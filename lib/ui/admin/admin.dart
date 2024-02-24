import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    _subscribeToAdminTopic();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> _subscribeToAdminTopic() async {
    try {
      await _firebaseMessaging.subscribeToTopic('admin');
      print('Subscribed to admin topic');
    } catch (e) {
      print('Failed to subscribe to admin topic: $e');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    // Define the vibration pattern
    final vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0; // Start immediately
    vibrationPattern[1] = 100; // Vibrate for  100 milliseconds
    vibrationPattern[2] = 1000; // Wait for  1 second
    vibrationPattern[3] = 500; // Vibrate for  500 milliseconds

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
      enableVibration: true, // Enable vibration
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'notification',
    );
  }

  Future<void> sendNotificationToUser(
      String userToken, String title, String body) async {
    // Construct the notification payload
    final data = {
      "notification": {
        "title": title,
        "body": body,
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "sound": 'default',
        "screen": "admin",
      },
      "to": userToken, // Send the notification to the user's FCM token
    };

    // Prepare the request headers
    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAGtuQ8Q0:APA91bHTnUy4ifPviejyRt18FgeLdBJ_k7GIu40gegveSF0qIHVMZVfw5_-7YFduyEaJwPIqzZKaoOLUbvzZqOr-sEfVcrlCkA4DDue-ha8SMz34GzQ24saUoHLCJrbe51s04pBdrQvR', // Your Firebase Cloud Messaging key
    };

    // Send the notification
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      body: json.encode(data),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // On success
      print("Notification sent successfully");
    } else {
      // On failure
      print("Failed to send notification");
    }
  }

  Future<void> _approveReport(String userId, String reportId) async {
    // Get report document from 'potholes_report' subcollection
    DocumentSnapshot reportSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('potholes_report')
        .doc(reportId)
        .get();

    // Check if report document exists and contains necessary fields
    if (!reportSnapshot.exists ||
        reportSnapshot.data() == null ||
        reportSnapshot.data() is! Map<String, dynamic>) {
      print('Error: Report document or necessary fields not found.');
      return;
    }

    Map<String, dynamic> reportData =
        reportSnapshot.data() as Map<String, dynamic>;

    // Update status of report
    await reportSnapshot.reference.update({
      'status': 'approved',
      'approval_date': FieldValue.serverTimestamp(), // Add this line
    });

    // Get user document from users collection
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(userId).get();

    // Check if user document exists and contains necessary fields
    if (userSnapshot.exists &&
        userSnapshot.data() != null &&
        userSnapshot.data() is Map<String, dynamic>) {
      // Retrieve the user's FCM token from Firestore
      String? userToken = userSnapshot.get(
          'fcm'); // Assuming 'fcm_token' is the field name for the FCM token

      if (userToken == null) {
        print("User FCM token not found");
        return;
      }

      // Get fullname and username from user document
      String fullname =
          (userSnapshot.data() as Map<String, dynamic>)['fullname'] ?? '';
      String username =
          (userSnapshot.data() as Map<String, dynamic>)['username'] ?? '';

      // Send notification to user using the userToken
      // Note: You'll need to implement the actual notification sending logic here
      await sendNotificationToUser(
          userToken, 'Report Approved'.tr, 'Your report has been approved.'.tr);

      // Send notification to user in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'reportId': reportId,
        'type': 'approve',
        'message': 'Your report has been approved.'.tr,
        'image_url':
            reportData['image_url'], // add image_url to notification data
        'description':
            reportData['description'], // add description to notification data
        'timestamp': FieldValue.serverTimestamp(),
        'isfixed': false,
      });
    } else {
      // Handle error - user document or necessary fields not found
      print('Error: User document or necessary fields not found.');
    }
  }

  Future<void> _deleteReport(String userId, String reportId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('potholes_report')
        .doc(reportId)
        .delete();

// Get the user's device token from Firestore
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(userId).get();
// Check if user document exists and contains necessary fields
    if (userSnapshot.exists &&
        userSnapshot.data() != null &&
        userSnapshot.data() is Map<String, dynamic>) {
      // Retrieve the user's FCM token
      String? userToken = userSnapshot.get('fcm');

      if (userToken != null) {
        // Send notification to user using the userToken
        await sendNotificationToUser(
            userToken, 'Report Refused'.tr, 'Your report has been refused.'.tr);
      } else {
        print("User FCM token not found");
      }

      // Get fullname and username from user document
      String fullname =
          (userSnapshot.data() as Map<String, dynamic>)['fullname'] ?? '';
      String username =
          (userSnapshot.data() as Map<String, dynamic>)['username'] ?? '';

      await _showNotification('Report Refused'.tr,
          'Your report has been refused. $fullname (@$username).'.tr);
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'reportId': reportId,
        'type': 'delete',
        'message': 'Your report has been delete it.'.tr,
        'timestamp': FieldValue.serverTimestamp(),
        'isfixed': true,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getReportsData() async {
// Get the reports from the 'reports' collection
    QuerySnapshot<Map<String, dynamic>> reportsSnapshot =
        await _firestore.collection('reports').get();

    final reports = reportsSnapshot.docs;
    List<Map<String, dynamic>> reportDataList = [];

// Iterate over the reports and get the user's data for each report
    for (final report in reports) {
      final userId = report.reference.parent.parent!.id;

      // Get the user's document from the 'users' collection
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (!userSnapshot.exists) {
        continue;
      }

      final userData = userSnapshot.data() as Map<String, dynamic>;
      final fullName = userData['fullname'];
      final username = userData['username'];

      if (fullName == null || username == null) {
        continue;
      }

      // Add the report data and user data to the list
      reportDataList.add({
        'reportData': report.data(),
        'fullname': fullName,
        'username': username,
      });
    }

    return reportDataList;
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null || user.email != 'el.rajoubi79@gmail.com') {
      return const Text('You are not authorized to view this page.');
    }

    return ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Admin Page'.tr),
              backgroundColor: Colors.blue,
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collectionGroup('potholes_report').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final reports = snapshot.data!.docs
                    .where((report) =>
                        (report.data() as Map<String, dynamic>)['image_url'] !=
                            null &&
                        (report.data() as Map<String, dynamic>)['status'] !=
                            'approved')
                    .toList();
                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final reportData = report.data() as Map<String, dynamic>;
                    final reportId = report.id;
                    final userId = report.reference.parent.parent!.id;

                    // Fetch the user data before building the list
                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('users').doc(userId).get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          var x = snapshot.data!.data();

                          Map<String, dynamic> userData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          String fullName = userData['fullname'];
                          String username = userData['username'];

                          if (username == null) {
                            return Text(
                                'Error: User document or necessary fields not found.'
                                    .tr);
                          }

                          return ListTile(
                            title: Text(
                                '${userData['fullname']} (${userData['username']})'),
                            subtitle: Text(
                                'Report: ${reportData['description'] ?? 'No description provided.'}'),
                            leading: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Image'.tr),
                                      content: Image.network(
                                          reportData['image_url']),
                                      actions: [
                                        TextButton(
                                          child: Text('OK'.tr),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Image.network(
                                reportData['image_url'] ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    _approveReport(userId, reportId);
                                    _scaffoldMessengerKey.currentState
                                        ?.showSnackBar(SnackBar(
                                            content:
                                                Text('Report approved'.tr)));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteReport(userId, reportId);
                                    _scaffoldMessengerKey.currentState
                                        ?.showSnackBar(SnackBar(
                                            content:
                                                Text('Report deleted'.tr)));
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            )));
  }
}
