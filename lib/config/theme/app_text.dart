import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText {
  static final TextStyle bodyLarge = GoogleFonts.sen(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 16,
    color: Colors.white,
  );

  static final TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 30,
    color: Colors.white,
    fontWeight: FontWeight.bold
  );

  static final TextStyle headLineLarge = GoogleFonts.poppins(
    fontSize: 30,
    color: Colors.white,
    fontWeight: FontWeight.bold
  );

  static final TextStyle headLineMedium = GoogleFonts.poppins(
    fontSize: 30,
    color: Colors.white,
    fontWeight: FontWeight.bold
  );

  

  


  static final TextTheme textTheme = TextTheme(
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    titleLarge: titleLarge
  );
}
