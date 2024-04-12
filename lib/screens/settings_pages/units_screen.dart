import 'package:example/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  bool isLoading = true;
  String source = "";
  String windSpeed = "";
  String barometric = "";
  bool isHour = false;
  bool isTemp = false;
  bool isMachine = false;

  Map<String, String> pressure = {
    'mb': 'Millibars',
    'mmHg': 'Mercury',
    'inHg': 'Mercury',
    'hPa': 'Hectopascals',
    'kPa': 'Kilopascals',
  };

  Future _setSource(String source, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, source);
  }

  Future<String> _getSource(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  Future _setParam(bool param, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, param);
  }

  Future<bool> _getParam(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> getData() async {
    source = await _getSource("source");
    windSpeed = await _getSource("wind_speed");
    barometric = await _getSource("barometric");
    if (source == "") {
      source = "International";
      _setSource(source, "source");
    }
    if (windSpeed == "") {
      windSpeed = source == "Canada" ? "KM/H" :
        source == "International" ? "M/S" : "MPH";
      _setSource(windSpeed, "wind_speed");
    }
    if (barometric == "") {
      barometric = "mb";
      _setSource(barometric, "barometric");
    }


    isHour = await _getParam("24-hour");

    isTemp = await _getParam("fahrenheit_celsius");

    isMachine = await _getParam("machine");

    setState(() {
      isLoading = false;
    });
  }

  Future<void> onChangeSource(String newSource) async {
    String newWindSpeed = windSpeed;
    setState(() {
      isLoading = true;
    });
    await _setSource(newSource, "source");

    if (windSpeed != "Knots" && windSpeed != "Beaufort") {
      newWindSpeed = newSource == "Canada" ? "KM/H" :
      newSource == "International" ? "M/S" : "MPH";

      await _setSource(newWindSpeed, "wind_speed");
    }

    setState(() {
      source = newSource;
      windSpeed = newWindSpeed;
      isLoading = false;
    });
  }

  void onHourChange(bool value) async {
    await _setParam(value, "24-hour");
    setState(() {
      isHour = value;
    });
  }
  void onTempChange(bool value) async {
    await _setParam(value, "fahrenheit_celsius");
    setState(() {
      isTemp = value;
    });
  }
  void onMachineChange(bool value) async {
    await _setParam(value, "machine");
    setState(() {
      isMachine = value;
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
        ? Scaffold(
          body: const Center(
              child: CircularProgressIndicator(),
            ),
        backgroundColor: scheme.background,
        )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                "Weather Units",
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
                      "DATA SOURCE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.inversePrimary,
                      ),
                    ),
                  ),
                  UnitsButton(
                    location: "USA",
                    notation: "Fahrenheit, Miles, MPH",
                    asset: "assets/images/flag_usa.png",
                    isChosen: source == "USA",
                    onTap: () {
                      onChangeSource("USA");
                    },
                  ),
                  UnitsButton(
                    location: "UK",
                    notation: "Celsius, Miles, MPH",
                    asset: "assets/images/big_ben.png",
                    isChosen: source == "UK",
                    onTap: () {
                      onChangeSource("UK");
                    },
                  ),
                  UnitsButton(
                    location: "Canada",
                    notation: "Celsius, Kilometers, KM/H",
                    asset: "assets/images/leaf.png",
                    isChosen: source == "Canada",
                    onTap: () {
                      onChangeSource("Canada");
                    },
                  ),
                  UnitsButton(
                    location: "International",
                    notation: "Celsius, Kilometers, M/S",
                    asset: "assets/images/earth.png",
                    isChosen: source == "International",
                    onTap: () {
                      onChangeSource("International");
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "CUSTOM UNITS",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.inversePrimary,
                      ),
                    ),
                  ),
                  MaterialButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    onPressed: null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_outlined,
                              color: Colors.yellow,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "24-Hour Time",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: scheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                        CupertinoSwitch(
                          value: isHour,
                          onChanged: onHourChange,
                        )
                      ],
                    ),
                  ),
                  SettingsButton(
                    name: "Wind Speed",
                    hintText: windSpeed,
                    icon: Icons.north_east_outlined,
                    iconColor: Colors.deepPurple,
                    route: "/wind",
                    onBack: getData,
                  ),
                  SettingsButton(
                    name: "Barometric Pressure",
                    hintText: "${pressure[barometric]} ($barometric)",
                    icon: Icons.straighten_outlined,
                    iconColor: Colors.orange,
                    route: "/barometric",
                    onBack: getData,
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "SPECIAL MODES",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.inversePrimary,
                      ),
                    ),
                  ),
                  MaterialButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    onPressed: null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.thermostat,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Fahrenheit & Celsius",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: scheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                        CupertinoSwitch(
                          value: isTemp,
                          onChanged: onTempChange,
                        )
                      ],
                    ),
                  ),
                  MaterialButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    onPressed: null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.smart_toy_outlined,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Weather Machine",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: scheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                        CupertinoSwitch(
                          value: isMachine,
                          onChanged: onMachineChange,
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Use Fahrenheit & Celsius mode to see both units simultaneously. "
                          "Weather Machine shows app perfomance and debug info.",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: scheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class UnitsButton extends StatelessWidget {
  const UnitsButton({
    super.key,
    this.onTap,
    required this.location,
    required this.notation,
    required this.asset,
    required this.isChosen,
  });
  final void Function()? onTap;
  final String location;
  final String notation;
  final String asset;
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
              Image.asset(asset, width: 18),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: scheme.inversePrimary,
                    ),
                  ),
                  Text(
                    notation,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: scheme.inversePrimary,
                    )
                  ),
                ],
              )
            ],
          ),
          isChosen
              ? const Icon(
                  Icons.check,
                  color: Colors.grey,
                )
              : Container(),
        ],
      ),
    );
  }
}
