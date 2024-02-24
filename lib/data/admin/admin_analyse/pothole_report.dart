import 'package:cloud_firestore/cloud_firestore.dart';

class PotholeReport {
  String id;
  String address;
  String description;
  String imageUrl;
  bool isFixed;
  double latitude;
  double longitude;
  String status;
  DateTime reportdate;
  DateTime approvaldate;
  DateTime fixedDate;
  String type;

  PotholeReport({
    required this.id,
    required this.address,
    required this.description,
    required this.imageUrl,
    required this.isFixed,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.reportdate,
    required this.approvaldate,
    required this.fixedDate,
    required this.type,
  });

  factory PotholeReport.fromFirestore(DocumentSnapshot doc) {
    return PotholeReport(
      id: doc.id,
      address: doc['address'],
      description: doc['description'],
      imageUrl: doc['image_url'],
      isFixed: doc['isFixed'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      status: doc['status'],
      reportdate: (doc['reportdate'] as Timestamp).toDate(),
      approvaldate: (doc['approval_date'] as Timestamp).toDate(),
      fixedDate: (doc['fixedDate'] as Timestamp).toDate(),
      type: doc['type'],
    );
  }
}
