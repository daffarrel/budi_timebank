import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:latlong2/latlong.dart';

import '../components/constants.dart';
import '../custom widgets/heading2.dart';
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
import '../rate pages/rate_given_page.dart';
import 'applicants_selection.dart';

class RequestDetails extends StatefulWidget {
  final String requestId;
  final String user;
  const RequestDetails(
      {super.key, required this.requestId, required this.user});

  @override
  State<RequestDetails> createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  late DateTime dateJob;
  late DateTime dateCreatedOn;
  DateTime? dateUpdatedOn;
  late ServiceRequest requestDetails;

  late dynamic ratedUser;
  late Profile _userRequestor;
  Profile? _userProvidor;
  final List<Profile> _listApplicants = [];

  bool isLoad = true;

  bool isRated = false;
  final TextEditingController _commentController = TextEditingController();
  int _starRatingValue = 0;

  double? paymentTransferred;

  isPending() => requestDetails.status == ServiceRequestStatus.pending;
  isAccepted() => requestDetails.status == ServiceRequestStatus.accepted;
  isOngoing() => requestDetails.status == ServiceRequestStatus.ongoing;
  isCompletedVerified() =>
      requestDetails.status == ServiceRequestStatus.completedVerified;
  // pending completion verification
  isCompleted() => requestDetails.status == ServiceRequestStatus.completed;

  isRequestor() => requestDetails.requestorId == widget.user;

  @override
  void initState() {
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

    requestDetails =
        await ClientServiceRequest.getMyServiceRequestById(widget.requestId);

    _userRequestor =
        await ClientUser.getUserProfileById(requestDetails.requestorId);

    if (requestDetails.providerId != null) {
      _userProvidor =
          await ClientUser.getUserProfileById(requestDetails.providerId!);
    }

    // isNull(requestDetails.provider)
    //     ? _userProvidor = 'No Providor'
    //     : _userProvidor = await ClientUser(Common().channel)
    //         .getUserById(requestDetails.provider);
    // TODO: Check this

    dateCreatedOn = requestDetails.createdAt;
    dateUpdatedOn = requestDetails.updatedAt;
    dateJob = requestDetails.date;

    if (requestDetails.status == ServiceRequestStatus.completedVerified) {
      paymentTransferred =
          await ClientServiceRequest.getServiceIncome(widget.requestId);
      // remove negative value (just in  case)
      paymentTransferred = paymentTransferred?.abs();
    }

    if (requestDetails.status == ServiceRequestStatus.completedVerified) {
      var rating = await ClientRating.getRatingByJobId(jobId: widget.requestId);
      if (rating != null) {
        isRated = true;
        _starRatingValue = rating.rating;
      }
    }

    for (int i = 0; i < requestDetails.applicants.length; i++) {
      var name =
          await ClientUser.getUserProfileById(requestDetails.applicants[i]);
      _listApplicants.add(name);
    }

    // print(_listApplicants);
    setState(() {
      isLoad = false;
    });
  }

  String getStatus(ServiceRequestStatus status) {
    if (status == ServiceRequestStatus.pending &&
        requestDetails.applicants.isEmpty) {
      return 'Available';
    } else if (status == ServiceRequestStatus.completedVerified) {
      return 'Completed'; // Verified status will be denoted by a checkmark
    } else {
      return status.name.titleCase();
    }
  }

  //final rateServiceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Request Details'),
      ),
      body: isLoad
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (kDebugMode)
                  Text(
                    requestDetails.id.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                const Center(child: Heading2('Title')),
                Center(
                    child: Text(requestDetails.title.toString().capitalize())),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      shape: const RoundedRectangleBorder(
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
                                  getStatus(requestDetails.status),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 5),
                                if (requestDetails.status ==
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
                          children: [
                            const Heading2('Rate'),
                            Text(
                              '${requestDetails.rate} Time/hour',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        //does not have any applicants
                        if (_userProvidor == null &&
                            requestDetails.applicants.isEmpty) ...[
                          const Heading2('Applicants'),
                          const Text('No Applicants'),
                          const SizedBox(height: 5)
                        ],
                        if (requestDetails.applicants.isNotEmpty &&
                            _userProvidor == null)
                          ApplicantsSelectionList(
                            applicants: _listApplicants,
                            onSelectProvider: (int index) async {
                              // select applicants to be provider
                              await ClientServiceRequest.applyProvider(
                                  widget.requestId,
                                  requestDetails.applicants[index]);
                              // send notification to the selected provider
                              ClientNotification.notifyAcceptProvider(
                                  requestDetails.applicants[index],
                                  requestDetails.title);
                              if (mounted) Navigator.pop(context);
                              setState(() {
                                _getAllinstance();
                              });
                            },
                            onClickProfile: (int index) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ViewProfile(
                                    id: requestDetails.applicants[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        if (getStatus(requestDetails.status) != 'Available')
                          Column(
                            children: [
                              const Heading2('Provider'),
                              _userProvidor == null
                                  ? const Text('No provider selected')
                                  : TextButton(
                                      style: AppTheme
                                          .themeData2.textButtonTheme.style,
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => ViewProfile(
                                            id: requestDetails.requestorId,
                                          ),
                                        ));
                                      },
                                      // TODO: Chnage to requestor name
                                      child: Text(_userProvidor!.name
                                          .toString()
                                          .titleCase()),
                                    ),
                            ],
                          ),

                        //CustomDivider(color: AppTheme.themeData2.primaryColor),
                        //SizedBox(height: 8),
                        if (isCompletedVerified())
                          Column(
                            children: [
                              const Heading2('The request is completed'),
                              Text(
                                  'Completed On: ${requestDetails.completedAt?.formatDate()}'),
                              Text(
                                  'Time: ${requestDetails.completedAt?.formatTime()}'),
                            ],
                          ),
                        if (isCompletedVerified() && isRated)
                          Column(
                            children: [
                              const Text('You have rated the provider.'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Payment: '),
                                  Text(
                                    '${paymentTransferred?.toStringAsFixed(2)} Time/hour',
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              TextButton(
                                  style:
                                      AppTheme.themeData2.textButtonTheme.style,
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          const RateGivenPage(),
                                    ));
                                  },
                                  child: const Text('Go to rating page'))
                            ],
                          ),
                        if (isCompletedVerified() && !isRated)
                          Column(children: [
                            const Text(
                              'Rate the provider',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            Center(
                              child: RatingBar.builder(
                                initialRating: 0,
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                onRatingUpdate: (value) {
                                  _starRatingValue = value.toInt();
                                },
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                  hintText: 'Enter comment'),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                                style: AppTheme
                                    .themeData2.elevatedButtonTheme.style,
                                onPressed: () => showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: const Text('Submit Review?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await ClientRating.rateProvider(
                                                  rating: _starRatingValue,
                                                  message:
                                                      _commentController.text,
                                                  jobId: widget.requestId,
                                                  providerId:
                                                      _userProvidor!.userUid!);
                                              await ClientNotification
                                                  .notifyProviderRated(
                                                      _userProvidor!.userUid!,
                                                      requestDetails.title,
                                                      _starRatingValue);

                                              Navigator.pop(context);
                                              setState(() {
                                                _getAllinstance();
                                              });
                                            },
                                            child: const Text('Submit'),
                                          ),
                                        ],
                                      ),
                                    ),
                                child: const Text('Rate Provider'))
                          ]),
                        if (isOngoing() && !isCompleted())
                          const Column(
                            children: [
                              Text(
                                'The request has started',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        if (isCompleted())
                          Column(
                            children: [
                              const Text(
                                'The provider has marked the request as completed.',
                                textAlign: TextAlign.center,
                              ),
                              const Divider(),
                              ElevatedButton(
                                  style: AppTheme
                                      .themeData2.elevatedButtonTheme.style,
                                  onPressed: () async {
                                    await showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          ConfirmCompleteJobDialog(
                                              requestDetails: requestDetails),
                                    );
                                    _getAllinstance();
                                  },
                                  child: const Text('Verify Completion')),
                            ],
                          ),
                        if (_userProvidor != null && isAccepted())
                          Column(
                            children: [
                              const Text(
                                'Start the request to record the request to the database',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                  style: AppTheme
                                      .themeData2.elevatedButtonTheme.style,
                                  onPressed: () async {
                                    await showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          StartJobDialog(
                                              requestDetails: requestDetails),
                                    );
                                    _getAllinstance();
                                  },
                                  child: const Text('Start Request')),
                            ],
                          ),

                        if (_userProvidor == null)
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Delete Request?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await ClientServiceRequest
                                          .deleteServiceRequest(
                                              widget.requestId);
                                      if (!mounted) return;
                                      context.showSnackBar(
                                          message: 'Service Request deleted');
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                            child: const Text('Delete request'),
                          ),
                      ],
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
                const Divider(),
                const Heading2('Category'),
                Text(requestDetails.category),
                const Divider(),
                const Heading2('Community'),
                Text(requestDetails.communityType == null
                    ? 'Not specified'
                    : requestDetails.communityType!),
                const Divider(),
                const Heading2('Description'),
                Text(requestDetails.description.toString().capitalize()),
                const Divider(),
                const Heading2('Location'),
                Text('Address: ${requestDetails.location.address}'),
                Text('District: ${requestDetails.location.district}'),
                Text('State: ${requestDetails.location.state}'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                          requestDetails.location.coordinate.latitude,
                          requestDetails.location.coordinate.longitude),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: LatLng(
                                requestDetails.location.coordinate.latitude,
                                requestDetails.location.coordinate.longitude),
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
                const Divider(),
                const Heading2('Media'),
                requestDetails.media.isEmpty
                    ? const Text('No Attachment')
                    : SizedBox(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: requestDetails.media.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Text(
                                    '${index + 1}) ${requestDetails.media[index].toString()}'),
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
      // FIXME: reanable edit request
      // floatingActionButton: !isLoad && isPending()
      //     ? FloatingActionButton(
      //         onPressed: () {
      //           Navigator.of(context)
      //               .push(MaterialPageRoute(
      //                 builder: (context) => UpdatePage(id: requestDetails.id!),
      //               ))
      //               .then((value) => setState(
      //                     () {
      //                       _getAllinstance();
      //                     },
      //                   ));
      //         },
      //         tooltip: 'Edit Request',
      //         child: const Icon(Icons.edit),
      //       )
      //     : null,
    );
  }
}

class StartJobDialog extends StatefulWidget {
  const StartJobDialog({super.key, required this.requestDetails});

  final ServiceRequest requestDetails;

  @override
  State<StartJobDialog> createState() => _StartJobDialogState();
}

class _StartJobDialogState extends State<StartJobDialog> {
  bool processing = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start Request'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        if (processing)
          const SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(),
          )
        else
          TextButton(
            onPressed: () async {
              setState(() => processing = true);
              await ClientServiceRequest.startService(
                  widget.requestDetails.id!);
              await ClientNotification.notifyStartJob(
                  widget.requestDetails.providerId!,
                  widget.requestDetails.title);
              setState(() => processing = false);
              Navigator.pop(context);
            },
            child: const Text('Start'),
          ),
      ],
    );
  }
}

class ConfirmCompleteJobDialog extends StatefulWidget {
  const ConfirmCompleteJobDialog({super.key, required this.requestDetails});

  final ServiceRequest requestDetails;

  @override
  State<ConfirmCompleteJobDialog> createState() =>
      _ConfirmCompleteJobDialogState();
}

class _ConfirmCompleteJobDialogState extends State<ConfirmCompleteJobDialog> {
  bool processing = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Request?'),
      content: const Text(
          'Once the request completion is verified, transaction of Time/hour will be made.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        if (processing)
          const SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(),
          )
        else
          TextButton(
            onPressed: () async {
              setState(() => processing = true);
              await ClientServiceRequest.verifyServiceCompleted(
                  widget.requestDetails.id!);
              await ClientNotification.notifyVerifyCompleteJob(
                  widget.requestDetails.providerId!,
                  widget.requestDetails.title);
              setState(() => processing = false);
              Navigator.pop(context);
            },
            child: const Text('Complete'),
          ),
      ],
    );
  }
}
