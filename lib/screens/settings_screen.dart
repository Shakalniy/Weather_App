import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../exports.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  String currentTheme = "";
  String currentSource = "";
  bool isLoading = true;
  late Color primaryColor;

  Future<String> _getData(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  Future _setData(String data, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, data);
  }

  void getCurrentData() async {
    String theme = await _getData("theme");
    if (theme == "") {
      theme = "system";
      await _setData("theme", theme);
    }
    String source = await _getData("source");
    if (source == "") {
      source = "International";
      await _setData("source", "International");
    }

    String colorStr = await _getData("primary_color");
    int value = int.parse(colorStr, radix: 16);

    setState(() {
      primaryColor = Color(value);
      currentTheme = theme[0].toUpperCase() + theme.substring(1);
      currentSource = source;
      isLoading = false;
    });
  }

  @override
  void initState() {
    getCurrentData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return isLoading ? Scaffold(body: const Center(child: CircularProgressIndicator(),), backgroundColor: scheme.background,)
      : Scaffold(
        appBar: AppBar(
          title: Text(
            "Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: scheme.inversePrimary,
            ),
          ),
          titleSpacing: 10,
          backgroundColor: scheme.background,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 0),
            child: Divider(
              height: 1,
              color: scheme.onSurface,
              thickness: 1,
            ),
          )
        ),
        backgroundColor: scheme.background,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.all(10),
                    child: Text(
                      "DISPLAY OPTIONS",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.inversePrimary,
                      ),
                    ),
                  ),
                  SettingsButton(
                    name: 'Units',
                    hintText: currentSource,
                    icon: Icons.language,
                    iconColor: Colors.orange,
                    route: '/units',
                    onBack: getCurrentData,
                  ),
                  SettingsButton(
                    name: 'Appearance',
                    hintText: currentTheme,
                    icon: Icons.dark_mode,
                    iconColor: Colors.orange,
                    route: '/appearance',
                    onBack: getCurrentData,
                  ),
                ],
              ),
            ),
            BottomMenu(currentScreen: "Settings", primaryColor: primaryColor,),
          ],
        ),
      );
  }
}