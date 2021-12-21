import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BasePrefService {
  @protected
  static SharedPreferences? _prefs;

  @mustCallSuper
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @protected
  SharedPreferences get prefs => _prefs!;
}
