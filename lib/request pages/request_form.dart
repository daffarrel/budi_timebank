import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../components/constants.dart';
import '../custom widgets/custom_headline.dart';
import '../components/app_theme.dart';
import '../db_helpers/client_service_request.dart';
import '../model/service_request.dart' as model;
import '../shared/community_list.dart';
import '../shared/job_categories.dart';
import '../shared/malaysia_state.dart';
import 'map_editor.dart';

class RequestForm extends StatefulWidget {
  const RequestForm({super.key});

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  //store user input
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _rateController = TextEditingController();
  final _mediaController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeLimitController = TextEditingController();

  late String _selectedCategory;
  late String _selectedCommunity;

  final DateTime _dateTime = DateTime.now();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> mediaList = [];

  DateTime? selectedDate;

  late String address;
  late String location1;
  late DateTime? newDate;
  late TimeOfDay? newTime;

  List<String> states = MalaysiaState.allStatesName();
  List<String>? districtsInSelectedState;

  // late String countryValue = '';
  String? stateValue;
  String? districtValue;

  // late MapController _mapController;
  late bool isLocationFetched;
  late bool isLoad;
  bool isDetectingLocation = false;
  LatLng? _currentPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    isLoad = false;
    isLocationFetched = false;
    _selectedCategory = kJobCategories.first;
    _selectedCommunity = kCommunityList.first;
    // _mapController = MapController.withPosition(
    //   initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
    // );
  }

  //get geo location
  //Flutter method to get current user latitude & longitude location
  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Method to get full address from latitude & longitude co-ordinates (lat long to address)
  Future<void> getAddressFromLatLong(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      final locationAddress = [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
      ]
          .where((element) => element != null && element.isNotEmpty)
          .toSet()
          .toList();

      _locationController.text = locationAddress.join(', ');

      var state = place.administrativeArea;

      setState(() {
        // countryValue = place.country.toString();
        if (state!.contains('Wilayah Persekutuan') ||
            state.contains('Federal Territory')) {
          stateValue =
              'Wilayah Persekutuan'; // must match the value in MalaysiaState

          if (state.contains('Kuala Lumpur')) {
            districtValue = 'Kuala Lumpur';
          } else if (state.contains('Labuan')) {
            districtValue = 'Labuan';
          } else if (state.contains('Putrajaya')) {
            districtValue = 'Putrajaya';
          }
        } else {
          stateValue = place.administrativeArea.toString();
          districtValue = null;
        }

        districtsInSelectedState = MalaysiaState.districtsForState(stateValue!);

        print(place);

        // only assign the value if known, otherwise, it is up to the user to select
        if (districtsInSelectedState!.contains(place.subAdministrativeArea)) {
          districtValue = place.subAdministrativeArea;
        } else if (districtsInSelectedState!.contains(place.locality)) {
          districtValue = place.locality;
        } else if (districtsInSelectedState!.contains(place.subLocality)) {
          districtValue = place.subLocality;
        }
      });
      if (mounted) context.showSnackBar(message: 'Location details added');
    } catch (e) {
      context.showErrorSnackBar(message: e.toString());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rateController.dispose();
    _mediaController.dispose();

    super.dispose();
  }

  _addmedia(String media) {
    setState(() {
      mediaList.insert(0, media);
    });
  }

  _deleteMedia(String media) {
    setState(() {
      mediaList.removeWhere((element) => element == media);
    });
  }

  _isMediaEmpty(dynamic media) {
    if (media.length == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Request Form'),
      ),
      body: isLoad
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                        child: CustomHeadline('Title', isRequired: true),
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Title'),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              _titleController.text == '') {
                            return 'Please enter title...';
                          }
                          return null;
                        },
                        // onFieldSubmitted: (value) {
                        //   reqList[0]['Title'] = value;
                        // },
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                        child: CustomHeadline('Description', isRequired: true),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter description of the job',
                          //prefixIcon: Icon(Icons.map)
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description...';
                          }
                          return null;
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                        child: CustomHeadline('Date & Time', isRequired: true),
                      ),
                      TextFormField(
                        enableInteractiveSelection: false,
                        readOnly: true,
                        controller: _dateController,
                        decoration: const InputDecoration(
                            errorStyle: TextStyle(
                              color: Colors.red, // or any other color
                            ),
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                            hintText: 'Date & Time'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please pick a date & time...';
                          }
                          // else if (newDate!.hour == 0 || newDate!.minute == 0) {
                          //   return 'Pick a time';
                          // }
                          return null;
                        },
                        onTap: () {
                          DatePicker.showDateTimePicker(context,
                              theme: DatePickerTheme(
                                  doneStyle: TextStyle(
                                      color: AppTheme.themeData.primaryColor)),
                              showTitleActions: true,
                              minTime: DateTime(
                                  _dateTime.year,
                                  _dateTime.month,
                                  _dateTime.day,
                                  _dateTime.hour,
                                  _dateTime.minute,
                                  _dateTime.second),
                              maxTime: _dateTime.add(const Duration(days: 365)),
                              onChanged: (date) {
                            //print('change $date');
                          }, onConfirm: (date) {
                            setState(() => selectedDate = date);
                            final dateFormatted =
                                DateFormat('dd-MM-yyyy').format(date);
                            final timeFormatted =
                                DateFormat('hh:mm a').format(date);
                            _dateController.text =
                                'Date: $dateFormatted Time: $timeFormatted';
                          },
                              currentTime: DateTime.now(),
                              locale: LocaleType.en);
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                        child: CustomHeadline('Category', isRequired: true),
                      ),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          // to remove the dropdown's underline border
                          underline: Container(height: 0),
                          iconEnabledColor: Theme.of(context).primaryColor,
                          value: _selectedCategory,
                          items:
                              kJobCategories.map<DropdownMenuItem<String>>((e) {
                            return DropdownMenuItem<String>(
                                value: e,
                                child: Center(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value.toString();
                              //print(_genderController.text);
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                        child: CustomHeadline('Community', isRequired: true),
                      ),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: Container(height: 0),
                          iconEnabledColor: Theme.of(context).primaryColor,
                          value: _selectedCommunity,
                          items:
                              kCommunityList.map<DropdownMenuItem<String>>((e) {
                            return DropdownMenuItem<String>(
                                value: e,
                                child: Center(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCommunity = value.toString();
                              //print(_genderController.text);
                            });
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                        child: CustomHeadline('Location', isRequired: true),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            'Enter address of the job or get current location'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() => isDetectingLocation = true);

                          Position position = await _getGeoLocationPosition();
                          if (!kIsWeb) getAddressFromLatLong(position);

                          var latlngPos =
                              LatLng(position.latitude, position.longitude);

                          _mapController.move(latlngPos, 15.5);

                          setState(() {
                            _currentPosition = latlngPos;
                            isLocationFetched = true;
                            isDetectingLocation = false;
                          });
                        },
                        child: isDetectingLocation
                            ? const Text('Loading...')
                            : const Text('Detect my location'),
                      ),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            // helperText:
                            //     'Latitude and longitude of the location will be\nautomatically added',
                            hintText: 'Enter location address'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter location...';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField(
                        value: stateValue,
                        validator: (value) =>
                            value == null ? 'Please select a state...' : null,
                        decoration: const InputDecoration(
                            // enabledBorder: OutlineInputBorder(
                            //     borderSide: BorderSide(
                            //         color: Theme.of(context).primaryColor,
                            //         width: 2)),
                            border: OutlineInputBorder(),
                            hintText: 'Select state'),
                        items: [
                          for (var state in states)
                            DropdownMenuItem(
                              value: state,
                              child: Text(state),
                            )
                        ],
                        onChanged: (value) {
                          setState(() {
                            stateValue = value.toString();

                            districtValue = null;
                            districtsInSelectedState =
                                MalaysiaState.districtsForState(stateValue!);
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField(
                        value: districtValue,
                        validator: (value) => value == null
                            ? 'Please select a district...'
                            : null,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select District'),
                        items: districtsInSelectedState == null
                            ? null
                            : [
                                for (var district in districtsInSelectedState!)
                                  DropdownMenuItem(
                                    value: district,
                                    child: Text(district),
                                  )
                              ],
                        onChanged: (value) {
                          setState(() {
                            districtValue = value.toString();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                                initialCenter: LatLng(
                                    _currentPosition?.latitude ?? 3.035,
                                    _currentPosition?.longitude ?? 102.5),
                                initialZoom: 13.6,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'iium-buditimebank',
                                  tileProvider:
                                      CancellableNetworkTileProvider(),
                                ),
                                MarkerLayer(
                                  markers: [
                                    if (_currentPosition != null)
                                      Marker(
                                        width: 80.0,
                                        height: 80.0,
                                        point: LatLng(
                                            _currentPosition!.latitude,
                                            _currentPosition!.longitude),
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
                            Positioned(
                              right: 3,
                              top: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(170),
                                    borderRadius: BorderRadius.circular(10)),
                                child: TextButton.icon(
                                  onPressed: () async {
                                    LatLng? res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MapEditor(
                                            initialLocation: _currentPosition),
                                      ),
                                    );
                                    if (res == null) return;

                                    _mapController.move(
                                        LatLng(res.latitude, res.longitude),
                                        15.5);
                                    setState(() {
                                      _currentPosition = res;
                                      isLocationFetched = true;
                                    });
                                  },
                                  icon: const Icon(Icons.edit_location_alt),
                                  label: Text(isLocationFetched
                                      ? 'Edit location'
                                      : 'Set location'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: CustomHeadline(heading: 'Attachment'),
                      // ),
                      // Row(
                      //   // mainAxisAlignment: MainAxisAlignment.center,
                      //   // crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       child: TextFormField(
                      //         controller: _mediaController,
                      //         decoration: InputDecoration(
                      //             helperText:
                      //                 'Enter any relevant documents \nrelated to the job',
                      //             border: OutlineInputBorder(),
                      //             hintText: 'Enter attachment'),
                      //       ),
                      //     ),
                      //     Padding(
                      //       padding: const EdgeInsets.only(bottom: 40.0),
                      //       child: TextButton(
                      //           onPressed: () {
                      //             if (_mediaController.text.length == 0) {
                      //               context.showErrorSnackBar(
                      //                   message:
                      //                       'You have not entered any attachment..');
                      //             } else {
                      //               _addmedia(_mediaController.text);
                      //               _mediaController.clear();
                      //             }
                      //           },
                      //           child: Center(child: Icon(Icons.add))),
                      //     )
                      //   ],
                      // ),
                      // _isMediaEmpty(mediaList)
                      //     ? Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child:
                      //             Text('You have not entered any attachment'),
                      //       )
                      //     : SizedBox(
                      //         height: 60,
                      //         child: ListView.builder(
                      //           physics: const BouncingScrollPhysics(),
                      //           scrollDirection: Axis.horizontal,
                      //           shrinkWrap: true,
                      //           itemCount: mediaList.length,
                      //           itemBuilder: (context, index) {
                      //             return Card(
                      //               child: Padding(
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: Row(
                      //                   children: [
                      //                     Text(mediaList[index]
                      //                         .toString()
                      //                         .titleCase()),
                      //                     SizedBox(
                      //                       height: 5,
                      //                     ),
                      //                     IconButton(
                      //                         onPressed: () {
                      //                           _deleteMedia(mediaList[index]
                      //                               .toString());
                      //                         },
                      //                         icon: Icon(
                      //                           Icons.remove_circle_outline,
                      //                           color: Colors.red,
                      //                         ))
                      //                   ],
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //         )),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                        child: CustomHeadline('Time Limit', isRequired: true),
                      ),
                      TextFormField(
                        controller: _timeLimitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            helperText: 'Time required to finish the request',
                            hintText: 'Enter time limit (hours)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter time limit';
                          }
                          return null;
                        },
                        // onFieldSubmitted: (value) {
                        //   reqList[0]['Title'] = value;
                        // },
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                        child: CustomHeadline('Rate', isRequired: true),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rateController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter Rate',
                                  helperText:
                                      'Make sure you have enough \$ to pay'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter rate..';
                                }
                                return null;
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('\$ Time/hour'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_currentPosition == null) {
                            context.showErrorSnackBar(
                                message: 'Please set coordinate on map');
                            return;
                          }
                          if (!_formKey.currentState!.validate()) {
                            context.showErrorSnackBar(
                                message: 'Fill in all the particulars...');
                            return;
                          }

                          var rate = double.parse(
                              _rateController.text); //convert to double
                          var time = double.parse(_timeLimitController.text);

                          var requestorId =
                              FirebaseAuth.instance.currentUser!.uid;

                          var request = model.ServiceRequest(
                            title: _titleController.text,
                            description: _descriptionController.text,
                            location: model.Location(
                              coordinate: firestore.GeoPoint(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude),
                              address: _locationController.text,
                              district: districtValue!,
                              state: stateValue!,
                            ),
                            status: model.ServiceRequestStatus.pending,
                            rate: rate,
                            media: mediaList,
                            requestorId: requestorId,
                            applicants: [],
                            category: _selectedCategory,
                            communityType: _selectedCommunity,
                            timeLimit: time,
                            date: selectedDate!,
                            createdAt: DateTime.now(),
                          );

                          _submitJobForm(request);
                        },
                        child: const Text('Create Request'),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _submitJobForm(model.ServiceRequest serviceRequest) async {
    try {
      ClientServiceRequest.submitJob(serviceRequest);
      context.showSnackBar(message: 'Job Created');
      Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      context.showErrorSnackBar(message: '${e.message}');
    } catch (e) {
      context.showErrorSnackBar(message: e.toString());
    }
  }
}
