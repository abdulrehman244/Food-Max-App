class AppUtils {
  static String formatPrice(double price) {
    return "Rs ${price.toStringAsFixed(0)}";
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
