import 'package:cloud_firestore/cloud_firestore.dart';

class ReportRepository {
  getReports() async {
    var snapshot = await FirebaseFirestore.instance
        .collectionGroup('potholes_report')
        .get();

List<Map<String, dynamic>> maps = snapshot.docs.map((snapshot) {
  var data = snapshot.data();
  data['id'] = snapshot.id;  // Add the document ID to the map
  return data;
}).toList();

    return maps;
  }
}
