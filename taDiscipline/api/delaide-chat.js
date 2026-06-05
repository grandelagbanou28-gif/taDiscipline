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

const { SUPABASE_URL, SUPABASE_ANON_KEY, XAI_API_KEY } = process.env;

async function supabaseFetch(path, body) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
      Prefer: 'return=representation',
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Supabase error ${res.status}: ${text}`);
  }
  return res.json();
}

async function handleToolCall(userId, toolName, args) {
  switch (toolName) {
    case 'create_goal':
      await supabaseFetch('goals', {
        user_id: userId,
        title: args.title,
        category: args.category || 'other',
        deadline: args.deadline || null,
        status: 'notStarted',
        progress: 0,
      });
      break;
    case 'add_habit':
      await supabaseFetch('habits', {
        user_id: userId,
        name: args.name,
        frequency: args.frequency || 'daily',
        target: args.target || 1,
      });
      break;
    case 'schedule_task': {
      const today = new Date().toISOString().split('T')[0];
      await supabaseFetch('plans', {
        user_id: userId,
        date: args.date || today,
        tasks: [{
          id: crypto.randomUUID ? crypto.randomUUID() : `${Date.now()}-${Math.random()}`,
          title: args.title,
          completed: false,
        }],
        type: 'weekly',
      });
      break;
    }
    case 'log_mood': {
      const dateStr = new Date().toISOString().split('T')[0];
      await supabaseFetch('journal_entries', {
        user_id: userId,
        date: dateStr,
        content_encrypted: '',
        mood: args.mood,
        type: 'morning',
      });
      break;
    }
  }
}

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ response: 'Method not allowed' });
  }

  try {
    const { user_id, message, history } = req.body;

    await supabaseFetch('chat_messages', { user_id, role: 'user', content: message });

    const grokMessages = [
      { role: 'system', content: SYSTEM_PROMPT },
      ...(history || []).map((m) => ({
        role: m.role === 'user' || m.role === 'assistant' ? m.role : 'user',
        content: m.content,
      })),
      { role: 'user', content: message },
    ];

    const grokRes = await fetch('https://api.x.ai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${XAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'grok-2-latest',
        messages: grokMessages,
        temperature: 0.7,
        max_tokens: 1024,
        tools: [
          {
            type: 'function',
            function: {
              name: 'create_goal',
              description: "Créer un nouvel objectif SMART",
              parameters: {
                type: 'object',
                properties: {
                  title: { type: 'string', description: "Titre de l'objectif" },
                  category: { type: 'string', enum: ['career', 'health', 'finance', 'spirituality', 'relationships', 'learning'] },
                  deadline: { type: 'string', description: 'Date limite ISO 8601' },
                },
                required: ['title'],
              },
            },
          },
          {
            type: 'function',
            function: {
              name: 'add_habit',
              description: 'Ajouter une nouvelle habitude',
              parameters: {
                type: 'object',
                properties: {
                  name: { type: 'string' },
                  frequency: { type: 'string', enum: ['daily', 'weekly', 'monthly'] },
                  target: { type: 'number' },
                },
                required: ['name', 'frequency'],
              },
            },
          },
        ],
      }),
    });

    if (!grokRes.ok) {
      throw new Error(`Grok API error: ${grokRes.status}`);
    }

    const grokData = await grokRes.json();
    const assistantMessage = grokData.choices[0]?.message;
    const content = assistantMessage?.content ?? '';
    const toolCalls = assistantMessage?.tool_calls;

    if (toolCalls && toolCalls.length > 0) {
      for (const call of toolCalls) {
        const args = JSON.parse(call.function.arguments);
        await handleToolCall(user_id, call.function.name, args);
      }
    }

    await supabaseFetch('chat_messages', { user_id, role: 'assistant', content });

    return res.json({ response: content });
  } catch (error) {
    console.error('DelAide chat error:', error);
    return res.status(500).json({
      response: 'Désolé, je rencontre des difficultés techniques. Réessaie dans un instant. \u{1F31F}',
    });
  }
};
