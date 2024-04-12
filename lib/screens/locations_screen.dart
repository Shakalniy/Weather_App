import 'package:flutter/material.dart';
import 'package:flutter_location_search/flutter_location_search.dart';
import '../exports.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {

  String _locationText = '';
  bool isLoading = true;
  String _localPos = '';
  List<String> _locationsList = [];
  late Color primaryColor;

  Future _setLocList(List<String> cities, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, cities);
  }

  Future<List<String>> _getLocList(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  Future _setStringParam(String city, String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, city);
  }

  Future<String> _getStringParam(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          isLoading = false;
        });
        _showToast(context, 'Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        isLoading = false;
      });
      _showToast(context, 'Location permissions are permanently denied, we cannot request permissions.');
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> _getAddressFromLatLng(position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      return place.locality ?? place.administrativeArea ?? "Kazan";

    } 
    catch (e) {
      print(e);
    }
    return "Kazan";
  }

  Future getData() async {
    _locationsList = await _getLocList("locations_list");

    String colorStr = await _getStringParam("primary_color");
    int value = int.parse(colorStr, radix: 16);

    setState(() {
      isLoading = false;
      primaryColor = Color(value);
    });
  }

  Future getLoc() async {
    setState(() {
      isLoading = true;
    });
    Position position = await _getGeoLocationPosition();
    String place = await _getAddressFromLatLng(position);

    setState(() {
      _localPos = place;
    });
  }

  Future addCity(locationData) async {
    var locData = locationData.addressData;
    _locationText = "${locData["city"]}, ${locData["country"]}";

    List<String> locationsList = await _getLocList("locations_list");
    if (!locationsList.contains(_locationText)) {
      locationsList.add(_locationText);
      await _setLocList(locationsList, "locations_list");
    }

    String city = locData["city"];
    await _setStringParam(city, "current_city");
    Navigator.pushNamed(context, '/');
  }

  Future removeCity(String location) async {
    List<String> locationsList = await _getLocList("locations_list");
    locationsList.remove(location);
    await _setLocList(locationsList, "locations_list");

    String currentCity = await _getStringParam("current_city");
    if (currentCity == location.split(",")[0]) {
      currentCity = _localPos;
      await _setStringParam(currentCity, "current_city");
      Navigator.pushNamed(context, '/');
    }
    setState(() {
      _locationsList = locationsList;
    });
  }

  void _showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    var scheme = Theme.of(context).colorScheme;
    scaffold.showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(
            color: scheme.inversePrimary,
            fontFamily: 'RobotoNormal',
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
      ),
    );
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return isLoading ? Scaffold(body: Center(child: CircularProgressIndicator()), backgroundColor: scheme.background,) :
      Scaffold(
      appBar: AppBar(
        title: Text(
          "Locations",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: scheme.inversePrimary,
          ),
        ),
        titleSpacing: 10,
        backgroundColor: scheme.background,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            color: scheme.inversePrimary,
            onPressed: () async {
              LocationData? locationData = await LocationSearch.show(
                context: context,
                lightAdress: true,
                mode: Mode.fullscreen,
                currentPositionButtonText: "Current location",
                historyMaxLength: 3,
                searchBarBackgroundColor: Colors.grey,
                searchBarTextColor: scheme.inversePrimary,
                iconColor: scheme.inversePrimary,
                language: 'en'
              );
              if (locationData != null) {
                await addCity(locationData);
              }
            },
          )
        ],
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
            MaterialButton(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/target.png",
                    width: 20,
                    color: scheme.inversePrimary,
                  ),
                  SizedBox(width: 5,),
                  Text(
                    "Your current location",
                    style: TextStyle(
                      fontSize: 16,
                      color: scheme.inversePrimary,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                await getLoc();
                await _setStringParam(_localPos, "current_city");
                Navigator.pushNamed(context, '/');
              }
            ),

            for(var location in _locationsList)
              MaterialButton(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 16,
                        color: scheme.inversePrimary,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        removeCity(location);
                      },
                      icon: Icon(
                        Icons.close,
                        color: scheme.inversePrimary,
                      )
                    )
                  ],
                ),
                onPressed: () async {
                  String city = location.split(",")[0];
                  await _setStringParam(city, "current_city");
                  Navigator.pushNamed(context, '/');
                }
              )
          ],
        ),
      ),
      bottomNavigationBar: BottomMenu(currentScreen: "Locations", primaryColor: primaryColor,),
    );
  }
}
