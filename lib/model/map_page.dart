import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  static Future<MapPage> create() async {
    // Load the map data
    await Future.delayed(const Duration(seconds: 1));

    // Create and return a MapPage widget
    return const MapPage();
  }

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LatLng _center =
      const LatLng(32.3947, 15.0947); // The center of Misurata city
  final double _zoom = 12.0; // The zoom level

  late GoogleMapController _mapController;
  final Geolocator _geolocator = Geolocator();

  // Add a new variable to store the user's coordinates.
  LatLng _userCoordinates = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Misurata Map',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: GoogleMap(
        zoomControlsEnabled: false, // Disable the zoom in and zoom out buttons.
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: _zoom,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  // Get the user's current location and display the Misurata map if the user is within the boundaries of Misurata.
  void _getUserLocation() async {
    // Check if the user has granted permission to access their location.
    if (await Permission.location.isGranted) {
      // Get the user's current location.
      Position position = await Geolocator.getCurrentPosition();

      // Store the user's coordinates in the variable you created in step 1.
      _userCoordinates = LatLng(position.latitude, position.longitude);

      // Check if the user's coordinates are within the boundaries of Misurata.
      if (_userCoordinates.latitude >= 32.3947 &&
          _userCoordinates.latitude <= 32.4052 &&
          _userCoordinates.longitude >= 15.0947 &&
          _userCoordinates.longitude <= 15.1052) {
        // Display the Misurata map.
        _mapController.moveCamera(CameraUpdate.newLatLng(_center));
      } else {
        // Display a message telling the user that they are outside of Misurata and cannot use the app.
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Outside of Misurata'),
            content: const Text(
                'The Misurata Map app can only be used within the boundaries of Misurata. Please move to Misurata to use the app.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // Request permission to access the user's location.
      await Permission.location.request();
    }
  }
}
