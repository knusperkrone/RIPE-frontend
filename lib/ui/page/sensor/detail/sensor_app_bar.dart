import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ripe/ui/component/colors.dart';

typedef ContextCallback = void Function(BuildContext);

class SensorAppBar extends SliverPersistentHeaderDelegate {
  // static final _GRADIENT_TWEEN = Tween(begin: 0.0, end: 1.0);

  final double expandedHeight;
  final double topPadding;
  final String name;
  final double textSize;
  final ImageProvider imageProvider;
  final ContextCallback onBack;

  SensorAppBar({
    required this.expandedHeight,
    required this.topPadding,
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
          padding: EdgeInsets.only(
              top: kToolbarHeight / 2 + shrinkOffset / 3 + topPadding),
          child: Opacity(
            opacity: max(0.0, 1 - (shrinkOffset / expandedHeight) * 3),
            child: Column(
              children: <Widget>[
                Container(
                  width: expandedHeight,
                  height: max(double.minPositive,
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
          top: kToolbarHeight / 4 + topPadding,
          left: 70.0,
          child: Container(
            width: qWidth,
            child: Opacity(
              opacity: nameOpacity,
              child: Text(
                name,
                textAlign: TextAlign.start,
                style:
                    theme.textTheme.titleLarge!.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          top: 6.0 + topPadding,
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
  double get maxExtent => expandedHeight + topPadding;

  @override
  double get minExtent => kToolbarHeight + topPadding;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    if (oldDelegate is SensorAppBar) {
      return name != oldDelegate.name;
    }
    return false;
  }
}
