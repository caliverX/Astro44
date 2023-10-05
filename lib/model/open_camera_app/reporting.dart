import 'dart:io';
import 'dart:typed_data';
import 'package:astro44/ui/pages/master_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportingPage extends StatefulWidget {
  final String imagePath;

  const ReportingPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  _ReportingPageState createState() => _ReportingPageState();
}

class _ReportingPageState extends State<ReportingPage> {
  bool isUploading = false;
  String description = '';

  Future<String?> _takePicture() async {
    setState(() {
      isUploading = true;
    });

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('potholes_reports/${DateTime.now()}.jpg');

    try {
      List<int> imageBytes = await File(widget.imagePath).readAsBytes();
      Uint8List uint8ImageBytes = Uint8List.fromList(imageBytes);
      UploadTask uploadTask = ref.putData(uint8ImageBytes);
      TaskSnapshot taskSnapshot;

      try {
        taskSnapshot = await uploadTask;
      } on FirebaseException catch (e) {
        print('error uploading image: $e');
        return null;
      }

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double lat = position.latitude;
      double lon = position.longitude;

      String userId = FirebaseAuth.instance.currentUser!.uid;
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      users.doc(userId).collection('potholes_report').add({
        'image_url': downloadUrl,
        'latitude': lat,
        'longitude': lon,
        'description': description,
        'status': 'still not approved',
      });

      return downloadUrl;
    } catch (e) {
      print('error: $e');
      return null;
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void _saveImageToFirestore() async {
    String? imageUrl = await _takePicture();

    if (imageUrl != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('success'),
            content: Text('the report has been sent.'),
            actions: <Widget>[
              TextButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeNavigationBar()),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporting Page'),
      ),
      body: Center(
        child: isUploading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: _saveImageToFirestore,
                    child: Text('Save Picture'),
                  ),
                ],
              ),
      ),
    );
  }
}
