import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth pages/login_page.dart';
import 'auth pages/setup_profile.dart';
import 'components/app_theme.dart';
import 'dashboard%20pages/dashboard.dart';
import 'firebase_options.dart';
import 'navigation.dart';
import 'profile pages/profile.dart';
import 'request pages/request.dart';
import 'service pages/service.dart';
import 'splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase Console: https://console.firebase.google.com/u/0/project/budi-timebank/overview
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // emulator settings
  // if (kDebugMode) {
  //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  //   await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //   // FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BUDI Timebank',
      theme: AppTheme.themeData,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/setupProfile': (_) => const SetupProfile(),
        '/navigation': (_) => const BottomBarNavigation(valueListenable: 0),
        '/profile': (_) => const ProfilePage(isMyProfile: true),
        '/request': (_) => const RequestPage(),
        '/service': (_) => const ServicePage(),
        '/dashboard': (_) => const Dashboard(),
      },
    );
  }
}
