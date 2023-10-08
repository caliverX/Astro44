import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AdminPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
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

  Future<void> _approveReport(String userId, String reportId) async {
    // Update status of report
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('potholes_report')
        .doc(reportId)
        .update({'status': 'approved'});

    // Get user document from users collection
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(userId).get();

    // Check if user document exists and contains necessary fields
    if (userSnapshot.exists &&
        userSnapshot.data() != null &&
        userSnapshot.data() is Map<String, dynamic>) {
      // Get fullname and username from user document
      String fullname =
          (userSnapshot.data() as Map<String, dynamic>)['fullname'] ?? '';
      String username =
          (userSnapshot.data() as Map<String, dynamic>)['username'] ?? '';

      // Send notification to user
      await _showNotification('Report Approved',
          'Your report has been approved by $fullname (@$username).');
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
    String? deviceToken =
        (userSnapshot.data() as Map<String, dynamic>?)?['device_token'];

    if (deviceToken != null) {
      // Send notification to the user
      await _showNotification(
          'Report Refused', 'Your report has been refused.');
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
        print(
            '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>User document does not exist for user ID<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<: $userId');
        continue;
      }

      final userData = userSnapshot.data() as Map<String, dynamic>;
      final fullName = userData['fullname'];
      final username = userData['username'];

      if (fullName == null || username == null) {
        print(
            '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Either fullName or username is null for user ID<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<: $userId');
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
      return Text('You are not authorized to view this page.');
    }

    return ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Admin Page'),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collectionGroup('potholes_report').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
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
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          Map<String, dynamic> userData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          String fullName = userData['fullname'];
                          String username = userData['username'];

                          return ListTile(
                            title: Text(
                                '${userData['fullname']} (${userData['username']})'),
                            subtitle: Text(
                                'Report: ${reportData['description'] ?? 'No description provided.'}'),
                            leading: Image.network(
                              reportData['image_url'] ?? '',
                              width: 50,
                              height: 50,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: () {
                                    _approveReport(userId, reportId);
                                    _scaffoldMessengerKey.currentState
                                        ?.showSnackBar(SnackBar(
                                            content: Text('Report approved')));
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteReport(userId, reportId);
                                    _scaffoldMessengerKey.currentState
                                        ?.showSnackBar(SnackBar(
                                            content: Text('Report deleted')));
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
