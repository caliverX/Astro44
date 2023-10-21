import 'dart:io';
import 'dart:typed_data';
import 'package:astro44/ui/master/master_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
            title: const Text('success'),
            content: const Text('the report has been sent.'),
            actions: <Widget>[
              TextButton(
                child: const Text('ok'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MasterPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          );
        },
      );

      String uui = FirebaseAuth.instance.currentUser!.uid;
      print(uui);

      // Call the new notification method here
      sendNotification(
          'New Pothole Report', 'A new pothole report has been submitted');
    }
  }

// Define the new method
  Future<void> sendNotification(String subject, String title) async {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    String toParams = "/topics/" + 'admin'; // Change 'yourTopicName' to 'admin'

    final data = {
      "notification": {"body": subject, "title": title},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "sound": 'default',
        "screen": "admin",
      },
      "to": "${toParams}"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAGtuQ8Q0:APA91bHTnUy4ifPviejyRt18FgeLdBJ_k7GIu40gegveSF0qIHVMZVfw5_-7YFduyEaJwPIqzZKaoOLUbvzZqOr-sEfVcrlCkA4DDue-ha8SMz34GzQ24saUoHLCJrbe51s04pBdrQvR' // Replace 'key' with your Firebase Cloud Messaging key
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);
    if (response.statusCode == 200) {
      // on success do
      print("true");
    } else {
      // on failure do
      print("false");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporting Page'),
      ),
      body: Center(
        child: isUploading
            ? const CircularProgressIndicator()
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
                    child: const Text('Save Picture'),
                  ),
                ],
              ),
      ),
    );
  }
}
