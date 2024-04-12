import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarometricPressureScreen extends StatefulWidget {
  const BarometricPressureScreen({super.key});

  @override
  State<BarometricPressureScreen> createState() => _BarometricPressureScreenState();
}

class _BarometricPressureScreenState extends State<BarometricPressureScreen> {

  bool isLoading = false;
  String barometric = "";

  void onBarometricChange(String bar) async {
    setState(() {
      isLoading = true;
    });

    await _setBarometric(bar, "barometric");

    setState(() {
      barometric = bar;
      isLoading = false;
    });
  }

  Future<String> _getBarometric(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  Future _setBarometric(String param, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, param);
  }

  void getData() async {
    String bar = await _getBarometric("barometric");
    if (bar == "") {
      await _setBarometric("mb", "barometric");
      bar = "mb";
    }
    setState(() {
      barometric = bar;
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
    return isLoading ? const Center(child: CircularProgressIndicator(),)
    : Scaffold(
        appBar: AppBar(
            title: Text(
              "Barometric Pressure",
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
                    "PICK YOUR PRESSURE",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.inversePrimary,
                  ),
                ),
              ),
              BarometricButton(
                name: 'Millibars (mb)',
                icon: Icons.straighten_outlined,
                onTap: () {
                  onBarometricChange("mb");
                },
                isChosen: barometric == "mb",
              ),
              BarometricButton(
                name: 'Mercury (mmHg)',
                icon: Icons.thermostat,
                onTap: () {
                  onBarometricChange("mmHg");
                },
                isChosen: barometric == "mmHg",
              ),
              BarometricButton(
                name: 'Mercury (inHg)',
                icon: Icons.thermostat,
                onTap: () {
                  onBarometricChange("inHg");
                },
                isChosen: barometric == "inHg",
              ),
              BarometricButton(
                name: 'Hectopascals (hPa)',
                icon: Icons.speed_outlined,
                onTap: () {
                  onBarometricChange("hPa");
                },
                isChosen: barometric == "hPa",
              ),
              BarometricButton(
                name: 'Kilopascals (kPa)',
                icon: Icons.speed_outlined,
                onTap: () {
                  onBarometricChange("kPa");
                },
                isChosen: barometric == "kPa",
              ),
            ],
          ),
        )
    );
  }
}

class BarometricButton extends StatelessWidget {
  const BarometricButton({
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
                color: Colors.orange,
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
