import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../custom widgets/custom_card_service_request.dart';
import '../components/app_theme.dart';
import '../db_helpers/client_service_request.dart';
import '../model/service_request.dart';
import 'request_details.dart';
import 'request_form.dart';

class YourRequest extends StatefulWidget {
  const YourRequest({Key? key}) : super(key: key);

  @override
  State<YourRequest> createState() => _YourRequestState();
}

class _YourRequestState extends State<YourRequest> {
  late String userUid;
  late bool isLoad;
  //late dynamic listRequest;
  bool isRequest = true;
  late Future<List<ServiceRequest>> listRequestFuture;

  @override
  void initState() {
    super.initState();
    listRequestFuture = ClientServiceRequest.getPendingRequests();
    userUid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List<ServiceRequest>>(
            future: listRequestFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data!.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 1.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Need help from other people?\nRequest help to let people know...',
                          textAlign: TextAlign.center,
                        ),
                        Container(
                            margin: const EdgeInsets.only(bottom: 0),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'asset/Team spirit-amico.png',
                              height: MediaQuery.of(context).size.height / 2.3,
                            )),
                      ],
                    ),
                  ),
                );
              }

              var requests = snapshot.data!;
              // sort request by created date (latest on top)
              requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              return SizedBox(
                height: MediaQuery.of(context).size.height / 1.2,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => RequestDetails(
                                    requestId: requests[index].id!,
                                    user: userUid)))
                            .then((value) => setState(
                                  () {
                                    listRequestFuture = ClientServiceRequest
                                        .getPendingRequests();
                                  },
                                ));
                      },
                      child: CustomCardServiceRequest(
                        category: requests[index].category,
                        location: requests[index].location,
                        date: requests[index].date,
                        status: requests[index].status,
                        requestorId: requests[index].requestorId,
                        title: requests[index].title,
                        rate: requests[index].rate.toString(),
                        isHaveApplicants: requests[index].applicants.isNotEmpty,
                      ),
                    );
                  },
                ),
              );
            }),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.themeData.primaryColor,
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RequestForm(),
                ));
            setState(() {
              listRequestFuture = ClientServiceRequest.getPendingRequests();
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Request'),
        ));
  }
}
