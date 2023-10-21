import 'package:get/get.dart';

class AdminController extends GetxController {
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
    update(); // notify listeners to rebuild
  }
}
