import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart' as intl;

class DetailedInfo extends StatelessWidget {
  DetailedInfo({super.key, required this.data});
  final Map<String, dynamic> data;

  String getWindDirection(int degree) {
    String direction = "";
    if (degree >= 293 || degree <= 68) {
      direction += "north";
    }
    if (degree >= 113 && degree <= 248) {
      direction += "south";
    }
    if (degree >= 23 && degree <= 158) {
      direction += "east";
    }
    if (degree >= 203 && degree <= 338) {
      direction += "west";
    }

    return direction;
  }

  String getUVRec(Color uv) {
    if (uv == Colors.green) {
      return "Enjoy the day.";
    }
    else if (uv == Colors.yellow) {
      return "Grab sunglasses.";
    }
    else if (uv == Colors.orange) {
      return "Generously apply broad spectrum.";
    }
    else if (uv == Colors.red) {
      return "Reduce time in the sun.";
    }
    return "Don't go outside.";
  }

  Map<String, IconData> moonIcon = {
    "New Moon": Icons.brightness_1_outlined,
    "Waxing Crescent": Icons.brightness_3,
    "First Quarter": Icons.brightness_2,
    "Waxing Gibbous": Icons.brightness_2,
    "Full Moon": Icons.brightness_1,
    "Waning Gibbous": Icons.brightness_2,
    "Last Quarter": Icons.brightness_2,
    "Waning Crescent": Icons.brightness_3,
  };

  int julianDate(int d, m, y) {

    int mm, yy;
    int k1, k2, k3;
    int j;

    yy = y - ((12 - m) / 10).floor();
    mm = m + 9;
    if (mm >= 12) {
      mm = mm - 12;
    }
    k1 = (365.25 * (yy + 4712)).floor();
    k2 = (30.6001 * mm + 0.5).floor();
    k3 = (((yy / 100) + 49).floor() * 0.75).floor() - 38;

    j = k1 + k2 + d + 59;
    if (j > 2299160)
    {
      j = j - k3;
    }
    return j;
  }

  double moonAge(int d, m, y) {
    int j = julianDate(d, m, y);
    double ag;
    double ip = (j + 4.867) / 29.53059;
    ip = ip - ip.floor();

    if (ip < 0.5)
      ag = ip * 29.53059 + 29.53059 / 2;
    else
      ag = ip * 29.53059 - 29.53059 / 2;

    ag = ag + 1;
    return ag;
  }

  String getFullMoonData(String time) {
    String date = time.split(" ")[0];
    List<String> times = date.split("-");
    int y = int.parse(times[0]);
    int m = int.parse(times[1]);
    int d = int.parse(times[2]);
    double mA = moonAge(d, m, y);
    int days;
    if (mA.floor() > 16) {
      days = (29.5 - mA + 16.6).floor();
    }
    else if (mA.floor()  == 16) {
      days = (mA - 16 + 29.5).round();
    }
    else {
      days = (16.6 - mA).floor();
    }

    DateTime newDate = DateTime(y, m, d);
    newDate = newDate.add(Duration(days: days));
    String dateStr = intl.DateFormat("MMM dd").format(newDate);
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    print(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatisticRow(
          degree: data["wind_degree"],
          icon: Icons.arrow_circle_left,
          iconColor: Colors.deepPurpleAccent,
          text1: "${data["wind_speed"].round()}${data["speed_not"]} winds from the ${getWindDirection(data["wind_degree"])}.",
          text2: "Visibility ${data["vis"].round()} ${data["dist_not"]}."
        ),
        StatisticRow(
          icon: Icons.water_drop,
          iconColor: Colors.lightBlueAccent,
          text1: "Humidity ${data["humidity"]}% • Dewpoint ${data["dewpoint"].round()}°.",
          text2: "Feels comfortable."
        ),
        StatisticRow(
          icon: Icons.compress,
          iconColor: Colors.yellow,
          text1: "Pressure ${data["pressure"]}${data["press_not"]}.",
          text2: "Fair conditions."
        ),
        StatisticRow(
          icon: Icons.wb_twilight,
          iconColor: Colors.amber,
          text1: "Sunrise ${data["sunrise"]} → sunset ${data["sunset"]}.",
          text2: "${data["daylight"]} hours of daylight."
        ),
        data["is_sun_up"] == 1 ?
        StatisticRow(
          uv: data["uv"],
          icon: Icons.circle,
          iconColor: data["uv_color"],
          text1: "${data["uv_risk"]} UV levels.",
          text2: getUVRec(data["uv_color"])
        ) :
        StatisticRow(
          degree: data["moon_phase"].contains("Waning") || data["moon_phase"].contains("Last") ? 90 : 0,
          icon: moonIcon[data["moon_phase"]]!,
          iconColor: scheme.inversePrimary,
          text1: "${data["moon_phase"]} moon tonight.",
          text2: "Next full moon on ${getFullMoonData(data["time"])}."
        ),
      ],
    );
  }
}

class StatisticRow extends StatelessWidget {
  const StatisticRow({
    super.key,
    this.degree,
    required this.icon,
    required this.iconColor,
    required this.text1,
    required this.text2,
    this.uv,
  });

  final int? degree;
  final int? uv;
  final IconData icon;
  final Color iconColor;
  final String text1;
  final String text2;

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          degree != null ?
          Transform.rotate(
            angle: (90 + degree!) * math.pi / 180,
            child: Icon(
              icon,
              color: iconColor,
              size: 33,
            ),
          )
          : uv != null ?
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 33,
              ),
              Text(
                "$uv",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700
                ),
              ),
            ],
          )
          : Icon(
            icon,
            color: iconColor,
            size: 33,
          ),
          SizedBox(width: 10,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text1,
                style: TextStyle(
                    fontSize: 14,
                    color: scheme.inversePrimary,
                    fontWeight: FontWeight.w400
                ),
              ),
              Text(
                text2,
                style: TextStyle(
                    fontSize: 14,
                    color: scheme.inversePrimary,
                    fontWeight: FontWeight.w400
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}