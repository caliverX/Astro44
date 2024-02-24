import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminReportisFixedController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<DocumentSnapshot> documents = RxList<DocumentSnapshot>();
  final RxList<DocumentSnapshot> filteredDocuments = RxList<DocumentSnapshot>();

  Future<void> updateDocumentsAndSendNotification(
      String userId, String notificationId, String potholeId) async {
    // Get the references to the documents
    DocumentReference notificationDocRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId);
    DocumentReference potholeDocRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('potholes_report')
        .doc(potholeId);

    // Update the documents
    await notificationDocRef.update({'isfixed': true});
    await potholeDocRef
        .update({'isFixed': true, 'fixedDate': FieldValue.serverTimestamp()});

    // Fetch the user's FCM token from Firestore
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(userId).get();

    // Check if user document exists and contains necessary fields
    if (userSnapshot.exists &&
        userSnapshot.data() != null &&
        userSnapshot.data() is Map<String, dynamic>) {
      // Retrieve the user's FCM token from Firestore
      String? userToken =
          userSnapshot.get('fcm'); // Ensure 'fcm' matches your field name

      if (userToken == null) {
        print("User FCM token not found");
        return;
      }

      // Send a notification to the user
      await sendNotificationToUser(userToken, 'Report Approved',
          'Your report has been fixed by the government');
    }
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

  @override
  void onInit() {
    super.onInit();
    _firestore.collectionGroup('notifications').snapshots().listen((snapshot) {
      documents.value = snapshot.docs;
      filteredDocuments.value =
          snapshot.docs.where((doc) => doc['isfixed'] == false).toList();
    });
  }
}

class AdminReportisFixed extends StatelessWidget {
  AdminReportisFixed({Key? key}) : super(key: key);

  final AdminReportisFixedController controller =
      Get.put(AdminReportisFixedController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() {
      if (controller.filteredDocuments.isEmpty) {
        return Center(
          child: Text(
            'There is nothing to show here.'.tr,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
        );
      }
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey, Colors.grey],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: controller.filteredDocuments
                .map(
                  (doc) => Card(
                    child: ListTile(
                      title: Text(
                        doc['message'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        doc['description'],
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      leading: Image.network(
                        doc['image_url'],
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () async {
                          final userId = doc.reference.parent.parent!.id;
                          final notificationId = doc.id;
                          final potholeId = doc[
                              'reportId']; // Assuming each notification document has a 'potholeId' field

                          await controller.updateDocumentsAndSendNotification(
                              userId, notificationId, potholeId);
                        },
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Column(
                                children: [
                                  Image.network(doc['image_url']),
                                  Text(doc['description']),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
                .expand((card) => [card, const Divider()])
                .toList(),
          ),
        ),
      );
    }));
  }
}
