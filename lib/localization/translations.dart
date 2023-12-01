import 'package:get/get.dart';
import 'package:astro44/localization/en.dart'; // Import your English language file
import 'package:astro44/localization/ar.dart'; // Import your Arabic language file

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': En().messages, // Use the messages map from the English language file
        'ar_SA': Ar().messages, // Use the messages map from the Arabic language file
      };
}
