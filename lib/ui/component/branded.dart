import 'package:flutter/material.dart';
import 'package:ripe/ui/component/colors.dart';

class RipeAppBar extends AppBar {
  RipeAppBar({
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Widget? title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    Color? shadowColor,
    ShapeBorder? shape,
    Color? backgroundColor,
    Brightness? brightness,
    IconThemeData? iconTheme,
    IconThemeData? actionsIconTheme,
    TextTheme? textTheme,
    bool primary = true,
    bool? centerTitle,
    bool excludeHeaderSemantics = false,
    double titleSpacing = NavigationToolbar.kMiddleSpacing,
    double toolbarOpacity = 1.0,
    double bottomOpacity = 1.0,
    double? toolbarHeight,
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

class RipeSnackbar extends SnackBar {
  static Text style(BuildContext context, String label) {
    final textTheme = Theme.of(context).textTheme.subtitle1!;
    return Text(label, style: textTheme.copyWith(color: Colors.black45));
  }

  RipeSnackbar(
    BuildContext context, {
    String label = '',
    SnackBarAction? action,
    Duration duration = const Duration(milliseconds: 4000),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) : super(
          content: RipeSnackbar.style(context, label),
          backgroundColor: BACKGROUND_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          action: action,
          duration: duration,
          behavior: behavior,
        );
}

class RipeIcon extends StatelessWidget {
  final IconData icon;

  const RipeIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    final size = Theme.of(context).iconTheme.size ?? 24.0;
    return ShaderMask(
      child: SizedBox(
        width: size * 1.2,
        height: size * 1.2,
        child: Icon(
          icon,
          size: size,
          color: Colors.white,
        ),
      ),
      shaderCallback: (Rect bounds) {
        final rect = Rect.fromLTRB(0, 0, size, size);
        return const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          stops: [0.0, 0.66],
          colors: [ACCENT_COLOR, PRIMARY_COLOR],
        ).createShader(rect);
      },
    );
  }
}
