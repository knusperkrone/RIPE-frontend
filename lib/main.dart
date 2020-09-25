import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iftem/ui/component/colors.dart';

import 'ui/page/splash_screen.dart';

void main() {
  runApp(IftemApp());
}

class IftemApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    const cachedLogo = AssetImage('assets/icon.png');
    precacheImage(cachedLogo, context);

    return MaterialApp(
      title: 'Iftem',
      theme: _prepareTheme(ThemeData.light()),
      home: const SplashScreen(cachedLogo),
    );
  }

  static ThemeData _prepareTheme(ThemeData theme) {
    const primaryColor = PRIMARY_COLOR;
    const accentColor = ACCENT_COLOR;
    const backgroundColor = BACKGROUND_COLOR;
    const errorColor = ERROR_COLOR;
    // const warnColor = Color(0xffE8A233);

    final textTheme = theme.textTheme;
    return theme.copyWith(
      primaryColor: primaryColor,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      disabledColor: Colors.white60,
      dividerColor: primaryColor,
      errorColor: errorColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      toggleableActiveColor: accentColor,
      dividerTheme: theme.dividerTheme.copyWith(),
      textTheme: theme.textTheme.copyWith(
        subtitle1: textTheme.subtitle1.copyWith(fontWeight: FontWeight.w300),
        subtitle2: textTheme.subtitle2.copyWith(fontWeight: FontWeight.w400),
      ),
      sliderTheme: theme.sliderTheme.copyWith(
        inactiveTrackColor: backgroundColor,
        activeTrackColor: accentColor,
        thumbColor: accentColor,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
      ),
    );
  }
}
