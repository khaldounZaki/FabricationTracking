class Validators {
  static String? requiredText(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  static String? requiredPositiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v.trim());
    if (n == null || n <= 0) return 'Enter a positive number';
    return null;
  }
}
