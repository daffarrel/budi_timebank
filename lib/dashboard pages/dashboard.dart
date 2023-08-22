import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../custom widgets/custom_headline.dart';
import '../components/app_theme.dart';
import '../db_helpers/client_user.dart';
import '../rate pages/rate_given_page.dart';
import '../rate pages/rate_received_page.dart';
import '../transactions pages/transaction.dart';
import 'request_dashboard_content.dart';
import 'service_dashboard_content.dart';
import 'shortcut_action_card.dart';
import 'time_balance_card.dart';
import 'x_dashboard_card.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    setupFcmNotification();
  }

  Future<void> setupFcmNotification() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }

    // Store the messaging token in the database
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      debugPrint('FCM Token: $token');
      await ClientUser.saveFcmToken(token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TimeBalanceCard(),
            if (kDebugMode)
              ElevatedButton(
                onPressed: () async {
                  final fcmToken = await FirebaseMessaging.instance.getToken();

                  debugPrint('fcmToken is $fcmToken');
                },
                child: const Text('Get firebase messaging token'),
              ),
            if (kDebugMode)
              ElevatedButton(
                onPressed: () async {
                  final HttpsCallable sendNotification = FirebaseFunctions
                      .instance
                      .httpsCallable('sendNotification');
                  try {
                    final result =
                        await sendNotification.call(<String, dynamic>{
                      'receiverUid': 'HvTOQfSLvFOegnpXZjf5GFsomun2',
                      'title': 'Notification Title',
                      'content': 'Notification Content',
                    });

                    debugPrint(
                        'Notification sent successfully: ${result.data}');
                  } catch (error) {
                    debugPrint('Error sending notification: $error');
                  }
                },
                child: const Text('Send notification'),
              ),
            Row(
              children: [
                Expanded(
                  child: XDashboardCard(
                    title: "Your Request",
                    borderColor: AppTheme.themeData.primaryColor,
                    navBarIndex: 1,
                    content: const RequestDashboardContent(),
                  ),
                ),
                Expanded(
                  child: XDashboardCard(
                    title: "Your Service",
                    borderColor: AppTheme.themeData.secondaryHeaderColor,
                    navBarIndex: 2,
                    content: const ServiceDashboardContent(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: CustomHeadline('Shortcuts'),
            ),
            Expanded(
              child: Row(
                children: [
                  ShortcutActionCard(
                    title: 'View Transaction History',
                    description: 'Keep your balance in check',
                    icon: Icons.receipt_long,
                    backgroundColor: AppTheme.themeData.primaryColor,
                    foregroundColor: Colors.white,
                    destination: MaterialPageRoute(
                        builder: (context) => const TransactionPage()),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ShortcutActionCard(
                          title: 'Rate Given',
                          description: 'Give feedback to other people',
                          icon: Icons.rate_review,
                          foregroundColor: AppTheme.themeData.primaryColor,
                          borderColor: AppTheme.themeData.primaryColor,
                          destination: MaterialPageRoute(
                              builder: (context) => const RateGivenPage()),
                        ),
                        ShortcutActionCard(
                          title: 'Received Rating',
                          description: 'See what other people thinks about you',
                          icon: Icons.thumbs_up_down,
                          foregroundColor: Colors.white,
                          backgroundColor:
                              AppTheme.themeData.secondaryHeaderColor,
                          destination: MaterialPageRoute(
                              builder: (context) => const RateReceivedPage()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
