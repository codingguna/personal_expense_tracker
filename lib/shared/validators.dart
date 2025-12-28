String? requiredValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }
  return null;
}
String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return null; // Consider using requiredValidator for mandatory fields
  }
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}