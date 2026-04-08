class AppValidators {
  AppValidators._();

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? fullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 3) return 'Enter your full name';
    return null;
  }

  static String? studentId(String? v) {
    if (v == null || v.trim().isEmpty) return 'Student ID is required';
    if (v.trim().length < 4) return 'Enter a valid student ID';
    return null;
  }

  static String? required(String? v, {String field = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final re = RegExp(r'^\+?[0-9]{9,15}$');
    if (!re.hasMatch(v.replaceAll(' ', ''))) return 'Enter a valid phone number';
    return null;
  }
}
