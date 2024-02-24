import 'package:astro44/ui/shared_components/componets/square.dart';
import 'package:astro44/ui/report/components/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

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
        title: Text('Report Page'.tr),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('select the issue that you want to report it !:'.tr,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: 3, // Adjust based on your actual number of items
                itemBuilder: (ctx, i) {
                  switch (i) {
                    case 0:
                      return Column(
                        children: [
                          Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CameraPage(type: 'pothole')),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/images/download.png',
                                      fit: BoxFit.cover),
                                ],
                              ),
                            ),
                          ),
                          Text('Pothole'.tr, style: TextStyle(fontSize: 14)),
                        ],
                      );
                    case 1:
                      return Column(
                        children: [
                          Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CameraPage(type: 'other')),
                                );
                              },
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset('assets/images/152529.png',
                                      fit: BoxFit.cover),
                                ],
                              ),
                            ),
                          ),
                          Text('Other Issues'.tr,
                              style: TextStyle(fontSize: 14)),
                        ],
                      );
                    case 2:
                      return Column(
                        children: [
                          Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CameraPage(type: 'streetlight')),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                      'assets/images/49-496403_streetlight-clipart-electric-post-electricity-png-download.png',
                                      fit: BoxFit.cover),
                                ],
                              ),
                            ),
                          ),
                          Text('Streetlight'.tr,
                              style: TextStyle(fontSize: 14)),
                        ],
                      );
                    default:
                      return Container();
                  }
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 0.0,
                  mainAxisSpacing: 5,
                  mainAxisExtent: 182, // Adjust based on your needs
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
