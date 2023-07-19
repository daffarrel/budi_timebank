import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../custom widgets/custom_card_service_request.dart';
import '../db_helpers/client_service_request.dart';
import '../model/service_request.dart';
import 'job_details.dart';

class CompletedServices extends StatefulWidget {
  const CompletedServices({Key? key}) : super(key: key);

  @override
  State<CompletedServices> createState() => _CompletedServicesState();
}

class _CompletedServicesState extends State<CompletedServices> {
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  late bool isLoad;
  late List<ServiceRequest> data;
  bool isRequest = true;

  @override
  void initState() {
    super.initState();
    isLoad = true;
    _getInstance();
  }

  Future _getInstance() async {
    setState(() {
      isLoad = true;
    });

    var completedServices = await ClientServiceRequest.getCompletedServices();

    setState(() {
      data = completedServices;
      isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoad
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? RefreshIndicator(
                  onRefresh: _getInstance,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'When you service/help is completed, the job will be listed here. No completed job yet...',
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 0),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'asset/completed_job.png',
                          height: MediaQuery.of(context).size.height / 2.3,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _getInstance,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => JobDetails(
                                      requestId: data[index].id!,
                                      user: currentUserUid)))
                              .then((value) => setState(
                                    () {
                                      _getInstance();
                                    },
                                  ));
                        },
                        child: CustomCardServiceRequest(
                          category: data[index].category,
                          location: data[index].location,
                          date: data[index].date,
                          status: data[index].status,
                          requestorId: data[index].requestorId,
                          title: data[index].title,
                          rate: data[index].rate.toString(),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
