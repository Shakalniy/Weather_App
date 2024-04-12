import 'package:example/exports.dart';
import 'package:flutter/material.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu({
    super.key,
    required this.currentScreen,
    required this.primaryColor
  });
  final String currentScreen;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.only(top: 10),
      alignment: Alignment.bottomCenter,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BottomButton(
            currentScreen: currentScreen,
            name: "Locations",
            route: "/locations",
            primaryColor: primaryColor,
            icon: Icons.location_on
          ),
          BottomButton(
            currentScreen: currentScreen,
            name: "Forecast",
            route: "/",
            primaryColor: primaryColor,
            icon: Icons.leaderboard
          ),
          BottomButton(
            currentScreen: currentScreen,
            name: "Settings",
            route: "/settings",
            primaryColor: primaryColor,
            icon: Icons.settings
          ),
        ],
      ),
    );
  }
}

class BottomButton extends StatelessWidget {

  BottomButton({
    super.key,
    required this.currentScreen,
    required this.name,
    required this.route,
    required this.primaryColor,
    required this.icon
  });
  final String currentScreen;
  final String name;
  final String route;
  final Color primaryColor;
  final IconData icon;

  Map<String, Widget> getWidget = {
    "/": ForecastScreen(),
    "/locations": LocationsScreen(),
    "/settings": SettingScreen(),
  };

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return MaterialButton(
        child: Column(
          children: [
            Icon(
              icon,
              color: currentScreen == name ? primaryColor : scheme.surface
            ),
            Text(
              name,
              style: TextStyle(
                color: currentScreen == name ? primaryColor : scheme.surface
              ),
            ),
          ],
        ),
        onPressed: (){
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => getWidget[route]!,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
    );
  }

}