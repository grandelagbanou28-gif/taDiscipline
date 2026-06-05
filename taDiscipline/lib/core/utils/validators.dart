class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email requis';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Au moins une majuscule';
    }
    if (!value.contains(RegExp(r'[0-9]'))) return 'Au moins un chiffre';
    return null;
  }

  static String? notEmpty(String? value, [String field = 'Champ']) {
    if (value == null || value.trim().isEmpty) return '$field requis';
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.isEmpty) return 'Code PIN requis';
    if (value.length != 6) return 'Le PIN doit contenir 6 chiffres';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Chiffres uniquement';
    return null;
  }

  static String? passwordStrength(String? value) {
    final passwordError = password(value);
    if (passwordError != null) return passwordError;
    if (value != null) {
      if (!value.contains(RegExp(r'[a-z]'))) return 'Ajoutez une minuscule';
      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return 'Idéal: ajoutez un caractère spécial';
      }
    }
    return null;
  }

  static double passwordScore(String password) {
    double score = 0;
    if (password.length >= 8) score += 25;
    if (password.contains(RegExp(r'[a-z]'))) score += 15;
    if (password.contains(RegExp(r'[A-Z]'))) score += 20;
    if (password.contains(RegExp(r'[0-9]'))) score += 20;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 20;
    return score.clamp(0, 100);
  }
}
