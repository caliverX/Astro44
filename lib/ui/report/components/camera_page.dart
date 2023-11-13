import 'package:astro44/ui/report/components/reporting.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();

  // _takePicture is an asynchronous function that opens the device's camera and returns the taken picture as an XFile.
  Future<XFile?> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    return photo;
  }

  // build is the method that returns the widget tree that represents the UI of this widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Page'),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Call _takePicture to take a picture and navigate to ReportingPage to upload it.
            XFile? photo = await _takePicture();
            if (photo != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportingPage(imagePath: photo.path),
                ),
              );
            }
          },
          child: const Text('Take Picture'),
          style: ElevatedButton.styleFrom(
            primary: Colors.grey, // background color
            onPrimary: Colors.white, // text color
            elevation: 5, // button's elevation
            shape: RoundedRectangleBorder(
              // button's shape
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
