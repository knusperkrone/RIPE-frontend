import 'package:flutter/material.dart';


class AnimatedLoadingSpinner extends StatefulWidget {
  const AnimatedLoadingSpinner({required Key key}) : super(key: key);

  @override
  State createState() => AnimatedLoadingSpinnerState();
}

class AnimatedLoadingSpinnerState extends State<AnimatedLoadingSpinner> {
  bool _isShowing = false;

  void setShowing(bool isShowing) {
    if (_isShowing != isShowing) {
      setState(() => _isShowing = isShowing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isShowing ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: const LinearProgressIndicator(),
    );
  }
}
