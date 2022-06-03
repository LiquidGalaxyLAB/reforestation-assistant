import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ras/screens/AboutScreen.dart';
import 'package:ras/screens/HomeScreen.dart';
import 'package:ras/screens/ProjectBuilder.dart';
import 'package:ras/screens/ProjectView.dart';
import 'package:ras/screens/SeedForm.dart';
import 'package:ras/screens/Settings.dart';
import 'package:ras/screens/MapBuilder.dart';
import 'package:ras/screens/SigninScreen.dart';
import 'package:ras/screens/SplashScreen.dart';
import 'package:ras/services/Database.dart';
import 'package:ras/services/LGConnection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ras/screens/MapView.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_translate/flutter_translate.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:ssh/ssh.dart';

main() async {
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en_US',
      supportedLocales: ['en_US', 'es', 'hi', 'de', 'sq']);

  runApp(LocalizedApp(delegate, MyApp()));
}

class MyApp extends StatelessWidget {
  checkLocalStorage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool? isFirst = preferences.getBool('first_time');
    if (isFirst == null || isFirst) {
      await preferences.setBool('first_time', false);
      await DatabaseService().importDB();
    }
  }

  openLogos() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String ipAddress = preferences.getString('master_ip') ?? '';
    String password = preferences.getString('master_password') ?? '';

    SSHClient client = SSHClient(
      host: ipAddress,
      port: 22,
      username: "lg",
      passwordOrKey: password,
    );

    try {
      await client.connect();
      // open logos
      await LGConnection().openDemoLogos();

      await client.disconnect();
    } catch (e) {
      print(e);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    // Fix orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Check if it is first time on the app, if it is first time, load mockdata
    checkLocalStorage();

    //openLogos
    openLogos();

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        title: 'RAS',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/': (context) => MyHomePage(),
          '/login': (context) => SignInScreen(),
          '/splash': (context) => SplashScreen(),
          '/map': (context) => MapBuilder(),
          '/settings': (context) => Settings(),
          '/project-builder': (context) => ProjectBuilder(),
          '/about': (context) => AboutScreen(),
          '/seed-form': (context) => SeedForm(),
          '/project-view': (context) => ProjectView(),
          '/map-view': (context) => MapView(),
        },
      ),
    );
  }
}
