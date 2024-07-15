import 'package:flutter/material.dart';
import 'package:ripe/ui/component/colors.dart';

ThemeData buildTheme(ThemeData theme) {
  const primaryColor = PRIMARY_COLOR;
  const secondaryColor = ACCENT_COLOR;
  const backgroundColor = BACKGROUND_COLOR;
  const errorColor = ERROR_COLOR;
  const buttonColorDark = BUTTON_COLOR;
  const buttonColorLight = BUTTON_COLOR_LIGHT;

  final textTheme = theme.textTheme;
  return theme.copyWith(
    primaryColor: primaryColor,
    colorScheme: theme.colorScheme.copyWith(
      primary: primaryColor,
      onPrimary: buttonColorDark,
      secondary: secondaryColor,
      onSecondary: buttonColorLight,
      error: errorColor,
      outline: Colors.white70,
    ),
    iconTheme: theme.iconTheme.copyWith(
      color: backgroundColor,
      opacity: 1.0,
    ),
    iconButtonTheme: theme.iconButtonTheme,
    disabledColor: Colors.white60,
    focusColor: buttonColorLight,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    dividerTheme: theme.dividerTheme.copyWith(color: primaryColor),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          width: 2.0,
          color: BUTTON_COLOR_LIGHT,
        ),
      ),
    ),
    textSelectionTheme: theme.textSelectionTheme.copyWith(
      cursorColor: buttonColorLight,
    ),
    textTheme: textTheme.copyWith(
      titleMedium: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w300),
      titleSmall: textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w400),
    ),
    switchTheme: theme.switchTheme.copyWith(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return (states.contains(WidgetState.selected))
            ? buttonColorDark
            : buttonColorLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return (states.contains(WidgetState.selected))
            ? secondaryColor
            : Colors.white10;
      }),
    ),
    sliderTheme: theme.sliderTheme.copyWith(
      inactiveTrackColor: backgroundColor,
      activeTrackColor: buttonColorDark,
      thumbColor: buttonColorLight,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
      overlayColor: buttonColorLight.withOpacity(0.25),
    ),
    dialogTheme: theme.dialogTheme.copyWith(
      titleTextStyle: textTheme.labelLarge!.copyWith(
        color: primaryColor,
      ),
    ),
    timePickerTheme: theme.timePickerTheme.copyWith(
      dialHandColor: buttonColorDark,
      hourMinuteTextColor: Colors.white,
      hourMinuteColor: buttonColorLight,
    ),
    buttonTheme: theme.buttonTheme.copyWith(
      buttonColor: primaryColor,
    ),
    floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
      backgroundColor: buttonColorDark,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(buttonColorDark),
        overlayColor: WidgetStateProperty.all(buttonColorLight),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(primaryColor),
        overlayColor: WidgetStateProperty.all(secondaryColor),
      ),
    ),
  );
}
