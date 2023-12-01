import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('notifications')
          .snapshots(includeMetadataChanges: true),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          final fixedNotifications =
              documents.where((doc) => doc['isfixed'] == true).toList();
          final unfixedNotifications =
              documents.where((doc) => doc['isfixed'] == false).toList();

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                 colors: [Colors.grey,Colors.grey],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  // Fixed notifications
                   Text(
                    'Fixed Potholes'.tr,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...fixedNotifications
                      .map((doc) => Card(
                            color: Colors.blue,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              title: Text(
                                doc['message'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                DateFormat('yyyy-MM-dd – kk:mm')
                                    .format(doc['timestamp'].toDate()),
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(doc['message']),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Image.network(doc['image_url']),
                                          Text(
                                            DateFormat('yyyy-MM-dd – kk:mm')
                                                .format(
                                                    doc['timestamp'].toDate()),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ))
                      .expand((card) => [card, const Divider()])
                      .toList(),
                  // Unfixed notifications
                   Text(
                    'Unfixed Potholes'.tr,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...unfixedNotifications
                      .map((doc) => Card(
                            color: Colors.blue,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              title: Text(
                                doc['message'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                DateFormat('yyyy-MM-dd – kk:mm')
                                    .format(doc['timestamp'].toDate()),
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(doc['message']),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Image.network(doc['image_url']),
                                          Text(
                                            DateFormat('yyyy-MM-dd – kk:mm')
                                                .format(
                                                    doc['timestamp'].toDate()),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ))
                      .expand((card) => [card, const Divider()])
                      .toList(),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Error: ${snapshot.error}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
          child:  Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'There is nothing to show here.'.tr  ,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
