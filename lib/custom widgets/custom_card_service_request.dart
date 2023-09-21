import 'package:flutter/material.dart';

import '../db_helpers/client_user.dart';
import '../my_extensions/extension_datetime.dart';
import '../my_extensions/extension_string.dart';
import '../model/service_request.dart';
import '../components/app_theme.dart';

class CustomCardServiceRequest extends StatelessWidget {
  final String requestorId;
  final ServiceRequestStatus status;
  final String title; //details
  final String rate;
  final DateTime date;
  final Location location;
  final String category;
  final bool isHaveApplicants;

  const CustomCardServiceRequest({
    super.key,
    required this.requestorId,
    required this.title,
    required this.rate,
    required this.status,
    required this.date,
    required this.location,
    required this.category,
    this.isHaveApplicants = false,
  });

  changeColor(ServiceRequestStatus status, bool haveApplicant) {
    return switch (status) {
      ServiceRequestStatus.pending => haveApplicant
          ? const Color.fromARGB(255, 0, 146, 143) // for pending request
          : const Color.fromARGB(255, 131, 194, 30), // for available request
      ServiceRequestStatus.accepted => const Color.fromARGB(255, 199, 202, 11),
      ServiceRequestStatus.ongoing => const Color.fromARGB(255, 213, 159, 15),
      ServiceRequestStatus.completedVerified =>
        const Color.fromARGB(255, 89, 175, 89),
      ServiceRequestStatus.completed =>
        AppTheme.themeData2.secondaryHeaderColor,
      _ => const Color.fromARGB(255, 127, 124, 139)
    };
  }

  String changeStatus(ServiceRequestStatus status, bool haveApplicant) {
    return switch (status) {
      ServiceRequestStatus.pending => haveApplicant ? 'Pending' : 'Available',
      ServiceRequestStatus.completedVerified => 'Completed',
      ServiceRequestStatus.completed => 'Completed (Pending Verification)',
      _ => status.name.titleCase()
    };
  }

  getRequestorName() async {
    var user = await ClientUser.getUserProfileById(requestorId);
    return user.name.titleCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: Card(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 4,
                        fit: FlexFit.tight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.work_outline_rounded),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(title.toString().capitalize(),
                                      //overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)
                                      //     Theme.of(context).textTheme.headline1,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(category,
                                style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Container(
                            decoration: BoxDecoration(
                                color: changeColor(status, isHaveApplicants),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                changeStatus(status, isHaveApplicants),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                      ),
                    ],
                  ),
                  const Divider(),
                  FutureBuilder(
                      future: getRequestorName(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.connectionState == ConnectionState.waiting
                              ? 'Loading...'
                              : snapshot.data.toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      }),
                  const SizedBox(height: 10),
                  Text(location.address,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    '\$ $rate Time/hour',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(date.formatDate(), style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
