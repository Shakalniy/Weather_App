import 'package:flutter/material.dart';
import 'exports.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        '/': (context) => const ForecastScreen(),
        '/locations': (context) => const LocationsScreen(),
        '/settings': (context) => const SettingScreen(),
        '/appearance': (context) => const AppearanceScreen(),
        '/units': (context) => const UnitsScreen(),
        '/wind': (context) => const WindSpeedScreen(),
        '/barometric': (context) => const BarometricPressureScreen(),
      },
      initialRoute: '/',
    );
  }
}
