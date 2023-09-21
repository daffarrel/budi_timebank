import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../custom widgets/custom_card_service_request.dart';
import '../db_helpers/client_service_request.dart';
import '../model/service_request.dart';
import 'job_details.dart';

class AvailableServices extends StatefulWidget {
  const AvailableServices({Key? key}) : super(key: key);

  @override
  State<AvailableServices> createState() => _AvailableServicesState();
}

class _AvailableServicesState extends State<AvailableServices> {
  late String user;

  Future<List<ServiceRequest>> getinstance() async {
    user = FirebaseAuth.instance.currentUser!.uid;

    var documents = await ClientServiceRequest.getMyAvailableServices();

    return documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return Future(() => setState(() {}));
        },
        child: FutureBuilder(
            future: getinstance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                    child: Text('Error getting data. Please try again later'));
              }

              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      'All available jobs based on category will be listed here...\nSo far there are no available job...',
                      textAlign: TextAlign.center,
                    ),
                    Container(
                        //padding: EdgeInsets.only(top: 5),
                        height: MediaQuery.of(context).size.height / 4.6,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 0),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Image.asset(
                            'asset/available_job.png',
                            height: MediaQuery.of(context).size.height / 3,
                          ),
                        )),
                  ],
                );
              }
              final jobData = snapshot.data as List<ServiceRequest>;
              return ListView.builder(
                itemCount: jobData.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => JobDetails(
                                  requestId: jobData[index].id!, user: user)))
                          .then((value) => getinstance());
                    },
                    child: CustomCardServiceRequest(
                      category: jobData[index].category,
                      location: jobData[index].location,
                      date: jobData[index].date,
                      status: jobData[index].status,
                      requestorId: jobData[index].requestorId,
                      title: jobData[index].title,
                      rate: jobData[index].rate.toString(),
                    ),
                  );
                },
              );
            }),
      ),
      // FIXME: Search disabled sbb belum migrate
    );
  }
}
