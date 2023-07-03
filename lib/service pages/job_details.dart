import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../components/constants.dart';
import '../custom widgets/heading2.dart';
import '../custom widgets/custom_headline.dart';
import '../custom%20widgets/theme.dart';
import '../db_helpers/client_rating.dart';
import '../db_helpers/client_service_request.dart';
import '../db_helpers/client_user.dart';
import '../extension_string.dart';
import '../model/profile.dart';
import '../model/service_request.dart';
import '../rate pages/rate_received_page.dart';

/// Basically request details but in Job offers tab
class JobDetails extends StatefulWidget {
  final String requestId;
  final String user;
  const JobDetails({super.key, required this.requestId, required this.user});

  @override
  State<JobDetails> createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetails> {
  late DateTime dateJob;
  late DateTime dateCreatedOn;
  DateTime? dateUpdatedOn;
  late ServiceRequest jobDetail;

  // will be assigned for completed job only
  double? _earnedIncome;

  // will be assigned for rated job only
  int? _ratingStar;
  String? _ratingComment;

  late dynamic ratedUser;
  late Profile _userRequestor;
  late dynamic _userProvidor;
  final dynamic _listApplicants = [];

  late bool isLoad = false;

  isNull(dynamic stuff) {
    if (stuff == '' || stuff.length == 0) {
      return true;
    } else {
      return false;
    }
  }

  isComplete() {
    if (jobDetail.status.name.toUpperCase() == 'COMPLETED') {
      return true;
    } else {
      return false;
    }
  }

  isAccepted() {
    if (jobDetail.status.name.toUpperCase() == 'ACCEPTED') {
      return true;
    } else {
      return false;
    }
  }

  isOngoing() {
    if (jobDetail.status.name.toUpperCase() == 'ONGOING') {
      return true;
    } else {
      return false;
    }
  }

  isPending() {
    if (jobDetail.status.name.toUpperCase() == 'PENDING') {
      return true;
    } else {
      return false;
    }
  }

  bool isRequested() {
    return jobDetail.applicants.contains(widget.user);
  }

  // isProviderRated() {
  //   if (ratedUser.ratings.length == 1 &&
  //       ratedUser.ratings[0].recipient == JobDetails.provider) {
  //     return true;
  //   } else if (ratedUser.ratings.length == 2 &&
  //       (ratedUser.ratings[0].recipient == JobDetails.provider ||
  //           ratedUser.ratings[1].recipient == JobDetails.provider)) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  // isRequestorRated() {
  //   if (ratedUser.ratings.length == 1 &&
  //       ratedUser.ratings[0].recipient == JobDetails.requestor) {
  //     return true;
  //   } else if (ratedUser.ratings.length == 2 &&
  //       (ratedUser.ratings[0].recipient == JobDetails.requestor ||
  //           ratedUser.ratings[1].recipient == JobDetails.requestor)) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  @override
  void initState() {
    isLoad = true;
    // hasRequestorRated = false;
    // hasRateRequestor = false;

    _getAllinstance();
    // _getRatingResponse();
    // _getApplicants();
    //_getRatingId();
    super.initState();
  }

  void _getAllinstance() async {
    setState(() {
      isLoad = true;
    });

    jobDetail =
        await ClientServiceRequest.getMyServiceRequestById(widget.requestId);

    _userRequestor = await ClientUser.getUserProfileById(jobDetail.requestorId);

    if (jobDetail.status == ServiceRequestStatus.completed) {
      _earnedIncome =
          await ClientServiceRequest.getServiceIncome(widget.requestId);
    }

    if (jobDetail.status == ServiceRequestStatus.completed) {
      var rating = await ClientRating.getRatingByJobId(jobId: widget.requestId);
      if (rating != null) {
        _ratingStar = rating.rating;
        _ratingComment = rating.message;
      }
    }

    // isNull(JobDetails.provider)
    //     ? _userProvidor = 'No Providor'
    //     : _userProvidor = await ClientUser(Common().channel)
    //         .getUserById(JobDetails.provider);
    // TODO: Check this
    isNull(jobDetail.applicants)
        ? _userProvidor = 'No Providor'
        : _userProvidor =
            await ClientUser.getUserProfileById(jobDetail.requestorId);
    // print(_userProvidor);
    dateCreatedOn = jobDetail.createdAt;
    dateUpdatedOn = jobDetail.updatedAt;
    dateJob = jobDetail.date;

    //print(widget.id);
    // ratedUser = await ClientRating(Common().channel)
    //     .getResponseRating('request_id', JobDetails.id);
    // TODO: Implement this

    for (int i = 0; i < jobDetail.applicants.length; i++) {
      // print(jobDetail.applicants[i]);
      var name = await ClientUser.getUserProfileById(jobDetail.applicants[i]);
      _listApplicants.add(name);
    }
    setState(() => isLoad = false);
  }

  void applyJob(String reqid, String provider) async {
    try {
      await ClientServiceRequest.applyApplicant(reqid, provider);

      context.showSnackBar(message: 'Job have been successfully requested');
      Navigator.of(context).pop();
      _getAllinstance();
    } catch (e) {
      context.showErrorSnackBar(message: e.toString());
    }
  }

  // void _rateRequestor(
  //     String author, int value, String comment, String id) async {
  //   try {
  //     await ClientRating(Common().channel)
  //         .ratingForRequestor(author, value, comment, id);
  //     setState(() {});
  //     context.showSnackBar(message: 'Requestor rated!!');
  //     Navigator.of(context).pop();
  //   } on GrpcError catch (e) {
  //     context.showErrorSnackBar(message: 'Caught error: ${e.message}');
  //   } catch (e) {
  //     context.showErrorSnackBar(message: e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        title: const Text('Job details'),
      ),
      body: isLoad
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (kDebugMode)
                    Text(
                      jobDetail.id.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  // Heading2('Job Id'),
                  // Text(widget.id),
                  Center(child: Heading2('Title')),
                  Center(child: Text(jobDetail.title.toString().capitalize())),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Card(
                          shape: const RoundedRectangleBorder(
                            // side: BorderSide(
                            //   color: themeData1().secondaryHeaderColor,
                            //   width: 3,
                            // ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Heading2('Requestor'),
                                Text(
                                  _userRequestor.name.toString().titleCase(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: const RoundedRectangleBorder(
                          // side: BorderSide(
                          //   color: themeData1().secondaryHeaderColor,
                          //   width: 3,
                          // ),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Heading2('Status'),
                              Text(
                                jobDetail.status.name.capitalize(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: const RoundedRectangleBorder(
                          // side: BorderSide(
                          //   color: themeData1().secondaryHeaderColor,
                          //   width: 3,
                          // ),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            //crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Heading2('Rate'),
                              Text(
                                '${jobDetail.rate} Time/hour',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  isComplete() //isRequestcomplete?
                      ? Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Heading2('Completed On'),
                                Text(
                                    'Date: ${jobDetail.updatedAt?.day}-${jobDetail.updatedAt?.month}-${jobDetail.updatedAt?.year}\n'),
                                Text(
                                    'Time: ${jobDetail.updatedAt?.hour}:${jobDetail.updatedAt?.minute}:${jobDetail.updatedAt?.second}\n'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Payment received: '),
                                    Text(
                                      '${_earnedIncome!.toStringAsFixed(2)} Time/hour',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                if (_ratingStar != null) // has received rating
                                  ...[
                                  const SizedBox(height: 10),
                                  RatingBarIndicator(
                                    rating: _ratingStar!.toDouble(),
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    direction: Axis.horizontal,
                                  ),
                                  Text(
                                    _ratingComment ?? 'No comment was given',
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                                  TextButton(
                                      style: themeData2().textButtonTheme.style,
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) =>
                                              const RateReceivedPage(),
                                        ));
                                      },
                                      child: const Text('Go to rating page'))
                                ] else ...[
                                  const SizedBox(height: 10),
                                  const Text('No rating has been given yet'),
                                  const SizedBox(height: 10),
                                ]
                              ],
                            ),
                          ),
                        )
                      : isAccepted()
                          ? const Card(
                              shape: RoundedRectangleBorder(
                                // side: BorderSide(
                                //   color: themeData1().secondaryHeaderColor,
                                //   width: 3,
                                // ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    CustomHeadline(
                                        heading:
                                            'You have been accepted as the provider'),
                                    Text(
                                        'Contact your requestor to start the request when you are ready')
                                  ],
                                ),
                              ),
                            )
                          : isOngoing()
                              ? const Card(
                                  shape: RoundedRectangleBorder(
                                    // side: BorderSide(
                                    //   color: themeData1().secondaryHeaderColor,
                                    //   width: 3,
                                    // ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                        child: CustomHeadline(
                                            heading:
                                                'You are currently doing this request')),
                                  ),
                                )
                              : Card(
                                  shape: const RoundedRectangleBorder(
                                    // side: BorderSide(
                                    //   //color: themeData1().secondaryHeaderColor,
                                    //   width: 3,
                                    // ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  //sini oi the service
                                  elevation: 5,
                                  child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: !isRequested()
                                          ? Column(
                                              children: [
                                                Heading2('Want to help?'),
                                                ElevatedButton(
                                                    style: themeData2()
                                                        .elevatedButtonTheme
                                                        .style,
                                                    onPressed: () =>
                                                        showDialog<String>(
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              AlertDialog(
                                                            title: const Text(
                                                                'Apply request?'),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context,
                                                                        'Cancel'),
                                                                child: const Text(
                                                                    'Cancel'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  applyJob(
                                                                      jobDetail
                                                                          .id!,
                                                                      widget
                                                                          .user);
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'Apply'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    // onPressed: () {

                                                    //   // print(widget.id);
                                                    //   // print(widget.user);

                                                    // },
                                                    child: const Text(
                                                        'Apply Request')),
                                              ],
                                            )
                                          : const Center(
                                              child: Text(
                                                  'You have applied the request.\nContact the Requestor to accept you as Provider'),
                                            )),
                                ),
                  const SizedBox(height: 15),
                  Container(
                      alignment: Alignment.center,
                      child: Heading2('Other Information')),
                  const Divider(),
                  Heading2('Date of the request'),
                  Text(
                      'Date: ${dateJob.day}-${dateJob.month}-${dateJob.year}\nTime: ${dateJob.hour.toString().padLeft(2, '0')}:${dateJob.minute.toString().padLeft(2, '0')}'),
                  //const SizedBox(height: 15),
                  const Divider(),
                  Heading2('Category'),
                  Text(jobDetail.category),
                  const Divider(),
                  Heading2('Description'),
                  Text(jobDetail.description.toString().capitalize()),
                  const Divider(),
                  Heading2('Location'),
                  Text('Address: ${jobDetail.location.address}'),
                  Text('State: ${jobDetail.location.state}'),
                  Text('City: ${jobDetail.location.city}'),
                  const Divider(),
                  Heading2('Media'),
                  isNull(jobDetail.media)
                      ? const Text('No Attachment')
                      : SizedBox(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: jobDetail.media.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Text(
                                      '${index + 1}) ${jobDetail.media[index].toString()}'),
                                ],
                              );
                            },
                          ),
                        ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Heading2('Created On'),
                          Text(
                              'Date: ${dateCreatedOn.day}-${dateCreatedOn.month}-${dateCreatedOn.year}\nTime: ${dateCreatedOn.hour}:${dateCreatedOn.minute}'),
                        ],
                      ),
                      if (dateUpdatedOn != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Heading2('Updated On'),
                            Text(
                                'Date: ${dateUpdatedOn!.day}-${dateUpdatedOn!.month}-${dateUpdatedOn!.year}\nTime: ${dateUpdatedOn!.hour}:${dateUpdatedOn!.minute}'),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
