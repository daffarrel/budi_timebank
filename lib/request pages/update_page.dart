import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../components/constants.dart';
import '../custom widgets/custom_headline.dart';
import '../custom%20widgets/heading2.dart';
import '../components/app_theme.dart';
import '../my_extensions/extension_string.dart';

class UpdatePage extends StatefulWidget {
  final String id;
  const UpdatePage({super.key, required this.id});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  void initState() {
    super.initState();
    //print(_dateControllerDisplay.text);

    _elementController.text = listElement[0];
    _categoryController.text = listCategories[0];
  }

  final _elementController = TextEditingController();
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

  late String countryValue = '';
  late String stateValue = '';
  late String cityValue = '';

  final DateTime _dateTime = DateTime.now();

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

  List<String> listElement = <String>[
    'title',
    'category',
    'description',
    'location',
    'date'
  ];

  updateJob(String body) async {
    if (body == '') {
      context.showErrorSnackBar(message: 'Update value cant be empty');
      Navigator.of(context).pop();
    }

    // TODO: implement edit service request
    // await ClientServiceRequest(Common().channel)
    //     .updateService(widget.id, body);
    context.showSnackBar(message: 'Job Updated');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Update Request'),
          backgroundColor: AppTheme.themeData.primaryColor),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Heading2('Pick element to update'),
          Container(
            alignment: Alignment.center,
            //padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppTheme.themeData.primaryColor,
                  width: 2,
                )),
            child: DropdownButton<String>(
              underline: Container(
                height: 0,
              ),
              iconEnabledColor: AppTheme.themeData.primaryColor,
              value: _elementController.text,
              items: listElement.map<DropdownMenuItem<String>>((e) {
                return DropdownMenuItem<String>(
                    value: e,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        e.toString().capitalize(),
                        style: TextStyle(
                            color: AppTheme.themeData.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _elementController.text = value.toString();
                  //print(_genderController.text);
                });
              },
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              if (_elementController.text == listElement[0]) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CustomHeadline('Update Title'),
                    ),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter Title'),
                      // validator: (value) {
                      //   if (value == null ||
                      //       value.isEmpty ||
                      //       _titleController.text == '') {
                      //     return 'Please enter title...';
                      //   }
                      //   return null;
                      // },
                      // onFieldSubmitted: (value) {
                      //   reqList[0]['Title'] = value;
                      // },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                        style: AppTheme.themeData2.elevatedButtonTheme.style,
                        onPressed: (() {
                          if (_titleController.text == '') {
                            context.showErrorSnackBar(
                                message: 'Please Enter Title...');
                          } else {
                            updateJob(
                                '{"title": "${_titleController.text.toString()}"}');
                          }
                        }),
                        child: const Text('Update Title'))
                  ],
                );
              } else if (_elementController.text == listElement[1]) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CustomHeadline('Pick category'),
                      Container(
                        alignment: Alignment.center,
                        //padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppTheme.themeData.primaryColor,
                              width: 2,
                            )),
                        child: DropdownButton<String>(
                          underline: Container(
                            height: 0,
                          ),
                          iconEnabledColor: AppTheme.themeData.primaryColor,
                          value: _categoryController.text,
                          items:
                              listCategories.map<DropdownMenuItem<String>>((e) {
                            return DropdownMenuItem<String>(
                                value: e,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                        color: AppTheme.themeData.primaryColor,
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
                      ElevatedButton(
                          style: AppTheme.themeData.elevatedButtonTheme.style,
                          onPressed: (() {
                            updateJob(
                                '{"category": "${_categoryController.text.toString()}"}');
                          }),
                          child: const Text('Update Category'))
                    ],
                  ),
                );
              } else if (_elementController.text == listElement[2]) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CustomHeadline('Update Description'),
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter Description'),

                      // onFieldSubmitted: (value) {
                      //   reqList[0]['Title'] = value;
                      // },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                        style: AppTheme.themeData.elevatedButtonTheme.style,
                        onPressed: (() {
                          if (_descriptionController.text == '') {
                            context.showErrorSnackBar(
                                message: 'Please Enter Description');
                          } else {
                            updateJob(
                                '{"description": "${_descriptionController.text.toString()}"}');
                          }
                        }),
                        child: const Text('Update Description'))
                  ],
                );
              } else if (_elementController.text == listElement[3]) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 15),
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
                    const SizedBox(height: 15),
                    // TODO: Betulkan balik
                    // CSCPicker(
                    //   // showCities: true,

                    //   defaultCountry: CscCountry.Malaysia,
                    //   disableCountry: true,
                    //   currentState: stateValue,
                    //   currentCity: cityValue,
                    //   layout: Layout.vertical,
                    //   dropdownDecoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(10),
                    //       border: Border.all(
                    //         color: AppTheme.themeData.primaryColor,
                    //         width: 2,
                    //       )),
                    //   cityDropdownLabel: 'Pick a City',
                    //   stateDropdownLabel: 'Pick a State',

                    //   // dropdownItemStyle: TextStyle,
                    //   // stateSearchPlaceholder: ,
                    //   // dropdownHeadingStyle: ,

                    //   onCountryChanged: (value) {
                    //     setState(() {
                    //       countryValue = value;
                    //       //_locationController.text = ''
                    //     });
                    //   },
                    //   onStateChanged: (value) {
                    //     setState(() {
                    //       stateValue = value.toString();
                    //       _stateController.text = stateValue;
                    //     });
                    //   },
                    //   onCityChanged: (value) {
                    //     setState(() {
                    //       cityValue = value.toString();
                    //       _cityController.text = cityValue;
                    //     });
                    //   },
                    // ),
                    ElevatedButton(
                        style: AppTheme.themeData.elevatedButtonTheme.style,
                        onPressed: (() {
                          if (_locationController.text == 'null' ||
                              _stateController.text == 'null') {
                            context.showErrorSnackBar(
                                message: 'Please full Address...');
                          } else {
                            updateJob(
                                '{"location":{"address": "${_locationController.text.toString()}", "city" : "${_cityController.text.toString()}", "state": "${_stateController.text.toString()}"}}');
                          }
                        }),
                        child: const Text('Update Location'))
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                        style: AppTheme.themeData.elevatedButtonTheme.style,
                        onPressed: () {
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
                            _dateController.text = date.toString();
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
                    TextFormField(
                      enabled: false,
                      controller: _dateControllerDisplay,
                      decoration: const InputDecoration(
                          errorStyle: TextStyle(
                            color: Colors.red, // or any other color
                          ),
                          border: OutlineInputBorder(),
                          hintText: 'Date & Time'),
                    ),
                    ElevatedButton(
                        style: AppTheme.themeData.elevatedButtonTheme.style,
                        onPressed: (() {
                          if (_dateControllerDisplay.text == '') {
                            context.showErrorSnackBar(
                                message: 'Enter Date & Time');
                          } else {
                            updateJob(
                                '{"date": "${_dateController.text.toString()}"}');
                          }
                        }),
                        child: const Text('Update Date & Time'))
                  ],
                );
              }
            },
          ),
        ]),
      ),
    );
  }
}
