import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WindSpeedScreen extends StatefulWidget {
  const WindSpeedScreen({super.key});

  @override
  State<WindSpeedScreen> createState() => _WindSpeedScreenState();
}

class _WindSpeedScreenState extends State<WindSpeedScreen> {

  bool isLoading = false;
  String windSpeed = "";
  String commonSpeed = "";

  void onWindSpeedChange(String ws) async {
    setState(() {
      isLoading = true;
    });

    await _setWindSpeed(ws, "wind_speed");

    setState(() {
      windSpeed = ws;
      isLoading = false;
    });
  }

  Future<String> _getWindSpeed(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  Future _setWindSpeed(String param, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, param);
  }

  void getData() async {
    String ws = await _getWindSpeed("wind_speed");
    String source = await _getWindSpeed("source");
    commonSpeed = source == "Canada" ? "KM/H" :
      source == "International" ? "M/S" : "MPH";

    if (ws == "") {
      await _setWindSpeed(commonSpeed, "wind_speed");
      ws = commonSpeed;
    }
    setState(() {
      windSpeed = ws;
      isLoading = false;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    ): Scaffold(
      appBar: AppBar(
        title: Text(
          "Wind Speed",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: scheme.inversePrimary,
          ),
        ),
        backgroundColor: scheme.background,
        iconTheme: IconThemeData(color: scheme.inversePrimary),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              child: Text(
                "SELECT A SPEED",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.inversePrimary,
                ),
              ),
            ),
            WindSpeedButton(
              name: commonSpeed,
              icon: Icons.north_east_outlined,
              onTap: () {
                onWindSpeedChange(commonSpeed);
              },
              isChosen: windSpeed == commonSpeed,
            ),
            WindSpeedButton(
              name: 'Knots',
              icon: Icons.tsunami,
              onTap: () {
                onWindSpeedChange("Knots");
              },
              isChosen: windSpeed == "Knots",
            ),
            WindSpeedButton(
              name: 'Beaufort',
              icon: Icons.air,
              onTap: () {
                onWindSpeedChange("Beaufort");
              },
              isChosen: windSpeed == "Beaufort",
            ),
          ],
        ),
      )
    );
  }
}

class WindSpeedButton extends StatelessWidget {
  const WindSpeedButton({
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
                color: Colors.deepPurple,
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
