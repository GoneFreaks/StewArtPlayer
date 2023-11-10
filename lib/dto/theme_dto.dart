import 'package:flutter/material.dart';

import '../helper/variable_holder.dart';

class ThemeDTO {

  static List<ThemeDTO> themes = [
    ThemeDTO(name: 'Standard', primaryColor: Colors.black, secondaryColor: Colors.deepPurpleAccent, backgroundColor: Colors.black38, textColor: Colors.white),
    ThemeDTO(name: 'Dunkel', primaryColor: Colors.black, secondaryColor: Colors.black, backgroundColor: Colors.black38, textColor: Colors.white),
    ThemeDTO(name: 'Dunkel-Orange', primaryColor: Colors.black, secondaryColor: Colors.orangeAccent, backgroundColor: Colors.black38, textColor: Colors.white),
    ThemeDTO(name: 'Dunkel-Blau', primaryColor: Colors.black, secondaryColor: Colors.blue, backgroundColor: Colors.black38, textColor: Colors.white),
    ThemeDTO(name: 'Dunkel-Rot', primaryColor: Colors.black, secondaryColor: Colors.red, backgroundColor: Colors.black38, textColor: Colors.white),
    ThemeDTO(name: 'Dunkel-Pink', primaryColor: Colors.black, secondaryColor: Colors.pink, backgroundColor: Colors.black38, textColor: Colors.white),
    ThemeDTO(name: 'Hell', primaryColor: Colors.white, secondaryColor: Colors.white, backgroundColor: Colors.white38, textColor: Colors.black),
    ThemeDTO(name: 'Hell-Gelb', primaryColor: Colors.white, secondaryColor: Colors.yellowAccent, backgroundColor: Colors.white38, textColor: Colors.black),
    ThemeDTO(name: 'Hell-Blau', primaryColor: Colors.white, secondaryColor: Colors.blue, backgroundColor: Colors.white38, textColor: Colors.black),
    ThemeDTO(name: 'Hell-Cyan', primaryColor: Colors.white, secondaryColor: Colors.cyan, backgroundColor: Colors.white38, textColor: Colors.black),
    ThemeDTO(name: 'Hell-Pink', primaryColor: Colors.white, secondaryColor: Colors.pinkAccent, backgroundColor: Colors.white38, textColor: Colors.black),
  ];

  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;

  ThemeDTO({required this.name, required this.primaryColor, required this.secondaryColor, required this.backgroundColor, required this.textColor});

  static TextStyle getBodyMedium(){
    return TextStyle(
      fontSize: 14,
      overflow: TextOverflow.ellipsis,
      color: themes[Holder.theme.value].textColor,
    );
  }

  static TextStyle getTitleLarge(){
    return TextStyle(
      fontSize: 21,
      overflow: TextOverflow.ellipsis,
      color: themes[Holder.theme.value].textColor,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle getTitleMedium() {
    return TextStyle(
      fontSize: 17,
      overflow: TextOverflow.ellipsis,
      color: themes[Holder.theme.value].textColor,
      fontWeight: FontWeight.bold,
    );
  }

  static Color getTextColor() {
    return themes[Holder.theme.value].textColor;
  }

  ThemeData asTheme(){
    return ThemeData(
      iconTheme: IconThemeData(
        color: textColor,
        size: 40
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.transparent,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: textColor,
        background: backgroundColor,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 21,
          overflow: TextOverflow.ellipsis,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          overflow: TextOverflow.ellipsis,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          overflow: TextOverflow.ellipsis,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          overflow: TextOverflow.ellipsis,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontSize: 10,
          overflow: TextOverflow.ellipsis,
          color: textColor,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          color: textColor,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}