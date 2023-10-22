
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  final List<Map<String, dynamic>> markers;
  const MapPage({Key? key, required this.markers}) : super(key: key);
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    buildMarkers();
    super.initState();
  }

  final LatLng _center = const LatLng(32.3754, 15.0925);
  final double _zoom = 12.0;
  final Set<Marker> _markers = {};

  buildMarkers() {
    for (var data in widget.markers) {
      final latitude = data['latitude'];
      final longitude = data['longitude'];
      final description = data['description'];
      final imageUrl = data['image_url'];
      final marker = Marker(
        markerId: MarkerId(data['id']),
        position: LatLng(latitude, longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      Text(description),
                      Image.network(imageUrl),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      _markers.add(marker);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:  GoogleMap(
      zoomControlsEnabled: false,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: _zoom,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: _markers,
    ));
  }
}
