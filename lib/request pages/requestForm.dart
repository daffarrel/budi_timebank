import 'package:csc_picker/csc_picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:grpc/grpc.dart';
import '../bin/client_service_request.dart';
import '../components/constants.dart';
import '../custom%20widgets/customHeadline.dart';
import '../custom%20widgets/theme.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../bin/common.dart';

//map API
//https://levelup.gitconnected.com/how-to-add-google-maps-in-a-flutter-app-and-get-the-current-location-of-the-user-dynamically-2172f0be53f6

class RequestForm extends StatefulWidget {
  const RequestForm({Key? key}) : super(key: key);

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  //store user input
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _locationController = TextEditingController();
  final _rateController = TextEditingController();
  final _mediaController = TextEditingController();
  final _dateControllerDisplay = TextEditingController();
  final _dateController = TextEditingController();
  final _timeLimitController = TextEditingController();

  final DateTime _dateTime = DateTime.now();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> mediaList = [];
  List<String> listCategories = <String>[
    'Arts, Crafts & Music',
    'Business Services',
    'Community Activities',
    'Companionship',
    'Education',
    'Help at Home',
    'Recreation',
    'Transportation',
    'Wellness',
  ];

  late String address;
  late String location1;
  late DateTime? newDate;
  late TimeOfDay? newTime;

  late String countryValue = '';
  late String stateValue = '';
  late String cityValue = '';

  late bool isLocationFetched;
  late bool isLoad;

  @override
  void initState() {
    isLoad = false;
    isLocationFetched = false;
    _categoryController.text = listCategories[2];
    // TODO: implement initState
    super.initState();
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

  //Method to get full address from latitude & longitude co-ordinates (lat long to address)
  Future<void> GetAddressFromLatLong(Position position) async {
    setState(() {
      isLoad = true;
    });
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}';
      // print('State: ${place.administrativeArea}');
      // print("City: ${place.locality}");
      // // print(place.country);
      // print(place);
      countryValue = place.country.toString();
      cityValue = place.locality.toString();
      stateValue = place.administrativeArea.toString();
      // _stateController.text = place.administrativeArea.toString();
      // _cityController.text = place.locality.toString();
      // _locationController.text = address;

      setState(() {
        // countryValue = place.country.toString();
        // cityValue = place.locality.toString();
        // stateValue = place.administrativeArea.toString();
        _stateController.text = stateValue;
        _cityController.text = cityValue;
        _locationController.text = address;
        //print(countryValue);
        //CSCPicker.onCountryChanged

        //print(isLocationFetched);
        // print(_stateController.text);
        // print(_cityController.text);
        isLocationFetched = true;
        isLoad = false;
      });
      context.showSnackBar(message: 'Location details added!!');
    } catch (e) {
      context.showErrorSnackBar(message: e.toString());
    }

    //print(Address);
  }

  // Future<void> GetLatLongfromAddress(String location) async {
  //   try {
  //     List<Location> locations = await locationFromAddress(location);
  //     setState(() {
  //       // _stateController.text = locations[0].latitude.toString();
  //       // _cityController.text = locations[0].longitude.toString();
  //       //_locationController.text = Address;
  //     });
  //     context.showSnackBar(message: 'Location details added!!');
  //   } catch (e) {
  //     context.showErrorSnackBar(message: e.toString());
  //   }

  //   //sprint(locations[0].latitude);
  //   //print(placemarks);
  //   // Placemark place = locations[0];
  //   // Address =
  //   //     '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
  //   //print(Address);
  // }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    // _stateController.dispose();
    // _cityController.dispose();
    // _locationController.dispose();
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
          // backgroundColor: Color.fromARGB(255, 127, 17, 224),
        ),
        body: isLoad
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                              child: CustomHeadline(heading: 'Title'),
                            ),
                            CustomHeadline(
                              heading: '*',
                              color: Colors.red,
                            )
                          ],
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
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                              child: CustomHeadline(heading: 'Desription'),
                            ),
                            CustomHeadline(
                              heading: '*',
                              color: Colors.red,
                            )
                          ],
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
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                              child: CustomHeadline(heading: 'Date & Time'),
                            ),
                            CustomHeadline(
                              heading: '*',
                              color: Colors.red,
                            )
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () {
                              DatePicker.showDateTimePicker(context,
                                  theme: DatePickerTheme(
                                      doneStyle: TextStyle(
                                          color: themeData1().primaryColor)),
                                  showTitleActions: true,
                                  minTime: DateTime(
                                      _dateTime.year,
                                      _dateTime.month,
                                      _dateTime.day,
                                      _dateTime.hour,
                                      _dateTime.minute,
                                      _dateTime.second),
                                  maxTime:
                                      _dateTime.add(const Duration(days: 365)),
                                  onChanged: (date) {
                                //print('change $date');
                              }, onConfirm: (date) {
                                _dateController.text = date.toString();
                                print(_dateController.text);
                                _dateControllerDisplay.text =
                                    'Date: ${date.day}-${date.month}-${date.year} Time: ${date.hour.toString().padLeft(2, '0')} : ${date.minute.toString().padLeft(2, '0')}';
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            child: const Text(
                              'Pick date & time',
                              //style: TextStyle(color: Colors.blue),
                            )),
                        const SizedBox(height: 8),
                        TextFormField(
                          enabled: false,
                          controller: _dateControllerDisplay,
                          decoration: const InputDecoration(
                              errorStyle: TextStyle(
                                color: Colors.red, // or any other color
                              ),
                              border: OutlineInputBorder(),
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
                        ),
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                              child: CustomHeadline(heading: 'Category'),
                            ),
                            CustomHeadline(
                              heading: '*',
                              color: Colors.red,
                            )
                          ],
                        ),
                        Container(
                          alignment: Alignment.center,
                          //padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              )),
                          child: DropdownButton<String>(
                            underline: Container(
                              height: 0,
                            ),
                            iconEnabledColor: Theme.of(context).primaryColor,
                            value: _categoryController.text,
                            items: listCategories
                                .map<DropdownMenuItem<String>>((e) {
                              return DropdownMenuItem<String>(
                                  value: e,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
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
                                _categoryController.text = value.toString();
                                //print(_genderController.text);
                              });
                            },
                          ),
                        ),
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                              child: CustomHeadline(heading: 'Location'),
                            ),
                            CustomHeadline(
                              heading: '*',
                              color: Colors.red,
                            )
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Enter address of the job or get current location'),
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

                        isLocationFetched
                            ? CSCPicker(
                                // showCities: true,

                                defaultCountry: CscCountry.Malaysia,
                                disableCountry: true,
                                currentState: stateValue,
                                currentCity: cityValue,
                                layout: Layout.vertical,
                                dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    )),
                                cityDropdownLabel: _cityController.text,
                                stateDropdownLabel: _stateController.text,

                                // dropdownItemStyle: TextStyle,
                                // stateSearchPlaceholder: ,
                                // dropdownHeadingStyle: ,

                                onCountryChanged: (value) {
                                  setState(() {
                                    countryValue = value;
                                    //_locationController.text = ''
                                  });
                                },
                                onStateChanged: (value) {
                                  setState(() {
                                    stateValue = value.toString();
                                    //_stateController.text = stateValue;
                                  });
                                },
                                onCityChanged: (value) {
                                  setState(() {
                                    cityValue = value.toString();
                                    //_cityController.text = cityValue;
                                  });
                                },
                              )
                            : CSCPicker(
                                // showCities: true,

                                defaultCountry: CscCountry.Malaysia,
                                disableCountry: true,
                                currentState: stateValue,
                                currentCity: cityValue,
                                layout: Layout.vertical,
                                dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    )),
                                cityDropdownLabel: 'Pick a City',
                                stateDropdownLabel: 'Pick a State',

                                // dropdownItemStyle: TextStyle,
                                // stateSearchPlaceholder: ,
                                // dropdownHeadingStyle: ,

                                onCountryChanged: (value) {
                                  setState(() {
                                    countryValue = value;
                                    //_locationController.text = ''
                                  });
                                },
                                onStateChanged: (value) {
                                  setState(() {
                                    stateValue = value.toString();
                                    _stateController.text = stateValue;
                                  });
                                },
                                onCityChanged: (value) {
                                  setState(() {
                                    cityValue = value.toString();
                                    _cityController.text = cityValue;
                                  });
                                },
                              ),
                        Row(
                          children: [
                            // Expanded(
                            //   child: ElevatedButton(
                            //       onPressed: () async {
                            //         GetLatLongfromAddress(_locationController.text);
                            //       },
                            //       child: Text('Enter Address')),
                            // ),
                            // SizedBox(width: 5),
                            Expanded(
                              child: ElevatedButton(
                                  onPressed: () async {
                                    Position position =
                                        await _getGeoLocationPosition();
                                    GetAddressFromLatLong(position);
                                  },
                                  child: isLoad
                                      ? const Text('Loading...')
                                      : const Text('Get current location')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: CustomHeadline(heading: 'Country & State & City'),
                        // ),
                        // TextFormField(
                        //   controller: _locationController,
                        //   enabled: false,
                        //   decoration: InputDecoration(
                        //       errorStyle: TextStyle(
                        //         color: Colors.red, // or any other color
                        //       ),
                        //       border: OutlineInputBorder(),
                        //       labelText: 'Address'),
                        //   // validator: (value) {
                        //   //   if (value == null || value.isEmpty) {
                        //   //     return 'Please enter location...';
                        //   //   }
                        //   //   return null;
                        //   // },
                        // ),
                        // SizedBox(height: 15),

                        // // SelectState(
                        // //   //dropdownColor: themeData1().primaryColor,
                        // //   // style: ,
                        // //   onCountryChanged: (value) {
                        // //     setState(() {
                        // //       countryValue = value;
                        // //     });
                        // //   },
                        // //   onStateChanged: (value) {
                        // //     setState(() {
                        // //       stateValue = value;
                        // //     });
                        // //   },
                        // //   onCityChanged: (value) {
                        // //     setState(() {
                        // //       cityValue = value;
                        // //     });
                        // //   },
                        // // ),
                        // // SizedBox(height: 8),
                        // TextFormField(
                        //   controller: _stateController,
                        //   enabled: false,
                        //   decoration: InputDecoration(
                        //     errorStyle: TextStyle(
                        //       color: Colors.red, // or any other color
                        //     ),
                        //     border: OutlineInputBorder(),
                        //     labelText: 'State',
                        //     //prefixIcon: Icon(Icons.map)
                        //   ),
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Tap "Enter Address" to obtain latitude';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        // SizedBox(height: 15),
                        // TextFormField(
                        //   controller: _cityController,
                        //   enabled: false,
                        //   decoration: InputDecoration(
                        //       errorStyle: TextStyle(
                        //         color: Colors.red, // or any other color
                        //       ),
                        //       border: OutlineInputBorder(),
                        //       labelText: 'City'),
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Tap "Enter Address" to obtain longitude';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        // SizedBox(height: 8),

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
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                              child: CustomHeadline(heading: 'Time Limit'),
                            ),
                            CustomHeadline(
                              heading: '*',
                              color: Colors.red,
                            )
                          ],
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
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                              child: CustomHeadline(heading: 'Rate'),
                            ),
                            CustomHeadline(
                              heading: '*',
                              color: Colors.red,
                            )
                          ],
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
                            // Expanded(
                            //   child: TextFormField(
                            //     controller: _titleController,
                            //     keyboardType: TextInputType.number,
                            //     decoration: InputDecoration(
                            //         border: OutlineInputBorder(),
                            //         hintText: 'Enter time limit (hours)'),
                            //     validator: (value) {
                            //       if (value == null || value.isEmpty) {
                            //         return 'Please enter time limit';
                            //       }
                            //       return null;
                            //     },
                            //     // onFieldSubmitted: (value) {
                            //     //   reqList[0]['Title'] = value;
                            //     // },
                            //   ),
                            // ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('\$ Time/hour'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                            onPressed: () async {
                              final user = supabase.auth.currentUser!.id;
                              // print(_stateController.text);
                              // print(_cityController.text);
                              //final _userCurrent = getCurrentUser(user);
                              //print(_userCurrent);
                              // print(stateValue == 'null');
                              //  else if (_cityController.text == 'null') {
                              //   context.showErrorSnackBar(
                              //       message: 'Pick a city..');
                              // }
                              if (_stateController.text == 'null') {
                                context.showErrorSnackBar(
                                    message: 'Pick a state..');
                              } else if (_formKey.currentState!.validate()) {
                                var rate = double.parse(
                                    _rateController.text); //convert to double
                                var time =
                                    double.parse(_timeLimitController.text);

                                _submitJobForm(
                                    _titleController.text,
                                    _descriptionController.text,
                                    _stateController.text,
                                    _cityController.text,
                                    _locationController.text,
                                    rate,
                                    mediaList,
                                    user,
                                    _categoryController.text,
                                    time,
                                    _dateController.text);
                              }
                            },
                            child: const Text('Create Request')),
                      ],
                    ),

                    // SizedBox(
                    //   height: 20,
                    // ),
                  ),
                ),
              ));
  }

  Future<void> _submitJobForm(
      String title,
      String description,
      String latitude,
      String longitude,
      String locName,
      double rate,
      List<String> media,
      String requestor,
      String category,
      double timeLimit,
      String date) async {
    try {
      await ClientServiceRequest(Common().channel).createServiceRequest(
          title,
          description,
          latitude,
          longitude,
          locName,
          rate,
          media,
          requestor,
          category,
          timeLimit,
          date);
      //print(test);
      //dprint(test.toProto3Json());
      context.showSnackBar(message: 'Job Created');
      Navigator.of(context).pop();
    } on GrpcError catch (e) {
      context.showErrorSnackBar(message: '${e.message}');
      print(e.toString());
    } catch (e) {
      context.showErrorSnackBar(message: e.toString());
      print(e.toString());
    }
  }
}
