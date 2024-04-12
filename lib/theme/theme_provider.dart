import 'package:example/exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {

  late ThemeData _themeData;
  String _theme = "";
  String _localTime = "";

  ThemeData get themeData {
    _getTheme("theme");
    _getCurrentTime("localtime");
    if (_theme == "") {
      _theme == "system";
    }
    if (_theme == "system") {
      _theme = SchedulerBinding.instance.platformDispatcher.platformBrightness.name;
    }
    else if (_theme == "location") {
      String time = _localTime.split(" ")[1];
      int hour = int.parse(time.split(":")[0]);
      if (hour >= 18 || hour <= 6) {
        _theme = "dark";
      }
      else {
        _theme = "light";
      }
    }
    _themeData = _theme == "dark" ? darkMode : lightMode;
    return _themeData;
  }

  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  Future _setTheme(String theme, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, theme);
  }

  Future<String> _getTheme(String key) async {
    var prefs = await SharedPreferences.getInstance();
    _theme = prefs.getString(key) ?? "";
    return _theme;
  }

  Future<String> _getCurrentTime(String key) async {
    var prefs = await SharedPreferences.getInstance();
    _localTime = prefs.getString(key) ?? "";
    return _localTime;
  }

  Future<void> changeTheme(String theme) async {
    if(theme == "system") {
      _theme = SchedulerBinding.instance.platformDispatcher.platformBrightness.name;
    }
    else {
      _theme = theme;
    }
    await _setTheme(theme, "theme");
    await _getTheme("theme");
    themeData = theme == "light" ? lightMode : darkMode;
  }
}