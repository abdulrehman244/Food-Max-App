class Validators {
  static String? validateEmail(String value) {
    if (value.isEmpty) return "Email required";
    if (!value.contains("@")) return "Invalid email";
    return null;
  }

  static String? validatePhone(String value) {
    if (value.isEmpty) return "Phone number required";
    if (value.length < 10) return "Invalid phone number";
    return null;
  }

  static String? validateName(String value) {
    if (value.isEmpty) return "Name is required";
    return null;
  }
}
