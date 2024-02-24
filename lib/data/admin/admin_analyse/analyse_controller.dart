import 'package:astro44/data/admin/admin_analyse/pothole_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:astro44/data/admin/admin_analyse/enum.dart';

class ReportController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxString _selectedType = 'All'.obs;
  RxString _selectedStreet = 'All'.obs;
  Rx<DateCombination?> _selectedDateCombination = DateCombination.None.obs;
  RxList<PotholeReport> _allReports = RxList<PotholeReport>();
  RxList<PotholeReport> _filteredReports = RxList<PotholeReport>();
  RxList<String> _uniqueTypes = RxList<String>();
  RxList<String> _uniqueStreets = RxList<String>();

  ReportController() {
    _fetchReports();
  }

  void _fetchReports() {
    _firestore.collection('users').get().then((userQuerySnapshot) {
      for (var userDoc in userQuerySnapshot.docs) {
        userDoc.reference
            .collection('potholes_report')
            .get()
            .then((reportQuerySnapshot) {
          _allReports.addAll(
            reportQuerySnapshot.docs
                .map(
                  (doc) => PotholeReport.fromFirestore(doc),
                )
                .toList(),
          );
          _applyFilters();
          _populateUniqueValues();
        });
      }
    });
  }

  void _applyFilters() {
    _filteredReports.clear();
    for (var report in _allReports) {
      if ((_selectedType.value == 'All' ||
              report.type == _selectedType.value) &&
          (_selectedStreet.value == 'All' ||
              report.address == _selectedStreet.value) &&
          (_selectedDateCombination.value == null ||
              _matchesDateCombination(report))) {
        _filteredReports.add(report);
      }
    }
    update();
  }

  bool _matchesDateCombination(PotholeReport report) {
    switch (_selectedDateCombination.value) {
      case DateCombination.CreationAndApproval:
        return report.reportdate.isBefore(report.approvaldate) ||
            report.reportdate.isAtSameMomentAs(report.approvaldate);
      case DateCombination.CreationAndFix:
        return report.reportdate.isBefore(report.fixedDate) ||
            report.reportdate.isAtSameMomentAs(report.fixedDate);
      case DateCombination.ApprovalAndFix:
        return report.approvaldate.isBefore(report.fixedDate) ||
            report.approvaldate.isAtSameMomentAs(report.fixedDate);
      default:
        return true;
    }
  }

  void _populateUniqueValues() {
    _uniqueTypes.value =
        _allReports.map((report) => report.type).toSet().toList();
    _uniqueStreets.value =
        _allReports.map((report) => report.address).toSet().toList();
  }

  void setSelectedType(String? type) {
    _selectedType.value = type ?? 'All';
    _applyFilters();
  }

  void setSelectedStreet(String? street) {
    _selectedStreet.value = street ?? 'All';
    _applyFilters();
  }

  void setSelectedDateCombination(DateCombination? combination) {
    _selectedDateCombination.value = combination;
    _applyFilters();
  }

  // New method to calculate average fix time
  Future<int> calculateAverageFixTime() async {
    int totalDays = 0;
    int reportCount = 0;

    for (var report in _filteredReports) {
      if (report.isFixed &&
          report.approvaldate != null &&
          report.fixedDate != null) {
        DateTime createdAt = report.reportdate;
        DateTime fixedAt = report.fixedDate;
        int days = fixedAt.difference(createdAt).inDays;
        totalDays += days;
        reportCount++;
      }
    }

    int averageDays = (reportCount != 0) ? (totalDays ~/ reportCount) : 0;
    return averageDays;
  }

// Method to calculate average time between reportdate and approvaldate
  Future<int> calculateAverageTimeBetweenReportAndApproval() async {
    int totalDays = 0;
    int reportCount = 0;

    for (var report in _filteredReports) {
      if (report.approvaldate != null) {
        DateTime createdAt = report.reportdate;
        DateTime approvedAt = report.approvaldate;
        int days = approvedAt.difference(createdAt).inDays;
        totalDays += days;
        reportCount++;
      }
    }

    int averageDays = (reportCount != 0) ? (totalDays ~/ reportCount) : 0;
    return averageDays;
  }

// Method to calculate average time between approvaldate and fixedDate
  Future<int> calculateAverageTimeBetweenApprovalAndFix() async {
    int totalDays = 0;
    int reportCount = 0;

    for (var report in _filteredReports) {
      if (report.approvaldate != null && report.fixedDate != null) {
        DateTime approvedAt = report.approvaldate;
        DateTime fixedAt = report.fixedDate;
        int days = fixedAt.difference(approvedAt).inDays;
        totalDays += days;
        reportCount++;
      }
    }

    int averageDays = (reportCount != 0) ? (totalDays ~/ reportCount) : 0;
    return averageDays;
  }

  // Inside your ReportController class
  int calculateTotalReportsByTypeAndStreet() {
    int totalReports = 0;
    for (var report in _filteredReports) {
      // Increment the counter for each report that matches the selected type and street
      if (_selectedType.value == 'All' || report.type == _selectedType.value) {
        if (_selectedStreet.value == 'All' ||
            report.address == _selectedStreet.value) {
          totalReports++;
        }
      }
    }
    return totalReports;
  }

  // Expose the Rx objects directly
  RxList<PotholeReport> get allReports => _allReports;
  RxList<PotholeReport> get filteredReports => _filteredReports;
  RxList<String> get uniqueTypes => _uniqueTypes;
  RxList<String> get uniqueStreets => _uniqueStreets;
  RxString get selectedType => _selectedType;
  RxString get selectedStreet => _selectedStreet;
  Rx<DateCombination?> get selectedDateCombination => _selectedDateCombination;
}
