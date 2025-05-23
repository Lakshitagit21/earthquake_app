import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart' as gc;

String getFormattedDateTime(num dt, [String pattern = 'yyyy-MM-dd']) =>
    DateFormat(pattern).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt()));

void showMsg(BuildContext context, String msg) =>
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

Future<String?> getCurrentCity(double lat, double long) async {
  try {
    final placemarkList =
    await gc.placemarkFromCoordinates(lat, long);
    if (placemarkList.isNotEmpty) {
      final placemark = placemarkList.first;
      return placemark.locality;
    }
    return  null;
  } catch (error) {
    return null;
  }
}

Color getAlertColor(String color) {
  return switch (color) {
    'green' => Colors.green,
    'yellow' => Colors.yellow,
    'orange' => Colors.orange,
    _ => Colors.red,
  };
}