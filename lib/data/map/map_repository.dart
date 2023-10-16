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



      // if (_mapController != null &&
      //     _userCoordinates.latitude >= 32.3 &&
      //     _userCoordinates.latitude <= 32.5 &&
      //     _userCoordinates.longitude >= 15.0 &&
      //     _userCoordinates.longitude <= 15.2) {
      //   _mapController!.moveCamera(CameraUpdate.newLatLng(_center));
      // } else {
      //   if (mounted) {
      //     showDialog(
      //       context: context,
      //       builder: (context) => AlertDialog(
      //         title: const Text('Outside of Misurata'),
      //         content: const Text(
      //             'The Misurata Map app can only be used within the boundaries of Misurata. Please move to Misurata to use the app.'),
      //         actions: [
      //           TextButton(
      //             onPressed: () => Navigator.pop(context),
      //             child: const Text('OK'),
      //           ),
      //         ],
      //       ),
      //     );
      //   }
      // }