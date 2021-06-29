import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ripe/ui/component/colors.dart';

typedef ContextCallback = void Function(BuildContext);

class SensorAppBar extends SliverPersistentHeaderDelegate {
  // ignore: non_constant_identifier_names
  static final _GRADIENT_TWEEN = Tween(begin: 0.0, end: 1.0);

  final double expandedHeight;
  final String name;
  final double textSize;
  final ImageProvider imageProvider;
  final ContextCallback onBack;

  SensorAppBar({
    required this.expandedHeight,
    required this.onBack,
    required this.textSize,
    required this.name,
    required this.imageProvider,
  });

  /*
   * Build
   */

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final qWidth = MediaQuery.of(context).size.width;
    double shrink = shrinkOffset / (maxExtent - kToolbarHeight - 8.0);
    shrink = max(0.0, min(1.0, shrink));

    final nameOpacity = max(
      0.0,
      min(1.0,
          ((shrinkOffset - (kToolbarHeight + 2)) / (kToolbarHeight + 2)) - 1),
    );

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [PRIMARY_COLOR, ACCENT_COLOR],
                  stops: [0.66, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Opacity(
              opacity: 1.0 - shrink,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Theme.of(context).canvasColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: kToolbarHeight / 2 + shrinkOffset / 3),
          child: Opacity(
            opacity: max(0.0, 1 - (shrinkOffset / expandedHeight) * 3),
            child: Column(
              children: <Widget>[
                Container(
                  width: expandedHeight,
                  height: max(0.000000000000000000001,
                      expandedHeight - kToolbarHeight - shrinkOffset),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.scaleDown,
                      image: imageProvider,
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: kToolbarHeight / 3,
          left: 70.0,
          child: Container(
            width: qWidth,
            child: Opacity(
              opacity: nameOpacity,
              child: Text(
                name,
                textAlign: TextAlign.start,
                style: theme.textTheme.headline6!.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          top: 6.0,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => onBack(context),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    if (oldDelegate is SensorAppBar) {
      return name != oldDelegate.name;
    }
    return false;
  }
}
