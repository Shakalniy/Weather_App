import 'package:flutter/material.dart';

class SmallInfo extends StatelessWidget {
  SmallInfo({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${data["cloud"]} for the hour.",
          style: TextStyle(
              fontSize: 16,
              color: scheme.inversePrimary,
              fontWeight: FontWeight.w400
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 15),
                child: Stack(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                          color: scheme.tertiary,
                          borderRadius: BorderRadius.circular(60)
                      ),
                    ),
                    Image.network(
                      data["icon"],
                      height: 120,
                      width: 120,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      data["temp_${data["tempNotation"]}"] != null ?
                      Text(
                        "${data["temp_${data["tempNotation"]}"].round()}°",
                        style: TextStyle(
                            color: scheme.inversePrimary,
                            fontSize: 55,
                            fontWeight: FontWeight.w700,
                            height: 1
                        ),
                      ) : Container(),
                      SizedBox(width: 10,),
                      data["temp_${data["inverseNotation"]}"] != null ?
                      Text(
                        "${data["temp_${data["inverseNotation"]}"].round()}°",
                        style: TextStyle(
                            color: scheme.inversePrimary,
                            fontSize: data["temp_c"] == null ? 55 : 35,
                            fontWeight: FontWeight.w700,
                            height: 1
                        ),
                      ) : Container(),
                    ],
                  ),
                  Text(
                    "Feels like ${data["feelslike_${data["tempNotation"]}"].round()}°",
                    style: TextStyle(
                      color: scheme.onSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}