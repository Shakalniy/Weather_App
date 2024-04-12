import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwitchThemeOnSystem {

  static Future<String> _getTheme(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  static void switchTheme(context) {
    var dispatcher = SchedulerBinding.instance.platformDispatcher;
    var provider = Provider.of<ThemeProvider>(context, listen: false);

    // This callback is called every time the brightness changes.
    dispatcher.onPlatformBrightnessChanged = () async {
      String theme = await _getTheme("theme");
      if (theme == "system") {
        await provider.changeTheme(theme);
      }
    };
  }
}