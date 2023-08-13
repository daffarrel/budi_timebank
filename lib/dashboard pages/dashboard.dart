import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../custom widgets/custom_headline.dart';
import '../components/app_theme.dart';
import '../rate pages/rate_given_page.dart';
import '../rate pages/rate_received_page.dart';
import '../transactions pages/transaction.dart';
import 'request_dashboard_content.dart';
import 'service_dashboard_content.dart';
import 'shortcut_action_card.dart';
import 'time_balance_card.dart';
import 'x_dashboard_card.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

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
