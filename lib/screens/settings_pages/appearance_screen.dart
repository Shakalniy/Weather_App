import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {

  bool isLoading = true;
  String theme = "";


  void onThemeChange(String th) async {
    setState(() {
      isLoading = true;
    });
    var provider = Provider.of<ThemeProvider>(context, listen: false);
    await provider.changeTheme(th);

    setState(() {
      theme = th;
      isLoading = false;
    });
  }

  Future<String> _getTheme(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  Future _setTheme(String theme, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, theme);
  }

  void getData() async {
    String th = await _getTheme("theme");
    if (th == "") {
      th = "system";
      await _setTheme("theme", th);
    }
    setState(() {
      theme = th;
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    SwitchThemeOnSystem.switchTheme(context);
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return isLoading ? Scaffold(body: const Center(child: CircularProgressIndicator(),), backgroundColor: scheme.background,)
      : Scaffold(
        appBar: AppBar(
          title: Text(
            "Appearance",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: scheme.inversePrimary,
            ),
          ),
          backgroundColor: scheme.background,
          iconTheme: IconThemeData(
            color: scheme.inversePrimary
          ),
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
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              child: Text(
                "CHOOSE YOUR BRIGHTNESS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.inversePrimary,
                ),
              ),
            ),
            AppearanceButton(
              name: 'Match System',
              icon: Icons.settings,
              onTap: () {
                onThemeChange("system");
              },
              isChosen: theme == "system",
            ),
            AppearanceButton(
              name: 'Match Location',
              icon: Icons.location_on,
              onTap: () {
                onThemeChange("location");
              },
              isChosen: theme == "location",
            ),
            AppearanceButton(
              name: 'Light',
              icon: Icons.light_mode,
              onTap: () {
                onThemeChange("light");
              },
              isChosen: theme == "light",
            ),
            AppearanceButton(
              name: 'Dark',
              icon: Icons.dark_mode,
              onTap: () {
                onThemeChange("dark");
              },
              isChosen: theme == "dark",
            ),
          ],
        ),
      );
  }
}

class AppearanceButton extends StatelessWidget {
  const AppearanceButton({
    super.key,
    this.onTap,
    required this.name,
    required this.icon,
    required this.isChosen
  });
  final void Function()? onTap;
  final String name;
  final IconData icon;
  final bool isChosen;

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return MaterialButton(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.blue,
              ),
              const SizedBox(width: 10,),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: scheme.inversePrimary,
                ),
              ),
            ],
          ),
          isChosen ?
          const Icon(
            Icons.check,
            color: Colors.grey,
          ) : Container(),
        ],
      ),
    );
  }
}
