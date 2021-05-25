import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iftem/ui/component/colors.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'ui/page/splash_screen.dart';

Future<void> main() async {
  if (kReleaseMode) {
    const dsn = 'https://2518fe9ebaaa43d8b2aa9c52e0a59974@sentry.if-lab.de/14';
    await SentryFlutter.init(
      (options) => options.dsn = dsn,
      appRunner: () => runApp(IftemApp()),
    );
  } else {
    runApp(IftemApp());
  }
}

class IftemApp extends StatelessWidget {
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
    const accentColor = ACCENT_COLOR;
    const backgroundColor = BACKGROUND_COLOR;
    const errorColor = ERROR_COLOR;
    const buttonColorDark = BUTTON_COLOR;
    const buttonColorLight = BUTTON_COLOR_LIGHT;

    final textTheme = theme.textTheme;
    return theme.copyWith(
      primaryColor: primaryColor,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      disabledColor: Colors.white60,
      dividerColor: primaryColor,
      errorColor: errorColor,
      focusColor: buttonColorLight,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      toggleableActiveColor: accentColor,
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
              ? accentColor
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
          overlayColor: MaterialStateProperty.all(accentColor),
        ),
      ),
    );
  }
}
