import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ripe/ui/component/colors.dart';

import 'ui/page/splash_screen.dart';

void main() async => runApp(RipeApp());

class RipeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const cachedLogo = AssetImage('assets/icon.png');
    precacheImage(cachedLogo, context, size: const Size(200.0, 200.0));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Ripe',
      theme: _prepareTheme(ThemeData.light()),
      darkTheme: _prepareTheme(ThemeData.dark()),
      home: const SplashScreen(cachedLogo),
    );
  }

  static ThemeData _prepareTheme(ThemeData theme) {
    const primaryColor = PRIMARY_COLOR;
    const secondaryColor = ACCENT_COLOR;
    const backgroundColor = BACKGROUND_COLOR;
    const errorColor = ERROR_COLOR;
    const buttonColorDark = BUTTON_COLOR;
    const buttonColorLight = BUTTON_COLOR_LIGHT;

    final textTheme = theme.textTheme;
    return theme.copyWith(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: theme.colorScheme.copyWith(
        primary: primaryColor,
        onPrimary: buttonColorDark,
        secondary: secondaryColor,
        onSecondary: buttonColorLight,
      ),
      backgroundColor: backgroundColor,
      disabledColor: Colors.white60,
      dividerColor: primaryColor,
      errorColor: errorColor,
      focusColor: buttonColorLight,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      toggleableActiveColor: secondaryColor,
      dividerTheme: theme.dividerTheme.copyWith(),
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
        subtitle1: textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w300),
        subtitle2: textTheme.subtitle2!.copyWith(fontWeight: FontWeight.w400),
      ),
      switchTheme: theme.switchTheme.copyWith(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          return (states.contains(MaterialState.selected))
              ? buttonColorDark
              : buttonColorLight;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          return (states.contains(MaterialState.selected))
              ? secondaryColor
              : backgroundColor;
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
        titleTextStyle: textTheme.button!.copyWith(
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
          foregroundColor: MaterialStateProperty.all(buttonColorDark),
          overlayColor: MaterialStateProperty.all(buttonColorLight),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(primaryColor),
          overlayColor: MaterialStateProperty.all(secondaryColor),
        ),
      ),
    );
  }
}
