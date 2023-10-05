import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;

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

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  late String _mapStyle;

  final LatLng _center =
      const LatLng(32.3754, 15.0925); // The center of Misurata city
  final double _zoom = 12.0; // The zoom level

  late GoogleMapController _mapController;
  final Geolocator _geolocator = Geolocator();

  // Add a new variable to store the user's coordinates.
  LatLng _userCoordinates = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/style.txt').then((string) {
      print(string);
      _mapStyle = string;
    });
    _getUserLocation();
  }

  @override
  bool get wantKeepAlive => true;
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
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _mapController.setMapStyle(_mapStyle);
        },

        zoomControlsEnabled: false, // Disable the zoom in and zoom out buttons.
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

      // Adjust the coordinates to cover the entire area of Misurata.
      if (_mapController != null &&
          _userCoordinates.latitude >= 32.3 &&
          _userCoordinates.latitude <= 32.5 &&
          _userCoordinates.longitude >= 15.0 &&
          _userCoordinates.longitude <= 15.2) {
        // Display the Misurata map.
        _mapController.moveCamera(CameraUpdate.newLatLng(_center));
      } else {
        // Display a message telling the user that they are outside of Misurata and cannot use the app.
        if (mounted) {
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
      }
    } else {
      // Request permission to access the user's location.
      await Permission.location.request();
    }
  }
}
