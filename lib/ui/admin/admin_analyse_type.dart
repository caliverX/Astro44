import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro44/data/admin/admin_analyse/analyse_controller.dart';

class AdminAnalyze extends StatefulWidget {
  @override
  State<AdminAnalyze> createState() => _AdminAnalyzeState();
}

class _AdminAnalyzeState extends State<AdminAnalyze> {
  final ReportController reportController = Get.put(ReportController());

  // Method to calculate the total number of reports by type and street
  void calculateTotalReports() {
    // Call the method from the controller to get the total number of reports
    int totalReports = reportController.calculateTotalReportsByTypeAndStreet();
    // Display the result using a snackbar
    Get.snackbar(
      'Total Reports'.tr,
      'There are a total of $totalReports reports for the selected type and street.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Type and Street'.tr),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown for type
              Obx(() => DropdownButton<String>(
                    value: reportController.selectedType.value ?? 'All',
                    onChanged: (value) {
                      reportController.setSelectedType(value);
                    },
                    items: [...reportController.uniqueTypes, 'All'].map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  )),
              SizedBox(height:  16), // Space between dropdowns
              // Dropdown for street
              Obx(() => DropdownButton<String>(
                    value: reportController.selectedStreet.value ?? 'All',
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
                  )),
              SizedBox(height:  16),
              ElevatedButton(
                onPressed: calculateTotalReports,
                child: Text('Calculate Total Reports'.tr),
              ),
              SizedBox(height:  16),
              ElevatedButton(
                onPressed: () {
                  // Clear all filters
                  reportController.setSelectedType('All');
                  reportController.setSelectedStreet('All');
                },
                child: Text('Clear Filters'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
