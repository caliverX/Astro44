import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapRepository {
  Future<LatLng> getUserLocation() async {
    LatLng userCoordinates = const LatLng(0, 0);

    if (await Permission.location.isGranted) {
      Position position = await Geolocator.getCurrentPosition();
      userCoordinates = LatLng(position.latitude, position.longitude);

    } else {
      await Permission.location.request();
    }
    return userCoordinates;
  }
}



 