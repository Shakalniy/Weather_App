import 'dart:io';
import 'package:flutter/material.dart';
import '../exports.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:provider/provider.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:intl/intl.dart' as intl;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {

  final widgetController = PageController(initialPage: 0);

  bool isLoading = true;
  bool isMachine = false;
  String _location = "";
  int index = 0;
  int _current = 0;
  final PageController _controller = PageController();
  Map<String, dynamic> smallData = {};
  Map<String, dynamic> detailedData = {};
  Map<String, dynamic> hourData = {};
  List<Map<String, dynamic>> weekData = [];
  late Color primaryColor;
  ScreenshotController screenshotController = ScreenshotController();

  Future<String> _getStringParam(String key) async {
    var prefs = await SharedPreferences.getInstance();
    String city = prefs.getString(key) ?? "";
    return city;
  }

  Future _setStringParam(String city, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, city);
  }

  Future<bool> _getBoolParam(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future _setLocList(List<String> cities, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, cities);
  }

  int getBeaufort(int speed) {
    if (speed < 1.1) {
      return 0;
    }
    int r = 5;
    int border = 5;
    for (int i = 1; i < 13; i++) {
      if (speed <= border) {
        return i;
      }
      r += 1 * (i == 2 ? 2 : i == 9 ? 0 : 1);
      border += r;
    }
    return 12;
  }

  Future<List<dynamic>> getWindSpeed(speedKPH, speedN, String speedNotation, double parse) async {
    String speed = await _getStringParam("wind_speed");
    if (speed == "") {
      speed = "M/S";
      await _setStringParam(speed, "wind_speed");
    }
    int windSpeed = 0;
    String speed_not = "";

    if (speed == "Knots") {
      windSpeed = (speedKPH / 1.852).round();
      speed_not = "kn";
    }
    else if (speed == "Beaufort") {
      windSpeed = getBeaufort(speedKPH!.round());
      speed_not = "bft";
    }
    else {
      windSpeed = (speedN / parse).round();
      speed_not = parse == 3.6 ? "m/s" :
      speedNotation == "kph" ? "km/h" : "mph";
    }

    return [windSpeed, speed_not];
  }

  int getPressure(currentHour, String pressNot) {
    double pressure = currentHour["pressure_mb"];
    if (pressNot == "mb" || pressNot == "hPa") {
      return pressure.round();
    }
    else if (pressNot == "mmHg") {
      return (pressure / 1.33322).round();
    }
    else if (pressNot == "inHg") {
      return currentHour["pressure_in"].round();
    }
    else {
      return (pressure / 10).round();
    }
  }

  String getTime(String str) {
    List<String> time = str.split(" ");
    if (time[1] == "AM") {
      return time[0];
    }
    else {
      List<String> times = time[0].split(":");
      int hour = int.parse(times[0]) + 12;
      return "$hour:${times[1]}";
    }

  }

  String getDaylight(String sunrise, sunset) {
    sunrise = getTime(sunrise);
    sunset = getTime(sunset);
    var format = intl.DateFormat("HH:mm");
    var start = format.parse(sunrise);
    var end = format.parse(sunset);
    Duration duration = end.difference(start).abs();
    String hours = (duration.inHours + (duration.inMinutes % 60) / 60).toStringAsFixed(1);
    return hours;
  }

  List<dynamic> getUVRisk(int uv) {
    if (uv <= 2) {
      return ["Low", Colors.green];
    }
    else if (uv <= 5) {
      return ["Moderate", Colors.yellow];
    }
    else if (uv <= 7) {
      return ["High", Colors.orange];
    }
    else if (uv <= 10) {
      return ["Very high", Colors.red];
    }
    else {
      return ["Violet", Colors.purple];
    }
  }

  void setSmallData(current, bool isTemp, String tempNotation) {
    if (isTemp) {
      smallData["temp_f"] = current["temp_f"];
      smallData["temp_c"] = current["temp_c"];
    }
    else {
      smallData["temp_$tempNotation"] = current["temp_$tempNotation"];
    }
    smallData["feelslike_$tempNotation"] = current["feelslike_$tempNotation"];
    smallData["cloud"] = current["condition"]["text"];
    smallData["icon"] = "https:${current["condition"]["icon"]}";
    smallData["tempNotation"] = tempNotation;
    smallData["inverseNotation"] = tempNotation == "f" ? "c" : "f";
  }

  Future setDetailedData(currentHour, astro, double parse, String tempNotation, distNotation, speedNotation, bool isHour) async {
    String press = await _getStringParam("barometric");
    if (press == "") {
      press = "mb";
      await _setStringParam(press, "barometric");
    }

    List<dynamic> speedData = await getWindSpeed(currentHour["wind_kph"], currentHour["wind_$speedNotation"], speedNotation, parse);
    int pressure = getPressure(currentHour, press);
    String sunrise = astro["sunrise"];
    String sunset = astro["sunset"];
    String daylight = getDaylight(astro["sunrise"], astro["sunset"]);
    List<dynamic> uvParams = getUVRisk(currentHour["uv"].round());
    if (isHour) {
      sunrise = getTime(sunrise);
      sunset = getTime(sunset);
    }

    detailedData["time"] = currentHour["time"];
    detailedData["wind_speed"] = speedData[0];
    detailedData["wind_degree"] = currentHour["wind_degree"];
    detailedData["wind_dir"] = currentHour["wind_dir"];
    detailedData["vis"] = currentHour["vis_$distNotation"];
    detailedData["humidity"] = currentHour["humidity"];
    detailedData["dewpoint"] = currentHour["dewpoint_$tempNotation"];
    detailedData["uv"] = currentHour["uv"].round();
    detailedData["uv_risk"] = uvParams[0];
    detailedData["uv_color"] = uvParams[1];
    detailedData["sunrise"] = sunrise;
    detailedData["sunset"] = sunset;
    detailedData["daylight"] = daylight;
    detailedData["pressure"] = pressure;
    detailedData["press_not"] = press;
    detailedData["dist_not"] = distNotation == "km" ? "kilometers" : "miles";
    detailedData["speed_not"] = speedData[1];
    detailedData["moon_phase"] = astro["moon_phase"];
    detailedData["moon_illumination"] = astro["moon_illumination"];
    detailedData["is_sun_up"] = currentHour["is_day"];
  }

  Future<void> setHourData(forecast, astro, Color color, int hour, String tempNotation, speedNotation, bool isHour, parse) async {
    double tempToday = forecast[0]["day"]["avgtemp_c"];
    double tempTomorrow = forecast[1]["day"]["avgtemp_c"];
    String sunrise = getTime(astro["sunrise"]);
    String sunset = getTime(astro["sunset"]);
    String speed = await _getStringParam("wind_speed");

    hourData["current_hour"] = hour;
    hourData["primary_color"] = color;
    hourData["tempToday"] = tempToday;
    hourData["tempTomorrow"] = tempTomorrow;
    hourData["temp_not"] = tempNotation;
    hourData["speed_not"] = speedNotation;
    hourData["is_hour"] = isHour;
    hourData["sunrise"] = sunrise;
    hourData["sunset"] = sunset;
    hourData["parse"] = parse;
    hourData["speed"] = speed;
    hourData["hours_data"] = forecast;
  }

  Future<void> setWeekData(forecast, String tempNotation, color, speedNotation, parse) async {
    for (var dayData in forecast){
      List<dynamic> speedData = await getWindSpeed(dayData["day"]["maxwind_kph"], dayData["day"]["maxwind_$speedNotation"], speedNotation, parse);
      Map<String, dynamic> data = {};
      data["date"] = dayData["date"];
      data["day"] = dayData["day"];
      data["color"] = color;
      data["temp_not"] = tempNotation;
      data["speed_not"] = speedData[1];
      data["wind_speed"] = speedData[0];
      weekData.add(data);
    }
  }

  Future<void> getData() async {
    String cityName = await _getStringParam("current_city");

    if (cityName == "") {
      await _setStringParam("Omsk", "current_city");
      await _setLocList(["Omsk"], "locations_list");
      cityName = await _getStringParam("current_city");
    }

    final response = await http.get(Uri.parse('http://api.weatherapi.com/v1/forecast.json?key=62665fbae7ba46ed91c112909243103&q=$cityName&days=8&aqi=no&alerts=no'));
    var provider = Provider.of<ThemeProvider>(context, listen: false);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      var location = data["location"];
      var current = data["current"];
      var forecastDay = data["forecast"]["forecastday"];
      var astro = forecastDay[0]["astro"];
      var allHours = forecastDay[0]["hour"];

      String country = location["country"] == null ? "" : ", ${location["country"]}";
      String loc = cityName + country;

      String localtime = "${location["localtime"]}";
      await _setStringParam(localtime, "localtime");

      String time = localtime.split(" ")[1];
      int hour = int.parse(time.split(":")[0]);

      var currentHour = allHours[hour];

      bool isTemp = await _getBoolParam("fahrenheit_celsius");
      bool isHour = await _getBoolParam("24-hour");

      String source = await _getStringParam("source");
      if (source == "") {
        source = "International";
        await _setStringParam(source, "source");
      }
      String tempNotation = source == "USA" ? "f" : "c";
      String distNotation = ["USA", "UK"].contains(source) ? "miles" : "km";
      String speedNotation = ["Canada", "International"].contains(source) ? "kph": "mph";
      double parse = source == "International" ? 3.6 : 1.0;

      Color color = getPrimaryColor(current["temp_c"]);
      String colorString = color.toString();
      String valueString = colorString.split('(0x')[1].split(')')[0];
      await _setStringParam(valueString, "primary_color");

      setSmallData(current, isTemp, tempNotation);
      await setDetailedData(currentHour, astro, parse, tempNotation, distNotation, speedNotation, isHour);
      await setHourData(forecastDay, astro, color, hour, tempNotation, speedNotation, isHour, parse);
      await setWeekData(forecastDay, tempNotation, color, speedNotation, parse);

      String theme = await _getStringParam("theme");
      if (theme == "") {
        theme = "system";
        await _setStringParam(theme, "theme");
      }
      await provider.changeTheme(theme);

      bool machine = await _getBoolParam("machine");

      setState(() {
        primaryColor = color;
        isLoading = false;
        _location = loc;
        isMachine = machine;
      });
    }
    else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text(
            'Failed to load data',
            style: TextStyle(
                fontFamily: "RobotoSlab"
            ),
          ),
        ),
      );
      throw Exception('Failed to load data');
    }
  }

  Color getPrimaryColor(double temp) {
    var scheme = Theme.of(context).colorScheme;
    if (temp < -5) {
      return Colors.purple;
    }
    else if (temp < 5) {
      return scheme.outline;
    }
    else if (temp < 15) {
      return scheme.primary;
    }

    return scheme.scrim;
  }

  Future<void> _pullRefresh() async {
    setState(() {
      isLoading = true;
    });
    getData();
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
      : Screenshot(
      controller: screenshotController,
        child: Scaffold(
        appBar: AppBar(
          backgroundColor: scheme.background,
          automaticallyImplyLeading: false,
          leadingWidth: 0,
          title: GestureDetector(
            child: Text(
              _location,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => LocationsScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () async {
                Directory root = await getTemporaryDirectory();
                String directoryPath = '${root.path}/screens';
                String? screenshot = await screenshotController.captureAndSave(directoryPath);
                print(screenshot);

                final result = await Share.shareXFiles([XFile(screenshot!)], text: 'Your screenshot');

                if (result.status == ShareResultStatus.success) {
                  print('Thank you for sharing the picture!');
                }
                await File(screenshot).delete();
              },
              padding: const EdgeInsets.only(right: 10),
              icon: const Icon(Icons.share),
              color: primaryColor,
            )
          ],
          titleSpacing: 10,
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 0),
            child: Divider(
              height: 1,
              indent: 10,
              endIndent: 10,
              color: primaryColor,
              thickness: 1,
            ),
          )
        ),

        backgroundColor: scheme.background,
        body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 20,),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Right now",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 28,
                        color: scheme.inversePrimary,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                Column(
                  children: [
                    ExpandablePageView(
                      onPageChanged: (index) {
                        setState(() {
                          _current = index;
                        });
                      },
                      controller: _controller,
                      children: [
                        SmallInfo(data: smallData),
                        DetailedInfo(data: detailedData)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [SmallInfo(data: smallData), DetailedInfo(data: detailedData)].asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _controller.animateToPage(entry.key, duration: Duration(milliseconds: 500), curve: Curves.ease),
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (scheme.inversePrimary)
                                    .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 30,),
                HourData(data: hourData,),
                SizedBox(height: 20,),
                WeekData(data: weekData,),
                SizedBox(height: 20,),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomMenu(currentScreen: "Forecast", primaryColor: primaryColor,)
            ),
      );
  }
}
