import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro44/data/admin/admin_analyse/analyse_controller.dart'; // Your controller path
import 'package:astro44/data/admin/admin_analyse/enum.dart'; // Your enum file path

class AdminAnalyzePage extends StatelessWidget {
  final ReportController reportController = Get.put(ReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Average Fix Time Analysis'.tr),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align children to the left
                  children: [
                    // Dropdown for type
                    Obx(() => Container(
                          width: 200, // Adjust the width as needed
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: reportController.selectedType.value ?? 'All',
                            onChanged: (value) {
                              reportController.setSelectedType(value);
                            },
                            items: [...reportController.uniqueTypes, 'All']
                                .map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        )),
                    SizedBox(height: 16), // Add space between the dropdowns
                    // Dropdown for street
                    Obx(() => Container(
                          width: 200, // Adjust the width as needed
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value:
                                reportController.selectedStreet.value ?? 'All',
                            onChanged: (value) {
                              reportController.setSelectedStreet(value);
                            },
                            items: [...reportController.uniqueStreets, 'All']
                                .map((street) {
                              return DropdownMenuItem<String>(
                                value: street,
                                child: Text(street),
                              );
                            }).toList(),
                          ),
                        )),
                  ],
                ),
              ),
              // Button to calculate average fix time
              ElevatedButton(
                onPressed: () async {
                  int averageDays =
                      await reportController.calculateAverageFixTime();
                  showResultAlert(context, 'Average Fix Time'.tr, averageDays);
                },
                child: Text('Calculate Average Fix Time'.tr),
              ),
              // Button to calculate average time between reportdate and approvaldate
              ElevatedButton(
                onPressed: () async {
                  int averageDays = await reportController
                      .calculateAverageTimeBetweenReportAndApproval();
                  showResultAlert(
                      context, 'Average Approval Time'.tr, averageDays);
                },
                child: Text('Calculate Average Approval Time'.tr),
              ),
              // Button to calculate average time between approvaldate and fixedDate
              ElevatedButton(
                onPressed: () async {
                  int averageDays = await reportController
                      .calculateAverageTimeBetweenApprovalAndFix();
                  showResultAlert(
                      context, 'Average Fix Time After Approval'.tr, averageDays);
                },
                child: Text('Calculate Average Fix Time After Approval'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to show the result in an alert dialog
  void showResultAlert(BuildContext context, String title, int averageDays) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text('The average number of days is $averageDays days.'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'.tr),
            ),
          ],
        );
      },
    );
  }

  String describeEnum(Object e) {
    return e.toString().split('.').last;
  }
}
