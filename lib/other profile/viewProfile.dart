import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:testfyp/bin/client_user.dart';
import 'package:testfyp/bin/common.dart';
import 'package:testfyp/custom%20widgets/customHeadline.dart';
import 'package:testfyp/custom%20widgets/ratingCardDetails1.dart';
import 'package:testfyp/custom%20widgets/theme.dart';
import 'package:testfyp/extension_string.dart';

import '../profile pages/contactIconWidget.dart';
import '../profile pages/emptyCardWidget.dart';
import '../profile pages/listViewContact.dart';

class ViewProfile extends StatefulWidget {
  final String id;
  const ViewProfile({super.key, required this.id});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  late dynamic profile;
  late List<String> skills;
  late List<dynamic> email;
  late List<dynamic> phone;
  late List<dynamic> twitter;
  late List<dynamic> whatsapp;

  //late final dynamic contacts = [];

  bool isLoad = true;
  @override
  void initState() {
    getInstance();
    // TODO: implement initState
    super.initState();
  }

  getInstance() async {
    profile = await ClientUser(Common().channel).getProfile1(widget.id);
    // print(profile);
    // print('the type is : ' + profile.user.profile.contacts[0].type.toString());
    skills = [];
    email = [];
    phone = [];
    twitter = [];
    whatsapp = [];
    //print(profile.user.profile.skills);
    for (int i = 0; i < profile.user.profile.skills.length; i++) {
      skills.add(profile.user.profile.skills[i]);
    }
    for (int i = 0; i < profile.user.profile.contacts.length; i++) {
      //print(data['contacts'][i]['type'].toString() == 'Email');
      if (profile.user.profile.contacts[i].type.toString() == 'Email') {
        //print("ui");
        email.add(profile.user.profile.contacts[i].address.toString());
      }
      if (profile.user.profile.contacts[i].type.toString() == 'Phone') {
        phone.add(profile.user.profile.contacts[i].address.toString());
      }
      if (profile.user.profile.contacts[i].type.toString() == 'Twitter') {
        twitter.add(profile.user.profile.contacts[i].address.toString());
      }
      if (profile.user.profile.contacts[i].type.toString() == 'WhatsApp') {
        whatsapp.add(profile.user.profile.contacts[i].address.toString());
      }
    }
    //print(contacts);
    setState(() {
      isLoad = false;
    });
    //print(skills);
  }

  bool isEmpty(stuff) {
    if (stuff.length == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Summary'),
        backgroundColor: themeData2().primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: isLoad
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: themeData2().primaryColor,
                          width: 3,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomHeadline(
                                heading: profile.user.profile.name
                                    .toString()
                                    .titleCase()),
                            SizedBox(height: 8),
                            Text('Gender',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(
                                '${profile.user.profile.gender.toString().capitalize()}',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CustomHeadline(heading: ' Ratings'),
                  RatingCardDetails1(
                      isProvider: true,
                      userRating: profile.user.rating.asProvider),
                  // RatingCardDetails1(
                  //     isProvider: false,
                  //     userRating: profile.user.rating.asRequestor),
                  CustomHeadline(heading: ' Skill List'),
                  isEmpty(skills)
                      ? Text('No skills entered')
                      : SizedBox(
                          height: 50,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: skills.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                      child: Text(skills[index]
                                          .toString()
                                          .capitalize())),
                                ),
                              );
                            },
                          )),
                  CustomHeadline(heading: ' Contact List'),
                  Row(
                    children: [
                      ContactWidget(
                          containerColor: themeData2().primaryColor,
                          theIcon: const Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          iconColor: Colors.white),
                      isEmpty(email)
                          ? emptyCardContact()
                          : CustomListviewContact(contactList: email)
                    ],
                  ),
                  Row(
                    children: [
                      ContactWidget(
                          containerColor: themeData2().primaryColor,
                          theIcon: const Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                          iconColor: Colors.white),
                      isEmpty(phone)
                          ? emptyCardContact()
                          : CustomListviewContact(contactList: phone)
                    ],
                  ),
                  Row(
                    children: [
                      ContactWidget(
                          containerColor: themeData2().primaryColor,
                          theIcon: const FaIcon(
                            FontAwesomeIcons.twitter,
                            color: Colors.white,
                          ),
                          iconColor: Colors.white),
                      isEmpty(twitter)
                          ? emptyCardContact()
                          : CustomListviewContact(contactList: twitter)
                    ],
                  ),
                  Row(
                    children: [
                      ContactWidget(
                          containerColor: themeData2().primaryColor,
                          theIcon: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.white,
                          ),
                          iconColor: Colors.white),
                      isEmpty(whatsapp)
                          ? emptyCardContact()
                          : CustomListviewContact(contactList: whatsapp)
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
