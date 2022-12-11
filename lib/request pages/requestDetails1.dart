import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grpc/grpc.dart';
import 'package:testfyp/components/constants.dart';
import 'package:testfyp/custom%20widgets/customDivider.dart';
import 'package:testfyp/custom%20widgets/theme.dart';
import 'package:testfyp/extension_string.dart';
import 'package:testfyp/other%20profile/viewProfile.dart';
import 'package:testfyp/rate%20pages/rateGiven.dart';
import '../bin/client_rating.dart';
import '../bin/client_service_request.dart';
import '../bin/client_user.dart';
import '../bin/common.dart';
import '../custom widgets/heading2.dart';

class RequestDetails1 extends StatefulWidget {
  final String requestId;
  final bool isRequest;
  final String user;
  RequestDetails1(
      {required this.requestId, required this.isRequest, required this.user});

  @override
  State<RequestDetails1> createState() => _RequestDetails1State();
}

class _RequestDetails1State extends State<RequestDetails1> {
  double _valueController = 0;
  double _value1Controller = 0;

  final _commentController = TextEditingController();
  final _comment1Controller = TextEditingController();

  late final dynamic dateCreatedOn;
  late final dynamic dateUpdatedOn;
  late final dynamic dateCompletedOn;
  late final dynamic requestDetails;

  late dynamic ratedUser;
  late dynamic _userRequestor;
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
    if (requestDetails.request.state.toString() == 'COMPLETED') {
      return true;
    } else {
      return false;
    }
  }

  isOngoing() {
    if (requestDetails.request.state.toString() == 'ONGOING') {
      return true;
    } else {
      return false;
    }
  }

  isPending() {
    if (requestDetails.request.state.toString() == 'PENDING') {
      return true;
    } else {
      return false;
    }
  }

  isRated() {
    if (ratedUser.ratings.length == 1) {
      // setState(() {

      // });
      return true;
    } else if (ratedUser.ratings.length == 2) {
      return false;
    } else {
      return true;
    }
  }

  isProviderRated() {
    if (ratedUser.ratings.length == 1 &&
        ratedUser.ratings[0].recipient == requestDetails.request.provider) {
      return true;
    } else if (ratedUser.ratings.length == 2 &&
        (ratedUser.ratings[0].recipient == requestDetails.request.provider ||
            ratedUser.ratings[1].recipient ==
                requestDetails.request.provider)) {
      return true;
    } else {
      return false;
    }
  }

  isRequestorRated() {
    if (ratedUser.ratings.length == 1 &&
        ratedUser.ratings[0].recipient == requestDetails.request.requestor) {
      return true;
    } else if (ratedUser.ratings.length == 2 &&
        (ratedUser.ratings[0].recipient == requestDetails.request.requestor ||
            ratedUser.ratings[1].recipient ==
                requestDetails.request.requestor)) {
      return true;
    } else {
      return false;
    }
  }

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
    requestDetails = await ClientServiceRequest(Common().channel)
        .getResponseById(widget.requestId);
    //print(requestDetails.request.mediaAttachments);
    _userRequestor = await ClientUser(Common().channel)
        .getUserById(requestDetails.request.requestor);

    isNull(requestDetails.request.provider)
        ? _userProvidor = 'No Providor'
        : _userProvidor = await ClientUser(Common().channel)
            .getUserById(requestDetails.request.provider);
    //print(_userProvidor);
    dateCreatedOn = DateTime.parse(requestDetails.request.createdAt);
    dateUpdatedOn = DateTime.parse(requestDetails.request.updatedAt);

    isComplete()
        ? dateCompletedOn = DateTime.parse(requestDetails.request.completedAt)
        : dateCompletedOn = '';
    //print(widget.id);
    ratedUser = await ClientRating(Common().channel)
        .getResponseRating('request_id', requestDetails.request.id);

    // print(ratedUser);
    // print(widget.requestor);
    for (int i = 0; i < requestDetails.request.applicants.length; i++) {
      //print(widget.applicants[i]);
      var name = await ClientUser(Common().channel)
          .getUserById(requestDetails.request.applicants[i]);
      _listApplicants.add(name);
    }
    // print(_listApplicants);
    setState(() {
      isLoad = false;
    });
  }

  void applyJob(String reqid, String provider) async {
    try {
      await ClientServiceRequest(Common().channel)
          .applyProvider1(reqid, provider);
      context.showSnackBar(message: 'Job requested!!');
      Navigator.of(context).pop();
    } on GrpcError catch (e) {
      context.showErrorSnackBar(message: '${e.message}');
      //print(e);
    } catch (e) {
      context.showErrorSnackBar(message: e.toString());
    }
  }

  void _completeJob(String id, String user) async {
    try {
      await ClientServiceRequest(Common().channel).completeService1(id, user);
      context.showSnackBar(message: 'Job Completed');
      Navigator.of(context).pop();
    } on GrpcError catch (e) {
      context.showErrorSnackBar(message: 'Caught error: ${e.message}');
    } catch (e) {
      context.showErrorSnackBar(message: e.toString());
    }
  }

  void _rateRequestor(
      String author, int value, String comment, String id) async {
    //widget.counter++;
    try {
      await ClientRating(Common().channel)
          .ratingForRequestor(author, value, comment, id);
      setState(() {
        //ddwidget.hasRequestorRated = true;
        //print
      });
      context.showSnackBar(message: 'Requestor rated!!');
      Navigator.of(context).pop();
    } on GrpcError catch (e) {
      context.showErrorSnackBar(message: 'Caught error: ${e.message}');
    } catch (e) {
      context.showErrorSnackBar(message: e.toString());
    }
  }

  void _rateProvider(
      String author, int value, String comment, String id) async {
    // widget.counter++;
    try {
      await ClientRating(Common().channel)
          .ratingForProvider(author, value, comment, id);
      context.showSnackBar(message: 'Provider rated!!');
      Navigator.of(context).pop();
    } on GrpcError catch (e) {
      context.showErrorSnackBar(message: 'Caught error: ${e.message}');
    } catch (e) {
      context.showErrorSnackBar(message: e.toString());
    }
    // setState(() {
    //   //widget.hasProviderRated = true;
    //   //hasRequestorRated = true;
    //   //print(hasRequestorRated);
    // });
  }

  void _deleteRequest(String id) async {
    try {
      await ClientServiceRequest(Common().channel).deleteService(id);
      context.showSnackBar(message: 'Job Deleted');
      Navigator.of(context).pop();
    } on GrpcError catch (e) {
      context.showErrorSnackBar(message: 'Caught error: ${e.message}');
      print(e);
    } catch (e) {
      context.showErrorSnackBar(message: e.toString());
    }
  }

  void _selectProvider(String id, String provider, String caller) async {
    try {
      await ClientServiceRequest(Common().channel)
          .selectProvider1(id, provider, caller);
      context.showSnackBar(message: 'Applicant Selected');
      Navigator.of(context).pop();
    } on GrpcError catch (e) {
      context.showErrorSnackBar(message: 'Caught error: ${e.message}');
    } catch (e) {
      context.showErrorSnackBar(message: e.toString());
    }
  }

  //final rateServiceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isRequest
          ? AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text('Job Details'),
            )
          : AppBar(
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              title: Text('Job Details'),
            ),
      body: isLoad
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Heading2('Job Id'),
                  // Text(widget.id),
                  Heading2('Title'),
                  Text(requestDetails.request.title.toString().capitalize()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Heading2('Requestor'),
                          Text(_userRequestor.user.name.toString().titleCase()),
                        ],
                      ),
                      Column(
                        children: [
                          Heading2('State'),
                          Text(requestDetails.request.state
                              .toString()
                              .capitalize()),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Heading2('Rate'),
                          Text('\$time/hour ' +
                              requestDetails.request.rate.toString()),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  widget.isRequest
                      ? Card(
                          elevation: 5,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                isNull(requestDetails.request
                                        .applicants) //does not have any  applicants
                                    ? Column(
                                        children: [
                                          Heading2('Applicants'),
                                          Text('No Applicants'),
                                        ],
                                      )
                                    : isNull(requestDetails.request
                                            .provider) // have applicants
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Heading2('Applicants'),
                                                Text(
                                                    'Select your applicants: '),
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: requestDetails
                                                      .request
                                                      .applicants
                                                      .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Row(
                                                      children: [
                                                        Expanded(
                                                          child: ElevatedButton(
                                                              style: themeData2()
                                                                  .elevatedButtonTheme
                                                                  .style,
                                                              onPressed: () {
                                                                // print(widget.id);
                                                                // print(
                                                                //     widget.applicants[
                                                                //         index]);
                                                                // print(widget.user);
                                                                _selectProvider(
                                                                    requestDetails
                                                                        .request
                                                                        .id
                                                                        .toString(),
                                                                    requestDetails
                                                                        .request
                                                                        .applicants[
                                                                            index]
                                                                        .toString(),
                                                                    widget.user
                                                                        .toString());
                                                              },
                                                              child: Text(
                                                                '${index + 1}) ${_listApplicants[index].user.name.toString().titleCase()}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12),
                                                              )),
                                                        ),
                                                        SizedBox(width: 8),
                                                        IconButton(
                                                          onPressed: (() {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        ViewProfile(
                                                                          id: _listApplicants[index]
                                                                              .user
                                                                              .userId
                                                                              .toString(),
                                                                        )));
                                                          }),
                                                          icon: FaIcon(
                                                            FontAwesomeIcons
                                                                .solidCircleQuestion,
                                                            color: themeData2()
                                                                .primaryColor,
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          )
                                        :
                                        // isComplete()
                                        //     ? Column(
                                        //         //job completed
                                        //         // mainAxisAlignment:
                                        //         //     MainAxisAlignment.center,
                                        //         // crossAxisAlignment:
                                        //         //     CrossAxisAlignment.center,
                                        //         children: [
                                        //           Heading2(
                                        //               'Provider'), //complete on 1
                                        //           Text(_userProvidor.user.name
                                        //               .toString()
                                        //               .titleCase()),
                                        //           Text(
                                        //               'Completed On: ${dateCompletedOn.day}-${dateCompletedOn.month}-${dateCompletedOn.year}'),
                                        //           Text(
                                        //               'Time: ${dateCompletedOn.hour}:${dateCompletedOn.minute}:${dateCompletedOn.second}')
                                        //         ],
                                        //       )
                                        //     :
                                        Column(
                                            //when requestor select provider
                                            children: [
                                              Container(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'Provider Selected',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: themeData2()
                                                            .primaryColor),
                                                  )),
                                              SizedBox(height: 5),
                                              isNull(requestDetails
                                                      .request.provider)
                                                  ? Text('No provider selected')
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(3, 3, 3, 6),
                                                      child: TextButton(
                                                        style: themeData2()
                                                            .textButtonTheme
                                                            .style,
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ViewProfile(
                                                              id: _userProvidor
                                                                  .user.userId
                                                                  .toString(),
                                                            ),
                                                          ));
                                                        },
                                                        child: Text(
                                                            _userProvidor
                                                                .user.name
                                                                .toString()
                                                                .titleCase()),
                                                      ),
                                                    )
                                            ],
                                          ),
                                CustomDivider(color: themeData2().primaryColor),
                                //SizedBox(height: 8),
                                isPending() //when has no applicants
                                    ? Column(
                                        children: [
                                          ElevatedButton(
                                              style: themeData2()
                                                  .elevatedButtonTheme
                                                  .style,
                                              onPressed: () {
                                                context.showSnackBar(
                                                    message: 'Job updated!!!');
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                  'Update Job Details (coming soon)')),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey),
                                              onPressed: () {},
                                              child:
                                                  Text('Job is still pending')),
                                        ],
                                      )
                                    : isComplete() //when request is complete
                                        ? isRated() //still for request
                                            ? isProviderRated()
                                                ? Text(
                                                    'You have rated the provider.')
                                                : Column(children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'Rate the provider',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: RatingBar.builder(
                                                        initialRating: 0,
                                                        itemBuilder:
                                                            (context, index) =>
                                                                Icon(
                                                          Icons.star,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        onRatingUpdate:
                                                            (value) {
                                                          _value1Controller =
                                                              value;
                                                          //print(_valueController);
                                                        },
                                                      ),
                                                    ),
                                                    TextFormField(
                                                      controller:
                                                          _comment1Controller,
                                                      decoration: InputDecoration(
                                                          hintText:
                                                              'Enter comment'),
                                                    ),
                                                    ElevatedButton(
                                                        style: themeData2()
                                                            .elevatedButtonTheme
                                                            .style,
                                                        onPressed: () {
                                                          //print(ratedUser);
                                                          // print(user);
                                                          // print(
                                                          //     _value1Controller.toInt());
                                                          // print(_comment1Controller.text);
                                                          // print(id);
                                                          _rateProvider(
                                                              widget.user,
                                                              _value1Controller
                                                                  .toInt(),
                                                              _comment1Controller
                                                                  .text,
                                                              requestDetails
                                                                  .request.id);
                                                        },
                                                        child: Text(
                                                            'Rate Provider'))
                                                  ])
                                            : Column(
                                                children: [
                                                  Heading2(
                                                      'The job is completed'),

                                                  Text(
                                                      'Completed On: ${dateCompletedOn.day}-${dateCompletedOn.month}-${dateCompletedOn.year}'),
                                                  Text(
                                                      'Time: ${dateCompletedOn.hour}:${dateCompletedOn.minute}:${dateCompletedOn.second}'), //completed on 2
                                                  //Text(widget.completed),
                                                ],
                                              )
                                        : isOngoing()
                                            ? ElevatedButton(
                                                style: themeData2()
                                                    .elevatedButtonTheme
                                                    .style,
                                                onPressed: () {
                                                  // try {
                                                  //   ClientServiceRequest(
                                                  //           Common().channel)
                                                  //       .startService1(
                                                  //           widget.id,
                                                  //           widget.user);
                                                  //   context.showSnackBar(
                                                  //       message:
                                                  //           'Job Started!!');
                                                  //   Navigator.of(context).pop();
                                                  // } on GrpcError catch (e) {
                                                  //   context.showErrorSnackBar(
                                                  //       message: e.toString());
                                                  // } catch (e) {
                                                  //   context.showErrorSnackBar(
                                                  //       message: e.toString());
                                                  // }

                                                  _completeJob(
                                                      requestDetails.request.id,
                                                      widget.user);
                                                },
                                                child: Text('Complete Job'))
                                            : ElevatedButton(
                                                style: themeData2()
                                                    .elevatedButtonTheme
                                                    .style,
                                                onPressed: () {
                                                  try {
                                                    ClientServiceRequest(
                                                            Common().channel)
                                                        .startService1(
                                                            requestDetails
                                                                .request.id,
                                                            widget.user);
                                                    context.showSnackBar(
                                                        message:
                                                            'Job Started!!');
                                                    Navigator.of(context).pop();
                                                  } on GrpcError catch (e) {
                                                    context.showErrorSnackBar(
                                                        message: e.toString());
                                                  } catch (e) {
                                                    context.showErrorSnackBar(
                                                        message: e.toString());
                                                  }

                                                  // _completeJob(
                                                  //     widget.id, widget.user);
                                                },
                                                child: Text('Start Job')),

                                // : Container(
                                //     padding: EdgeInsets.all(5),
                                //     decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.circular(5),
                                //         border: Border.all(
                                //             width: 2,
                                //             color: Theme.of(context)
                                //                 .primaryColor)),
                                //     child: Text('Job Not Complete')),
                                isNull(requestDetails.request.provider)
                                    ? TextButton(
                                        style:
                                            themeData2().textButtonTheme.style,
                                        onPressed: () {
                                          _deleteRequest(
                                              requestDetails.request.id);
                                        },
                                        child: Text('Delete Job'))
                                    : isComplete()
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                                style: themeData2()
                                                    .textButtonTheme
                                                    .style,
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        RateGivenPage(),
                                                  ));
                                                },
                                                child:
                                                    Text('Go to rating page')),
                                          )
                                        : TextButton(
                                            style: themeData2()
                                                .textButtonTheme
                                                .style,
                                            onPressed: () {
                                              _deleteRequest(
                                                  requestDetails.request.id);
                                              context.showSnackBar(
                                                  message: 'Job Deleted');
                                              Navigator.of(context).pop();
                                              //Navigator.of(context).popUntil((route) => route.i);
                                              //Navigator.of(context).pushNamed('/navigation');
                                            },
                                            child: Text('Abort Job')),
                              ],
                            ),
                          ),
                        )
                      : isComplete() //isRequestcomplete?
                          ? Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Heading2('Completed On'),
                                    Text(
                                        'Completed On: ${dateCompletedOn.day}-${dateCompletedOn.month}-${dateCompletedOn.year}'),
                                    Text(
                                        'Time: ${dateCompletedOn.hour}:${dateCompletedOn.minute}:${dateCompletedOn.second}'),
                                    // Text(
                                    //   'Rate The requestor',
                                    //   style: TextStyle(
                                    //       fontWeight: FontWeight.bold, fontSize: 15),
                                    // ),
                                    CustomDivider(
                                        color: themeData2().primaryColor),
                                    Heading2('Rate the requestor'),
                                    Text(_userRequestor.user.name
                                        .toString()
                                        .titleCase()),
                                    //SizedBox(height: 5),
                                    isRated() //for providor
                                        ? isRequestorRated()
                                            ? Text('Requestor has been rated')
                                            : Column(
                                                children: [
                                                  Center(
                                                    child: RatingBar.builder(
                                                      initialRating: 0,
                                                      itemBuilder:
                                                          (context, index) =>
                                                              Icon(
                                                        Icons.star,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                      onRatingUpdate: (value) {
                                                        _valueController =
                                                            value;
                                                        //print(_valueController);
                                                      },
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    controller:
                                                        _commentController,
                                                    decoration: InputDecoration(
                                                        hintText:
                                                            'Enter comment'),
                                                  ),
                                                  ElevatedButton(
                                                      style: themeData2()
                                                          .elevatedButtonTheme
                                                          .style,
                                                      onPressed: () {
                                                        _rateRequestor(
                                                            widget.user,
                                                            _valueController
                                                                .toInt(),
                                                            _commentController
                                                                .text,
                                                            requestDetails
                                                                .request.id);
                                                      },
                                                      child: Text(
                                                          'Rate Requestor')),
                                                ],
                                              )
                                        : Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: TextButton(
                                                style: themeData2()
                                                    .textButtonTheme
                                                    .style,
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                        builder: (context) =>
                                                            RateGivenPage(),
                                                      ))
                                                      .then((value) => setState(
                                                            () {
                                                              //_isEmpty = true;
                                                              _getAllinstance();
                                                            },
                                                          ));
                                                },
                                                child:
                                                    Text('Go to rating page')),
                                          )
                                  ],
                                ),
                              ),
                            )
                          : isOngoing()
                              ? Center(
                                  child: Text(
                                      'You are currently taking this Job...'))
                              : Card(
                                  //sini oi the service
                                  elevation: 5,
                                  child: Column(
                                    children: [
                                      Heading2('Interested in the job?'),
                                      ElevatedButton(
                                          style: themeData2()
                                              .elevatedButtonTheme
                                              .style,
                                          onPressed: () {
                                            // print(widget.id);
                                            // print(widget.user);
                                            applyJob(requestDetails.request.id,
                                                widget.user);
                                          },
                                          child: Text('Request Job')),
                                    ],
                                  ),
                                ),

                  Container(
                      alignment: Alignment.center,
                      child: Heading2('Other Information')),
                  Heading2('Category'),
                  Text(requestDetails.request.category),
                  Heading2('Description'),
                  Text(requestDetails.request.description
                      .toString()
                      .capitalize()),
                  Heading2('Location'),
                  Text(
                      'Address: ${requestDetails.request.location.name.toString()}'),
                  Text('State: ' +
                      requestDetails.request.location.coordinate.latitude),
                  Text('City: ' +
                      requestDetails.request.location.coordinate.longitude),
                  Heading2('Media'),
                  isNull(requestDetails.request.mediaAttachments)
                      ? Text('No Attachment')
                      : SizedBox(
                          //height: 50,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount:
                                requestDetails.request.mediaAttachments.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Text(
                                      '${index + 1}) ${requestDetails.request.mediaAttachments[index].toString()}'),
                                ],
                              );
                            },
                          ),
                        ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Heading2('Updated On'),
                          Text(
                              'Date: ${dateUpdatedOn.day}-${dateUpdatedOn.month}-${dateUpdatedOn.year}\nTime: ${dateUpdatedOn.hour}:${dateUpdatedOn.minute}'),
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