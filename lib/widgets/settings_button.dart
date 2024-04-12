import 'package:example/exports.dart';
import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  SettingsButton({
    super.key,
    required this.name,
    required this.hintText,
    required this.icon,
    required this.iconColor,
    required this.route,
    this.onBack
  });
  final String name;
  final String hintText;
  final IconData icon;
  final Color iconColor;
  final String route;
  final void Function()? onBack;

  Map<String, Widget> getWidget = {
    "/appearance": AppearanceScreen(),
    "/units": UnitsScreen(),
    "/wind": WindSpeedScreen(),
    "/barometric": BarometricPressureScreen()
  };

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return MaterialButton(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
              ),
              const SizedBox(width: 10,),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: scheme.inversePrimary,
                ),
              )
            ],
          ),
          Text(
            hintText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: scheme.secondary,
            ),
          ),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => getWidget[route]!,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ).then((_) {onBack!();});
      }
    );
  }

}