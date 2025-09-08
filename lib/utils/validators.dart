class Validators {
  static String? requiredField(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }

  static String? positiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v);
    if (n == null || n <= 0) return 'Enter a positive number';
    return null;
  }
}
