import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../custom widgets/custom_card_service_request.dart';
import '../db_helpers/client_service_request.dart';
import '../model/service_request.dart';
import '../shared/community_list.dart';
import '../shared/job_categories.dart';
import '../shared/malaysia_state.dart';
import 'filter_modal_sheet.dart';
import 'job_details.dart';

class AvailableServices extends StatefulWidget {
  const AvailableServices({Key? key}) : super(key: key);

  @override
  State<AvailableServices> createState() => _AvailableServicesState();
}

class _AvailableServicesState extends State<AvailableServices> {
  late String user;
  String? filterState;
  String? filterCategory;
  String? filterCommunity;

  Future<List<ServiceRequest>> getinstance() async {
    user = FirebaseAuth.instance.currentUser!.uid;

    var documents = await ClientServiceRequest.getMyAvailableServices();

    // apply filter by state
    if (filterState != null) {
      documents = documents
          .where((element) => element.location.state == filterState)
          .toList();
    }

    // apply filter by category
    if (filterCategory != null) {
      documents = documents
          .where((element) => element.category == filterCategory)
          .toList();
    }

    // apply filter by community
    if (filterCommunity != null) {
      documents = documents
          .where((element) => element.communityType == filterCommunity)
          .toList();
    }

    return documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return Future(() => setState(() {}));
        },
        child: Stack(
          children: [
            FutureBuilder(
                future: getinstance(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                        child:
                            Text('Error getting data. Please try again later'));
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
                    padding: const EdgeInsets.only(top: 50),
                    itemCount: jobData.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => JobDetails(
                                      requestId: jobData[index].id!,
                                      user: user)))
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  ActionChip(
                    avatar: Icon(
                      Icons.filter_alt_outlined,
                      size: 20,
                      color:
                          filterState == null ? Colors.black87 : Colors.white,
                    ),
                    label: Text(
                      filterState == null ? 'Filter state' : filterState!,
                      style: TextStyle(
                          color: filterState == null
                              ? Colors.black87
                              : Colors.white),
                    ),
                    backgroundColor:
                        filterState == null ? Colors.grey[300] : Colors.blue,
                    onPressed: () async {
                      var result = await showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return FilterModelSheet(
                              selectedState: filterState,
                              filterList: MalaysiaState.allStatesName(),
                            );
                          });
                      if (result == null) return;

                      if (result == 'All') {
                        setState(() => filterState = null);
                      } else {
                        setState(() => filterState = result);
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  ActionChip(
                    avatar: Icon(
                      Icons.filter_alt_outlined,
                      size: 20,
                      color: filterCategory == null
                          ? Colors.black87
                          : Colors.white,
                    ),
                    label: Text(
                      filterCategory == null
                          ? 'Filter category'
                          : filterCategory!,
                      style: TextStyle(
                          color: filterCategory == null
                              ? Colors.black87
                              : Colors.white),
                    ),
                    backgroundColor:
                        filterCategory == null ? Colors.grey[300] : Colors.blue,
                    onPressed: () async {
                      var result = await showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return FilterModelSheet(
                              selectedState: filterCategory,
                              filterList: kJobCategories,
                            );
                          });
                      if (result == null) return;

                      if (result == 'All') {
                        setState(() => filterCategory = null);
                      } else {
                        setState(() => filterCategory = result);
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  ActionChip(
                    avatar: Icon(
                      Icons.filter_alt_outlined,
                      size: 20,
                      color: filterCommunity == null
                          ? Colors.black87
                          : Colors.white,
                    ),
                    label: Text(
                      filterCommunity == null
                          ? 'Filter community'
                          : filterCommunity!,
                      style: TextStyle(
                          color: filterCommunity == null
                              ? Colors.black87
                              : Colors.white),
                    ),
                    backgroundColor: filterCommunity == null
                        ? Colors.grey[300]
                        : Colors.blue,
                    onPressed: () async {
                      var result = await showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return FilterModelSheet(
                              selectedState: filterCommunity,
                              filterList: kCommunityList,
                            );
                          });
                      if (result == null) return;

                      if (result == 'All') {
                        setState(() => filterCommunity = null);
                      } else {
                        setState(() => filterCommunity = result);
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
      // FIXME: Search disabled sbb belum migrate
    );
  }
}
