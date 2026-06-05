enum GoalCategory {
  career('carrière', '💼'),
  health('santé', '🏥'),
  finance('finances', '💰'),
  spirituality('spiritualité', '🧘'),
  relationships('relations', '❤️'),
  learning('apprentissage', '📚'),
  fitness('sport', '🏋️'),
  creativity('créativité', '🎨'),
  other('autre', '📌');

  final String label;
  final String emoji;

  const GoalCategory(this.label, this.emoji);

  String get displayName => '$emoji $label';
}

enum HabitFrequency {
  daily('quotidien', 'Tous les jours'),
  weekly('hebdomadaire', 'fois/semaine'),
  monthly('mensuel', 'fois/mois'),
  custom('personnalisé', 'Personnalisé');

  final String label;
  final String hint;

  const HabitFrequency(this.label, this.hint);
}

enum Mood {
  amazing('Génial', '🤩', 5),
  good('Bien', '😊', 4),
  neutral('Neutre', '😐', 3),
  low('Bas', '😔', 2),
  terrible('Difficile', '😢', 1);

  final String label;
  final String emoji;
  final int value;

  const Mood(this.label, this.emoji, this.value);
}

enum JournalType {
  morning('Intention du matin'),
  evening('Gratitude du soir');

  final String label;
  const JournalType(this.label);
}

enum GoalStatus {
  notStarted('À démarrer'),
  inProgress('En cours'),
  completed('Atteint'),
  abandoned('Abandonné');

  final String label;
  const GoalStatus(this.label);
}

enum PlanType {
  weekly('Hebdomadaire'),
  monthly('Mensuel');

  final String label;
  const PlanType(this.label);
}

enum BadgeType {
  firstGoal('Premier objectif', '🏆'),
  sevenDayStreak('7 jours', '🔥'),
  thirtyDayStreak('30 jours', '💪'),
  hundredDayStreak('100 jours', '👑'),
  tenGoals('Dix objectifs', '🎯'),
  pomodoroMaster('Maître Pomodoro', '⏱️'),
  journaling('Journalier', '📔');

  final String label;
  final String icon;

  const BadgeType(this.label, this.icon);
}
