import 'package:flutter/material.dart';
import 'package:iftem/ui/component/colors.dart';

class IftemAppBar extends AppBar {
  IftemAppBar({
    Widget leading,
    bool automaticallyImplyLeading = true,
    Widget title,
    List<Widget> actions,
    PreferredSizeWidget bottom,
    Color shadowColor,
    ShapeBorder shape,
    Color backgroundColor,
    Brightness brightness,
    IconThemeData iconTheme,
    IconThemeData actionsIconTheme,
    TextTheme textTheme,
    bool primary = true,
    bool centerTitle,
    bool excludeHeaderSemantics = false,
    double titleSpacing = NavigationToolbar.kMiddleSpacing,
    double toolbarOpacity = 1.0,
    double bottomOpacity = 1.0,
    double toolbarHeight,
  }) : super(
          elevation: 2,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [PRIMARY_COLOR, ACCENT_COLOR],
                stops: [0.66, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: actions,
          leading: leading,
          automaticallyImplyLeading: automaticallyImplyLeading,
          title: title,
          bottom: bottom,
          shadowColor: shadowColor,
          shape: shape,
          backgroundColor: backgroundColor,
          brightness: brightness,
          iconTheme: iconTheme,
          actionsIconTheme: actionsIconTheme,
          textTheme: textTheme,
          primary: primary,
          centerTitle: centerTitle,
          excludeHeaderSemantics: excludeHeaderSemantics,
          titleSpacing: titleSpacing,
          toolbarOpacity: toolbarOpacity,
          bottomOpacity: bottomOpacity,
          toolbarHeight: toolbarHeight,
        );
}

class IftemSnackbar extends SnackBar {
  static Text style(BuildContext context, String label) {
    final textTheme = Theme.of(context).textTheme.subtitle1;
    return Text(label, style: textTheme.copyWith(color: Colors.black45));
  }

  IftemSnackbar(
    BuildContext context, {
    String label,
    SnackBarAction action,
    Duration duration = const Duration(milliseconds: 4000),
  }) : super(
          content: IftemSnackbar.style(context, label),
          backgroundColor: BACKGROUND_COLOR,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          action: action,
          duration: duration,
        );
}
