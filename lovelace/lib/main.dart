import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lovelace/resources/authenticate_methods.dart';
import 'package:lovelace/resources/storage_methods.dart';
import 'package:lovelace/responsive/mobile_screen_layout.dart';
import 'package:lovelace/responsive/responsive_layout.dart';
import 'package:lovelace/responsive/web_screen_layout.dart';
import 'package:lovelace/screens/main/landing_screen.dart';
import 'package:lovelace/screens/user/background_auth/lock_screen.dart';
import 'package:lovelace/screens/user/initialise/init_display_name_screen.dart';
import 'package:lovelace/utils/colors.dart';
import 'package:flutter/services.dart';
import 'package:screen_capture_event/screen_capture_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final StorageMethods storageMethods = StorageMethods();
  final bool isLoggedIn =
      json.decode(await storageMethods.read('isLoggedIn') ?? 'false');
  final bool isFTL = json.decode(await storageMethods.read('isFTL') ?? 'false');

  // * Enable communication through HTTPS
  // ByteData data = await PlatformAssetBundle().load('assets/ca/ec2-cert.pem');
  // SecurityContext.defaultContext
  //     .setTrustedCertificatesBytes(data.buffer.asUint8List());

  // * Set the device orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(MyApp(isLoggedIn: isLoggedIn, isFTL: isFTL)));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final bool isFTL;
  final ResponsiveLayout _userPages = const ResponsiveLayout(
      mobileScreenLayout: MobileScreenLayout(),
      webScreenLayout: WebScreenLayout());
  const MyApp(
      {Key? key, required this.isLoggedIn, required this.isFTL, Object? data})
      : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ScreenCaptureEvent screenCaptureEvent = ScreenCaptureEvent();
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool isJailBroken = false;
  bool canMockLocation = false;
  bool isRealDevice = true;
  bool isOnExternalStorage = false;
  bool isSafeDevice = false;
  bool isDevelopmentModeEnable = false;

  @override
  void initState() {
    screenCaptureEvent.watch();
    screenCaptureEvent.preventAndroidScreenShot(true);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    screenCaptureEvent.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Future isFTL = storageMethods.read("isFTL");
    if (state == AppLifecycleState.resumed && isFTL == false ||
        state == AppLifecycleState.inactive && isFTL == false) {
      print(state);
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;
      navigator
          .push(MaterialPageRoute(builder: (context) => const LockScreen()));
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = ThemeData(
      fontFamily: 'Quicksand',
      scaffoldBackgroundColor: whiteColor,
      primaryColor: primaryColor,
    );
    Widget home;
    if (!widget.isLoggedIn) {
      home = const LandingScreen();
    } else if (widget.isFTL) {
      home = const InitDisplayNameScreen();
    } else {
      home = widget._userPages;
    }

    MaterialApp materialApp = MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'Lovelace',
        theme: themeData,
        home: home);
    return materialApp;
  }
}
