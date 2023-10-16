import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ReportController extends GetxController {
  var reports = RxList<Map<String, dynamic>>();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void onInit() {
    FirebaseMessaging.instance.subscribeToTopic('admin');
    fetchReports();
    super.onInit();
  }

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Get the user's fullname and username from the user document
    final fullname = (userSnapshot.data())?['fullname'] ?? 'N/A';
    final username = (userSnapshot.data())?['username'] ?? 'N/A';

    return {
      'fullname': fullname,
      'username': username,
    };
  }

  fetchReports() async {
    try {
      print('fetchReports called');

      var reportsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('potholes_report')
          .get();

      print('reportsSnapshot fetched');

      List<Future<Map<String, dynamic>>> reportFutures =
          reportsSnapshot.docs.map((snapshot) async {
        var data = snapshot.data();
        data['id'] = snapshot.id; // Add the document ID to the map

        // Get the user's fullname and username
        final userInfo = await getUserInfo(data['userId']);
        data['fullname'] = userInfo['fullname'];
        data['username'] = userInfo['username'];

        return data;
      }).toList();

      List<Map<String, dynamic>> fetchedReports =
          await Future.wait(reportFutures);

      print('fetchedReports: $fetchedReports');

      // Update the reports list
      reports.value = fetchedReports;
    } catch (e) {
      print('Error in fetchReports: $e');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
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

  Future<Map<String, dynamic>> approveReport(
      String userId, String reportId) async {
    // Update status of report
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('potholes_report')
        .doc(reportId)
        .update({'status': 'approved'});

    // Get user document from users collection
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Get the user's FCM token from Firestore
    String? fcmToken = (userSnapshot.data() as Map<String, dynamic>?)?['fcm'];
    if (fcmToken != null) {
      var data = {
        "to": fcmToken,
        "notification": {
          "body": 'Your report has been approved.',
          "title": 'Report Approved',
        },
      };
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final String jsonString = encoder.convert(data);

      var respond = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "key=AAAAGtuQ8Q0:APA91bHTnUy4ifPviejyRt18FgeLdBJ_k7GIu40gegveSF0qIHVMZVfw5_-7YFduyEaJwPIqzZKaoOLUbvzZqOr-sEfVcrlCkA4DDue-ha8SMz34GzQ24saUoHLCJrbe51s04pBdrQvR"
        },
        body: jsonString,
      );

      print(respond.body);

      // Get fullname and username from user document
      String fullname =
          (userSnapshot.data() as Map<String, dynamic>?)?['fullname'];
      String username =
          (userSnapshot.data() as Map<String, dynamic>?)?['username'];

      // Return the username and fullname
      return {'username': username, 'fullname': fullname};
    } else {
      // Handle error - FCM token not found
      print('Error: FCM token not found.');
      return {};
    }
  }

  Future<Map<String, dynamic>> deleteReport(
      String userId, String reportId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String? fcmToken = (userSnapshot.data() as Map<String, dynamic>?)?['fcm'];

    if (fcmToken != null) {
      var data = {
        "to": fcmToken,
        "notification": {
          "body": 'Your report has been refused.',
          "title": 'Report Refused',
        },
      };

      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final String jsonString = encoder.convert(data);

      var respond = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "key=AAAAGtuQ8Q0:APA91bHTnUy4ifPviejyRt18FgeLdBJ_k7GIu40gegveSF0qIHVMZVfw5_-7YFduyEaJwPIqzZKaoOLUbvzZqOr-sEfVcrlCkA4DDue-ha8SMz34GzQ24saUoHLCJrbe51s04pBdrQvR"
        },
        body: jsonString,
      );

      print(respond.body);

      // Get fullname and username from user document
      String fullname =
          (userSnapshot.data() as Map<String, dynamic>?)?['fullname'];
      String username =
          (userSnapshot.data() as Map<String, dynamic>?)?['username'];

      // Return the username and fullname
      return {'username': username, 'fullname': fullname};
    } else {
      // Handle error - FCM token not found
      print('Error: FCM token not found.');
      return {};
    }
  }
}
