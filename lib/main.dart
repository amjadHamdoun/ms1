import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mstand/language_constants.dart';
import 'is_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();

  // await FirebaseMessaging.instance.setAutoInitEnabled(true);
  AwesomeNotifications().initialize(
    'resource://drawable/res_bblogo',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notification',
        channelDescription: 'Basic Chaneel Notification',
        defaultColor: Colors.red,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        ledColor: Colors.red,
      ),
      NotificationChannel(
        channelKey: 'scheduld_channel',
        channelName: 'Scheduld Notification',
        channelDescription: 'Scheduld Chaneel Notification',
        defaultColor: Colors.blue,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        ledColor: Colors.red,
        // locked: true,
        soundSource: 'resource://raw/res_notisound',
      ),
    ],
  );
  tz.initializeTimeZones();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await FlutterDownloader.initialize(
    debug: true,
  );

  runApp(const MyApp()); // MyApp - OpenAdmin
}

class MyApp extends StatefulWidget {
  const MyApp({key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => setLocale(locale));
    super.didChangeDependencies();
  }

  void addSection() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> mySections = [
      'العقود',
      'وزارة التجارة',
      'شهادة الانتساب',
      'بطاقات الشخصية العمال',
    ];
    final List<String>? sections = prefs.getStringList('mySections');

    if (sections == null) {
      await prefs.setStringList('mySections', mySections);
    }
  }

  @override
  void initState() {
    super.initState();
    addSection();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'حقيبة الاعمال',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      home: const IsUserLogin(),
    );
  }
}
