import 'package:flutter/material.dart';
import 'package:expandable_page_view/expandable_page_view.dart';

class WeekData extends StatefulWidget {
  WeekData({super.key, required this.data});
  final List<Map<String, dynamic>>data;

  @override
  State<WeekData> createState() => _WeekDataState();
}

class _WeekDataState extends State<WeekData> {

  double maxTemp = 0;
  double minTemp = 1000;
  int _current = 0;
  final PageController _controller = PageController();

  Map<int, String> weekDays = {
    1: "Monday",
    2: "Tuesday",
    3: "Wednesday",
    4: "Thursday",
    5: "Friday",
    6: "Saturday",
    7: "Sunday",
  };

  String getCondition() {
    String result = "${widget.data[0]["day"]["condition"]["text"]} today";
    int count = 0;
    String endDay = "";

    for (var dayData in widget.data) {
      String condition = dayData["day"]["condition"]["text"];
      if (result.contains(condition)) {
        count += 1;
      }
      else {
        endDay = dayData["date"];
      }
    }

    if (count >= 4) {
      result += " in the week";
    }
    else if (widget.data[0]["date"] != endDay) {
      var weekDay = weekDays[DateTime.parse(widget.data[0]["date"]).weekday];
      result += " and tomorrow through $weekDay";
    }

    return "$result.";
  }

  void getMinMax() {
    for (var dayData in widget.data) {
      double temp = dayData["day"]["maxtemp_${dayData["temp_not"]}"];
      if (temp > maxTemp) {
        maxTemp = temp;
      }
      if (temp < minTemp) {
        minTemp = temp;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    getMinMax();
    super.initState();
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
            "This week",
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
        ExpandablePageView(
          alignment: Alignment.bottomCenter,
          onPageChanged: (index) {
            setState(() {
              _current = index;
            });
          },
          controller: _controller,
          children: [
            WeekTempDiagram(
              data: widget.data,
              maxTemp: maxTemp,
              minTemp: minTemp,
            ),
            WeekWindData(
              data: widget.data,
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeekTempDiagram(
              data: widget.data,
              maxTemp: maxTemp,
              minTemp: minTemp,
            ),
            WeekWindData(
              data: widget.data,
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
    );
  }
}

class WeekTempDiagram extends StatelessWidget {
  WeekTempDiagram({
    super.key,
    required this.data,
    required this.maxTemp,
    required this.minTemp,
  });
  final List<Map<String, dynamic>> data;
  final double maxTemp;
  final double minTemp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var dayData in data)
          DayTempData(data: dayData, maxTemp: maxTemp, minTemp: minTemp, tempNot: dayData["temp_not"]!,)
      ],
    );
  }

}

class DayTempData extends StatelessWidget {
  DayTempData({
    super.key,
    required this.data,
    required this.maxTemp,
    required this.minTemp,
    required this.tempNot
  });
  final Map<String, dynamic> data;
  final double maxTemp;
  final double minTemp;
  final String tempNot;

  String getIcon() {
    return "https:${data["day"]["condition"]["icon"]}";
  }

  double getRainFallWidth(int shift) {
    return 10 + shift / 3;
  }

  double getMaxTempWidth(int shift, context) {
    var maxWidth = (MediaQuery.of(context).size.width / 4 - 50).round();
    int step = (maxWidth / (maxTemp - minTemp)).round();
    int width = 50 + (shift.round() - minTemp.round()) * step;
    return width / 1.0;
  }

  String getNum() {
    int number = int.parse(data["date"].split("-")[2]);
    return "$number";
  }

  String getWeekDay() {
    int weekday = DateTime.parse(data["date"]).weekday;
    return weekDays[weekday]!;
  }

  Map<int, String> weekDays = {
    1: "MON",
    2: "TUE",
    3: "WED",
    4: "THU",
    5: "FRI",
    6: "SAT",
    7: "SUN",
  };

  Color changeColorLightness(Color color) => HSLColor.fromColor(color).withLightness(0.4).toColor();

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Spacer(),
                  Container(
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                      color: data["day"]["daily_chance_of_rain"] == 0 ? Colors.transparent : Colors.cyanAccent
                    ),
                    child: Row(
                      children: [
                        data["day"]["daily_chance_of_rain"] != 0 ?
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text(
                                    "${data["day"]["daily_chance_of_rain"]}%",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: scheme.background,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                                SizedBox(width: getRainFallWidth(data["day"]["daily_chance_of_rain"]),)
                              ],
                            )
                        : Container(),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Stack(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: scheme.tertiary,
                                    borderRadius: BorderRadius.circular(60)
                                ),
                              ),
                              Center(
                                child: Image.network(
                                  getIcon(),
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 70,
              child: Column(
                children: [
                  Text(
                    getWeekDay(),
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.inversePrimary,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  Text(
                    getNum(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    height: 50,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          padding: EdgeInsets.all(5),
                          color: changeColorLightness(data["color"]),
                          child: Center(
                            child: Text(
                              "${data["day"]["mintemp_${data["temp_not"]}"].round()}°",
                              style: TextStyle(
                                fontSize: 18,
                                color: scheme.background,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                            color: data["color"],
                          ),
                          width: getMaxTempWidth(data["day"]["maxtemp_${tempNot}"].round(), context),
                          height: 50,
                          child: Row(
                            children: [
                              Spacer(),
                              Text(
                                "${data["day"]["maxtemp_${data["temp_not"]}"].round()}°",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: scheme.background,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer()
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 3)
      ],
    );
  }
}

class WeekWindData extends StatelessWidget {

  WeekWindData({
    super.key,
    required this.data,
  });
  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var dayData in data)
          DayWindData(data: dayData)
      ],
    );
  }

}

class DayWindData extends StatelessWidget {
  DayWindData({
    super.key,
    required this.data,
  });
  final Map<String, dynamic> data;

  String getNum() {
    int number = int.parse(data["date"].split("-")[2]);
    return "$number";
  }

  String getWeekDay() {
    int weekday = DateTime.parse(data["date"]).weekday;
    return weekDays[weekday]!;
  }

  String getIcon() {
    return "https:${data["day"]["condition"]["icon"]}";
  }

  Map<int, String> weekDays = {
    1: "MON",
    2: "TUE",
    3: "WED",
    4: "THU",
    5: "FRI",
    6: "SAT",
    7: "SUN",
  };

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 20,),
            Container(
              alignment: Alignment.center,
              width: 40,
              child: Column(
                children: [
                  Text(
                    getWeekDay(),
                    style: TextStyle(
                        fontSize: 14,
                        color: scheme.inversePrimary,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  Text(
                    getNum(),
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(5),
              child: Stack(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: scheme.tertiary,
                        borderRadius: BorderRadius.circular(60)
                    ),
                  ),
                  Center(
                    child: Image.network(
                      getIcon(),
                      height: 40,
                      width: 40,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${data["day"]["condition"]["text"]}. ${data["wind_speed"]} ${data["speed_not"]} winds.",
              maxLines: 2,
              style: TextStyle(
                  fontSize: 14,
                  color: scheme.inversePrimary,
                  fontWeight: FontWeight.w400
              ),
            ),
          ],
        ),
        SizedBox(height: 3)
      ],
    );
  }
  
}