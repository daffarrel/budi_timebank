import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../components/constants.dart';
import '../custom widgets/heading2.dart';
import '../custom widgets/custom_headline.dart';
import '../components/app_theme.dart';
import '../db_helpers/client_notification.dart';
import '../db_helpers/client_rating.dart';
import '../db_helpers/client_service_request.dart';
import '../db_helpers/client_user.dart';
import '../my_extensions/extension_datetime.dart';
import '../my_extensions/extension_string.dart';
import '../model/profile.dart';
import '../model/service_request.dart';
import '../profile pages/others_profile.dart';
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

  isPending() => jobDetail.status == ServiceRequestStatus.pending;
  isAccepted() => jobDetail.status == ServiceRequestStatus.accepted;
  isOngoing() => jobDetail.status == ServiceRequestStatus.ongoing;
  isCompletedVerified() =>
      jobDetail.status == ServiceRequestStatus.completedVerified;
  // pending completion verification
  isCompleted() => jobDetail.status == ServiceRequestStatus.completed;

  bool isRequested() => jobDetail.applicants.contains(widget.user);

  @override
  void initState() {
    super.initState();
    isLoad = true;

    _getAllinstance();
  }

  void _getAllinstance() async {
    setState(() => isLoad = true);

    jobDetail =
        await ClientServiceRequest.getMyServiceRequestById(widget.requestId);

    _userRequestor = await ClientUser.getUserProfileById(jobDetail.requestorId);

    if (jobDetail.status == ServiceRequestStatus.completedVerified) {
      _earnedIncome =
          await ClientServiceRequest.getServiceIncome(widget.requestId);
    }

    if (jobDetail.status == ServiceRequestStatus.completedVerified) {
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
    jobDetail.applicants.isEmpty
        ? _userProvidor = 'No Providor'
        : _userProvidor =
            await ClientUser.getUserProfileById(jobDetail.requestorId);
    dateCreatedOn = jobDetail.createdAt;
    dateUpdatedOn = jobDetail.updatedAt;
    dateJob = jobDetail.date;

    //print(widget.id);
    // ratedUser = await ClientRating(Common().channel)
    //     .getResponseRating('request_id', JobDetails.id);
    // TODO: Implement this

    for (int i = 0; i < jobDetail.applicants.length; i++) {
      var name = await ClientUser.getUserProfileById(jobDetail.applicants[i]);
      _listApplicants.add(name);
    }
    setState(() => isLoad = false);
  }

  /// Send job request to job creator and add me to list of applicants
  void applyJob(String reqid, String provider) async {
    try {
      await ClientServiceRequest.applyApplicant(reqid, provider);
      ClientNotification.notifyAddApplicant(
          jobDetail.requestorId, jobDetail.title);
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

  String getServiceStatus(ServiceRequestStatus status) {
    if (status == ServiceRequestStatus.pending &&
        !jobDetail.applicants
            .contains(FirebaseAuth.instance.currentUser!.uid)) {
      return 'Available';
    } else if (status == ServiceRequestStatus.completedVerified) {
      return 'Completed'; // Verified status will be denoted by a checkmark
    } else {
      return status.name.capitalize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        title: const Text('Job details'),
      ),
      body: isLoad
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                if (kDebugMode)
                  Text(
                    jobDetail.id.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                const Center(child: Heading2('Title')),
                Center(child: Text(jobDetail.title.toString().capitalize())),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      clipBehavior: Clip.hardEdge,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: InkWell(
                        onTap: () {
                          // view requestor profile
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewProfile(id: jobDetail.requestorId),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Heading2('Requestor'),
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
                        //   color: AppTheme.themeData.secondaryHeaderColor,
                        //   width: 3,
                        // ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Heading2('Status'),
                            Row(
                              children: [
                                Text(
                                  getServiceStatus(jobDetail.status),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 5),
                                if (jobDetail.status ==
                                    ServiceRequestStatus.completedVerified)
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.blue, size: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Heading2('Rate'),
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
                if (isCompletedVerified())
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Heading2('Completed On'),
                          Text('Date: ${jobDetail.updatedAt?.formatDate()}'),
                          Text('Time: ${jobDetail.updatedAt?.formatTime()}\n'),
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
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            ),
                            TextButton(
                                style:
                                    AppTheme.themeData2.textButtonTheme.style,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
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
                  ),
                if (isCompleted())
                  const Card(
                    shape: RoundedRectangleBorder(),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          CustomHeadline('Job has been completed'),
                          SizedBox(height: 10),
                          Text('Pending verification from requestor')
                        ],
                      ),
                    ),
                  ),
                if (isAccepted())
                  const Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          CustomHeadline(
                              'You have been accepted as the provider'),
                          SizedBox(height: 10),
                          Text(
                            'Contact your requestor to start the request when you are ready',
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                if (isOngoing())
                  Card(
                    shape: const RoundedRectangleBorder(
                      // side: BorderSide(
                      //   color: AppTheme.themeData.secondaryHeaderColor,
                      //   width: 3,
                      // ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const CustomHeadline(
                              'You are currently doing this request'),
                          ElevatedButton(
                              onPressed: () async {
                                var res = await showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Mark task as completed?'),
                                        content: const Text(
                                            'Mark task as completed if you have successfully completed the task. Requestor will verify the completion before payment is released'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel')),
                                          TextButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text('Confirm'))
                                        ],
                                      );
                                    });
                                if (res ?? false) {
                                  await ClientServiceRequest.markTaskComplete(
                                      widget.requestId);
                                  await ClientNotification.claimCompleteJob(
                                      jobDetail.requestorId, jobDetail.title);
                                  _getAllinstance();
                                }
                              },
                              child: const Text('Task completed'))
                        ],
                      ),
                    ),
                  ),
                if (!isAccepted() &&
                    !isOngoing() &&
                    !isCompleted() &&
                    !isCompletedVerified())
                  Card(
                    shape: const RoundedRectangleBorder(
                      // side: BorderSide(
                      //   //color: AppTheme.themeData.secondary1HeaderColor,
                      //   width: 3,
                      // ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    //sini oi the service
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: !isRequested()
                          ? Column(
                              children: [
                                const Heading2('Want to help?'),
                                ElevatedButton(
                                  style: AppTheme
                                      .themeData2.elevatedButtonTheme.style,
                                  onPressed: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text('Apply request?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            applyJob(
                                                jobDetail.id!, widget.user);
                                          },
                                          child: const Text('Apply'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: const Text('Apply Request'),
                                ),
                              ],
                            )
                          : const Center(
                              child: Text(
                                  'You have applied the request.\nContact the Requestor to accept you as Provider'),
                            ),
                    ),
                  ),
                const SizedBox(height: 15),
                Container(
                    alignment: Alignment.center,
                    child: const Heading2('Other Information')),
                const Divider(),
                const Heading2('Date of the request'),
                Text('Date: ${dateJob.formatDate()}'),
                Text('Time: ${dateJob.formatTime()}'),
                //const SizedBox(height: 15),
                const Divider(),
                const Heading2('Category'),
                Text(jobDetail.category),
                const Divider(),
                const Heading2('Community'),
                Text(jobDetail.communityType == null
                    ? 'Not specified'
                    : jobDetail.communityType!),
                const Divider(),
                const Heading2('Description'),
                Text(jobDetail.description.toString().capitalize()),
                const Divider(),
                const Heading2('Location'),
                Text('Address: ${jobDetail.location.address}'),
                Text('State: ${jobDetail.location.state}'),
                Text('District: ${jobDetail.location.district}'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: FlutterMap(
                    options: const MapOptions(
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.pinchZoom,
                      ),
                      initialZoom: 16.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'iium-buditimebank',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: LatLng(
                              jobDetail.location.coordinate.latitude,
                              jobDetail.location.coordinate.longitude,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.location_on),
                              color: Colors.red,
                              iconSize: 45,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                TextButton.icon(
                    style:
                        TextButton.styleFrom(foregroundColor: Colors.black87),
                    onPressed: () => MapsLauncher.launchCoordinates(
                          jobDetail.location.coordinate.latitude,
                          jobDetail.location.coordinate.longitude,
                        ),
                    icon: const FaIcon(FontAwesomeIcons.map, size: 19.4),
                    label: const Text('Get Direction')),
                const Divider(),
                const Heading2('Media'),
                jobDetail.media.isEmpty
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
                        const Heading2('Created On'),
                        Text('Date: ${dateCreatedOn.formatDate()}'),
                        Text('Time: ${dateCreatedOn.formatTime()}'),
                      ],
                    ),
                    if (dateUpdatedOn != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Heading2('Updated On'),
                          Text('Date: ${dateUpdatedOn?.formatDate()}'),
                          Text('Time: ${dateUpdatedOn?.formatTime()}'),
                        ],
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
