import 'package:astro44/data/map/map_repository.dart';
import 'package:astro44/data/report/report_repository.dart';
import 'package:get/get.dart';

class MapController extends GetxController {
  MapRepository mapRepository = MapRepository();
  ReportRepository reportRepository = ReportRepository();

  Rx<Status> status = Status.loading.obs;

  RxList<Map<String, dynamic>> report = <Map<String, dynamic>>[].obs;

  var error = ''.obs;




  getMap() async {
    try{
    var respond = await reportRepository.getReports();

    report.value = respond;
        status.value = Status.success;

    }
    catch(e){
      error.value = e.toString();
      status.value = Status.error;

    }
   

  }

   
}

enum Status { loading, success, error }
