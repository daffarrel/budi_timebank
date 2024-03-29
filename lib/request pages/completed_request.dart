import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../custom widgets/custom_card_service_request.dart';
import '../db_helpers/client_service_request.dart';
import '../model/service_request.dart';
import 'request_details.dart';

class CompletedRequest extends StatefulWidget {
  const CompletedRequest({super.key});

  @override
  State<CompletedRequest> createState() => _CompletedRequestState();
}

class _CompletedRequestState extends State<CompletedRequest> {
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  late bool isLoad;
  late List<ServiceRequest> data;
  late dynamic listRating;
  bool isRequest = true;

  @override
  void initState() {
    isLoad = true;
    getinstance();
    super.initState();
  }

  Future getinstance() async {
    setState(() => isLoad = true);

    var completedReqs = await ClientServiceRequest.getCompletedRequest();
    // TODO: Implement rating

    // listRating.addAll(await supabase
    //     .from('ratings')
    //     .select()
    //     .eq('author', user)
    //     .range(from, to));

    setState(() {
      data = completedReqs;
      isLoad = false;
    });
    //print(listRequest.requests.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoad
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'All completed request will be listed here, remember to declare the job to "Completed". No completed requests for now...',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(bottom: 0),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'asset/Business deal-pana.png',
                          height: MediaQuery.of(context).size.height / 2.3,
                        )),
                  ],
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height / 1.2,
                  child: RefreshIndicator(
                    onRefresh: getinstance,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => RequestDetails(
                                        requestId: data[index].id!,
                                        user: currentUserUid)))
                                .then((value) => setState(
                                      () {
                                        getinstance();
                                      },
                                    ));
                          },
                          child: CustomCardServiceRequest(
                            category: data[index].category,
                            location: data[index].location,
                            date: data[index].date,
                            // status: isRated(listFiltered[index].id)
                            //     ? 'Completed (Rated)'
                            //     : 'Completed (Unrated)',
                            // TODO: implement rated/notrated
                            status: data[index].status,
                            requestorId: data[index].requestorId,
                            title: data[index].title,
                            rate: data[index].rate.toString(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
