import 'package:astro44/ui/shared_components/componets/square.dart';
import 'package:astro44/ui/report/components/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title:  Text('Report Page'.tr),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text('select the issue that you want to report it !:'.tr,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: const EdgeInsets.all(10),
                children: [
                  Card(
                    child: SquareTitle(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CameraPage()));
                      },
                      imagePath: 'assets/images/download.png',
                    ),
                  ),
                  Card(
                    child: SquareTitle(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CameraPage()));
                      },
                      imagePath:
                          'assets/images/49-496403_streetlight-clipart-electric-post-electricity-png-download.png',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your code here.
        },
        tooltip: 'Report an issue',
        child: const Icon(Icons.report),
      ),
    );
  }
}
