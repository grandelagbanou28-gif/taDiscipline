import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Types
interface ChatRequest {
  user_id: string;
  message: string;
  history: { role: string; content: string }[];
  user_context: Record<string, unknown>;
}

interface ToolCall {
  name: string;
  arguments: Record<string, unknown>;
}

const SYSTEM_PROMPT = `Tu es DelAide IA, l'assistant personnel de discipline et coaching de l'application taDiscipline. Tu es propulsé par Grok (xAI).

Personnalité :
- Bienveillant mais ferme, comme un coach sportif qui croit en toi
- Tutoiement naturel et chaleureux
- Réponses concises et motivantes
- Utilise des emojis avec parcimonie mais à bon escient

Capacités :
- Coaching personnalisé selon le profil et l'historique
- Décomposition d'objectifs ambitieux en plans d'action concrets (SMART)
- Feedback quotidien sur la progression
- Suggestions d'habitudes alignées sur les objectifs
- Défis hebdomadaires sur-mesure
- Analyse de tendances et insights

Règles :
- TOUJOURS répondre en français
- Ne jamais donner de conseils médicaux ou psychologiques professionnels
- En cas de détection de crise, recommander de contacter un professionnel
- Privilégier les actions concrètes aux encouragements vagues
- Adapter le ton à l'humeur détectée de l'utilisateur

Outils disponibles :
1. create_goal : Créer un nouvel objectif SMART
2. add_habit : Ajouter une nouvelle habitude
3. schedule_task : Planifier une tâche dans l'agenda
4. log_mood : Enregistrer l'humeur du jour`;

serve(async (req: Request) => {
  try {
    const { user_id, message, history, user_context }: ChatRequest =
      await req.json();

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const xaiApiKey = Deno.env.get("XAI_API_KEY") ?? "";

    const supabase = createClient(supabaseUrl, supabaseKey);

    // Save user message
    await supabase.from("chat_messages").insert({
      user_id,
      role: "user",
      content: message,
    });

    // Prepare messages for Grok
    const grokMessages = [
      { role: "system", content: SYSTEM_PROMPT },
      ...history.map((m) => ({
        role: m.role as "user" | "assistant" | "system",
        content: m.content,
      })),
      { role: "user" as const, content: message },
    ];

    // Call xAI Grok API
    const grokResponse = await fetch(
      "https://api.x.ai/v1/chat/completions",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${xaiApiKey}`,
        },
        body: JSON.stringify({
          model: "grok-2-latest",
          messages: grokMessages,
          temperature: 0.7,
          max_tokens: 1024,
          tools: [
            {
              type: "function",
              function: {
                name: "create_goal",
                description: "Créer un nouvel objectif SMART",
                parameters: {
                  type: "object",
                  properties: {
                    title: {
                      type: "string",
                      description: "Titre de l'objectif",
                    },
                    category: {
                      type: "string",
                      enum: [
                        "career",
                        "health",
                        "finance",
                        "spirituality",
                        "relationships",
                        "learning",
                      ],
                    },
                    deadline: {
                      type: "string",
                      description: "Date limite ISO 8601",
                    },
                  },
                  required: ["title"],
                },
              },
            },
            {
              type: "function",
              function: {
                name: "add_habit",
                description: "Ajouter une nouvelle habitude",
                parameters: {
                  type: "object",
                  properties: {
                    name: { type: "string" },
                    frequency: {
                      type: "string",
                      enum: ["daily", "weekly", "monthly"],
                    },
                    target: { type: "number" },
                  },
                  required: ["name", "frequency"],
                },
              },
            },
          ],
        }),
      },
    );

    if (!grokResponse.ok) {
      throw new Error(`Grok API error: ${grokResponse.status}`);
    }

    const grokData = await grokResponse.json();
    const assistantMessage = grokData.choices[0]?.message;
    const content = assistantMessage?.content ?? "";
    const toolCalls = assistantMessage?.tool_calls;

    // Handle tool calls
    if (toolCalls && toolCalls.length > 0) {
      for (const call of toolCalls) {
        const args = JSON.parse(call.function.arguments);
        await handleToolCall(supabase, user_id, call.function.name, args);
      }
    }

    // Save assistant response
    await supabase.from("chat_messages").insert({
      user_id,
      role: "assistant",
      content,
    });

    return new Response(JSON.stringify({ response: content }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("DelAide chat error:", error);
    return new Response(
      JSON.stringify({
        response:
          "Désolé, je rencontre des difficultés techniques. Réessaie dans un instant. 🌟",
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  }
});

async function handleToolCall(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  toolName: string,
  args: Record<string, unknown>,
) {
  switch (toolName) {
    case "create_goal":
      await supabase.from("goals").insert({
        user_id: userId,
        title: args.title,
        category: args.category ?? "other",
        deadline: args.deadline ?? null,
        status: "notStarted",
        progress: 0,
      });
      break;

    case "add_habit":
      await supabase.from("habits").insert({
        user_id: userId,
        name: args.name,
        frequency: args.frequency ?? "daily",
        target: args.target ?? 1,
      });
      break;

    case "schedule_task":
      await supabase.from("plans").upsert({
        user_id: userId,
        date: args.date,
        tasks: supabase.rpc("jsonb_set", {
          target: [],
          path: [],
          value: [
            {
              id: crypto.randomUUID(),
              title: args.title,
              completed: false,
            },
          ],
        }),
        type: "weekly",
      });
      break;

    case "log_mood":
      const today = new Date().toISOString().split("T")[0];
      await supabase.from("journal_entries").upsert({
        user_id: userId,
        date: today,
        content_encrypted: "",
        mood: args.mood,
        type: "morning",
      });
      break;
  }
}
