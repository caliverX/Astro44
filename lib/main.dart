import 'package:astro44/localization/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:astro44/ui/check/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:astro44/data/auth/servieces/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setLanguage(Locale locale) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('language_code', locale.languageCode);
  prefs.setString('country_code', locale.countryCode ?? 'US');

  Get.updateLocale(locale);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      _showNotification(
          message.notification!.title!, message.notification!.body!);
    }
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString('language_code') ?? 'en';
  String countryCode = prefs.getString('country_code') ?? 'US';

  // Get the system locale
  Locale systemLocale = WidgetsBinding.instance.window.locale;

  // Check if the system language is Arabic
  if (systemLocale.languageCode == 'ar') {
    // Set the app language to Arabic
    languageCode = 'ar';
    countryCode = 'SA';
  }

  runApp(
    GetMaterialApp(
      translations: Messages(),
      locale: Locale(languageCode, countryCode),
      fallbackLocale: const Locale('ar', 'SA'),
      debugShowCheckedModeBanner: false,
      home: AuthCheck(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Messages(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('ar', 'SA'),
      debugShowCheckedModeBanner: false,
      home: AuthCheck(),
    );
  }
}

int id = 1213;

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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.show(
    id++,
    title,
    body,
    platformChannelSpecifics,
    payload: 'notification',
  );
}
