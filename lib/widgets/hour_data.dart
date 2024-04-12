import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class HourData extends StatefulWidget {
  HourData({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  State<HourData> createState() => _HourDataState();
}

class _HourDataState extends State<HourData> {

  int _current = 0;
  final PageController _controller = PageController();
  int maxTemp = 0;
  int minTemp = 1000;

  String getTimeText() {
    int hour = widget.data["current_hour"];
    if (hour < 12) {
      return "This morning";
    }
    else if (hour < 18) {
      return "This afternoon";
    }
    return "Tonight and tomorrow";
  }

  String getCondition() {
    int hour = widget.data["current_hour"];
    String condition = widget.data["hours_data"][0]["hour"][hour]["condition"]["text"];
    String result = "$condition";
    double tempToday = widget.data["tempToday"];
    double tempTomorrow = widget.data["tempTomorrow"];
    double diff = tempTomorrow - tempToday;

    if (hour < 18) {
      result += ".";
    }
    else {
      result += " tonight. Tomorrow will be a ";

      if (diff.abs() < 5 && diff.abs() > 0) {
        result += "little ";
      }

      if (diff > 0) {
        result += "warmer.";
      }
      else if (diff < 0) {
        result += "colder.";
      }
      else {
        result += "the same.";
      }
    }

    return result;
  }

  String getTime(dataTime) {
    String time = dataTime.split(" ")[1];
    int currentHour = int.parse(time.split(":")[0]);
    int sunriseHour = int.parse(widget.data["sunrise"].split(":")[0]);
    int sunsetHour = int.parse(widget.data["sunset"].split(":")[0]);

    if (currentHour == sunriseHour) {
      return widget.data["sunrise"];
    }
    if (currentHour == sunsetHour) {
      return widget.data["sunset"];
    }
    if(widget.data["is_hour"] == false) {
      return getFormattedTime(time);
    }

    return time;
  }

  String getFormattedTime(String time) {
    int hour = int.parse(time.split(":")[0]);

    if (hour > 12) {
      return "${hour - 12}pm";
    }
    else if (hour == 12) {
      return "${hour}pm";
    }
    else if (hour == 0) {
      return "12am";
    }
    else {
      return "${hour}am";
    }
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

  int getWindSpeed(currentHour, String speedNotation, double parse) {
    String speed = widget.data["speed"];
    int windSpeed = 0;

    if (speed == "Knots") {
      windSpeed = (currentHour["wind_kph"] / 1.852).round();
    }
    else if (speed == "Beaufort") {
      windSpeed = getBeaufort(currentHour["wind_kph"]!.round());
    }
    else {
      windSpeed = (currentHour["wind_$speedNotation"] / parse).round();
    }

    return windSpeed;
  }

  List<Map<String, dynamic>> getHoursData(int start) {
    var list = widget.data["hours_data"][0]["hour"];
    int pos = start;
    String speedNot = widget.data["speed_not"];
    String tempNot = widget.data["temp_not"];

    List<Map<String, dynamic>> result = [];

    int i = 0;

    while (i < 8) {
      Map<String, dynamic> hourData = {};
      if (pos == 24) {
        pos = 0;
        list = widget.data["hours_data"][1]["hour"];
      }
      var hour = list[pos];
      hourData["time"] = getTime(hour["time"]);
      hourData["temp"] = hour["temp_$tempNot"];
      hourData["wind_degree"] = hour["wind_degree"];
      hourData["wind_dir"] = hour["wind_dir"];
      hourData["wind_speed"] = getWindSpeed(hour, speedNot, widget.data["parse"]);
      hourData["icon"] = "https:${hour["condition"]["icon"]}";
      if (hourData["temp"].round() > maxTemp) {
        setState(() {
          maxTemp = hourData["temp"].round();
        });
      }
      if (hourData["temp"].round() < minTemp) {
        setState(() {
          minTemp = hourData["temp"].round();
        });
      }
      pos += 1;
      i += 1;
      result.add(hourData);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            getTimeText(),
            maxLines: 2,
            style: TextStyle(
              fontSize: 28,
              color: scheme.inversePrimary,
              fontWeight: FontWeight.w600
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            getCondition(),
            style: TextStyle(
              fontSize: 16,
              color: scheme.inversePrimary,
              fontWeight: FontWeight.w400
            ),
          ),
        ),
        SizedBox(height: 20,),
        Column(
          children: [
            ExpandablePageView(
              alignment: Alignment.bottomCenter,
              onPageChanged: (index) {
                setState(() {
                  _current = index;
                });
              },
              controller: _controller,
              children: [
                HoursDiagram(
                  hours: getHoursData(widget.data["current_hour"]),
                  color: widget.data["primary_color"],
                  maxTemp: maxTemp,
                  minTemp: minTemp,
                ),
                HoursDiagram(
                  hours: getHoursData((widget.data["current_hour"] + 8) % 24),
                  color: widget.data["primary_color"],
                  maxTemp: maxTemp,
                  minTemp: minTemp,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HoursDiagram(
                  hours: getHoursData(widget.data["current_hour"]),
                  color: widget.data["primary_color"],
                  maxTemp: maxTemp,
                  minTemp: minTemp,
                ),
                HoursDiagram(
                  hours: getHoursData((widget.data["current_hour"] + 8) % 24),
                  color: widget.data["primary_color"],
                  maxTemp: maxTemp,
                  minTemp: minTemp,
                ),
              ].asMap().entries.map((entry) {
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
      ],
    );
  }
}

class HoursDiagram extends StatelessWidget {
  HoursDiagram({
    super.key,
    required this.hours,
    required this.color,
    required this.maxTemp,
    required this.minTemp,
  });
  final List<Map<String, dynamic>> hours;
  final Color color;
  final int maxTemp;
  final int minTemp;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        children: [
          Expanded(child: Container()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (var i = 0; i < hours.length; i++)
                Row(
                  children: [
                    DataColumn(hour: hours[i], color: color, maxTemp: maxTemp, minTemp: minTemp),
                    SizedBox(width: 3,)
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

}

class DataColumn extends StatelessWidget {
  DataColumn({
    super.key,
    required this.hour,
    required this.color,
    required this.maxTemp,
    required this.minTemp,
  });
  final Map<String, dynamic> hour;
  final Color color;
  final int maxTemp;
  final int minTemp;

  double getHeight() {
    int step = (60 / (maxTemp - minTemp)).round();
    int height = 60 + ((hour["temp"] as double).round() - minTemp.round()) * step;
    return height / 1.0;
  }

  String getWindDirection(int degree) {
    String direction = "";
    if (degree >= 293 || degree <= 68) {
      direction += "n";
    }
    if (degree >= 113 && degree <= 248) {
      direction += "s";
    }
    if (degree >= 23 && degree <= 158) {
      direction += "e";
    }
    if (degree >= 203 && degree <= 338) {
      direction += "w";
    }

    return direction;
  }

  Map<String, int> getDegree = {
    "n": 0,
    "ne": 45,
    "e": 90,
    "se": 135,
    "s": 180,
    "sw": 225,
    "w": 270,
    "nw": 315
  };

  String getIcon() {
    return hour["condition"]["icon"];
  }

  double getWidth(context) {
    return (MediaQuery.of(context).size.width - 30 - 24) / 8;
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: getWidth(context),
          height: getHeight(), // 100 - max
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "${hour["temp"].round()}°",
                style: TextStyle(
                  fontSize: 16,
                  color: scheme.background,
                  fontWeight: FontWeight.w500
                ),
              ),
              Expanded(child: Container()),
              Transform.rotate(
                angle: getDegree[getWindDirection(hour["wind_degree"])]! * math.pi / 180,
                child: Icon(
                  Icons.arrow_upward,
                  size: 16,
                  color: scheme.background,
                ),
              ),
              Text(
                "${hour["wind_speed"]}${getWindDirection(hour["wind_degree"])}",
                style: TextStyle(
                  fontSize: 10,
                  color: scheme.background,
                  fontWeight: FontWeight.w400
                ),
              ),
              SizedBox(height: 3,)
            ]
          ),
        ),
        SizedBox(height: 5,),
        Text(
          hour["time"],
          style: TextStyle(
              fontSize: 10,
              color: scheme.inversePrimary,
              fontWeight: FontWeight.w400
          ),
        ),
        SizedBox(height: 5,),
        Stack(
          children: [
            Container(
              height: getWidth(context) - 10,
              width: getWidth(context) - 10,
              decoration: BoxDecoration(
                  color: scheme.tertiary,
                  borderRadius: BorderRadius.circular(60)
              ),
            ),
            Center(
              child: Image.network(
                hour["icon"],
                height: getWidth(context) - 10,
                width: getWidth(context) - 10,
              ),
            ),
          ],
        )
      ],
    );
  }

}