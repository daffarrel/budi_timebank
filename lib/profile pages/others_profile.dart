import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../components/profile_avatar.dart';
import '../custom widgets/custom_headline.dart';
import '../custom%20widgets/theme.dart';
import '../db_helpers/client_user.dart';
import '../model/contact.dart';
import '../model/profile.dart';
import '../my_extensions/extension_string.dart';
import 'contact_widget.dart';
import 'custom_list_view_contact.dart';
import 'empty_card_contact.dart';

class ViewProfile extends StatefulWidget {
  final String id;
  const ViewProfile({super.key, required this.id});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  late Profile profile;
  late List<String> skills;
  late List<String> email;
  late List<String> phone;
  late List<String> twitter;
  late List<String> whatsapp;

  bool isLoad = true;
  @override
  void initState() {
    getInstance();
    super.initState();
  }

  getInstance() async {
    var myProfile = await ClientUser.getUserProfileById(widget.id);
    skills = [];
    email = [];
    phone = [];
    twitter = [];
    whatsapp = [];
    for (int i = 0; i < myProfile.skills.length; i++) {
      skills.add(myProfile.skills[i]);
    }
    for (int i = 0; i < myProfile.contacts.length; i++) {
      if (myProfile.contacts[i].contactType == ContactType.email) {
        email.add(myProfile.contacts[i].value);
      }
      if (myProfile.contacts[i].contactType == ContactType.phone) {
        phone.add(myProfile.contacts[i].value);
      }
      if (myProfile.contacts[i].contactType == ContactType.twitter) {
        twitter.add(myProfile.contacts[i].value);
      }
      if (myProfile.contacts[i].contactType == ContactType.whatsapp) {
        whatsapp.add(myProfile.contacts[i].value);
      }
    }

    setState(() {
      profile = myProfile;
      isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Summary'),
        //backgroundColor: themeData2().primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: isLoad
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  // if (kDebugMode)
                  //   Text(
                  //     widget.id,
                  //     style: const TextStyle(color: Colors.red),
                  //   ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      // shape: RoundedRectangleBorder(
                      //   side: BorderSide(
                      //     color: themeData2().primaryColor,
                      //     width: 3,
                      //   ),
                      //   borderRadius:
                      //       const BorderRadius.all(Radius.circular(12)),
                      // ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ProfileAvatar(
                              imageUrl: profile.avatar,
                              radius: 30,
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomHeadline(
                                    profile.name.toString().titleCase()),
                                const SizedBox(height: 8),
                                Text('(${profile.gender.name.capitalize()})',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // const CustomHeadline(' Ratings'),
                  const SizedBox(height: 10),
                  const CustomHeadline(' Skill List'),
                  skills.isEmpty
                      ? const Text('No skills entered')
                      : Wrap(
                          children: [
                            for (var skill in skills)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Chip(
                                  label: Text(skill.capitalize()),
                                  padding: const EdgeInsets.all(8),
                                  elevation: 5,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  // shape: ,
                                ),
                              ),
                          ],
                        ),
                  const SizedBox(height: 10),
                  const CustomHeadline(' Contact List'),
                  Row(
                    children: [
                      ContactWidget(
                          containerColor: themeData3().primaryColor,
                          theIcon: const Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          iconColor: Colors.white),
                      email.isEmpty
                          ? const EmptyCardContact()
                          : CustomListViewContact(contactList: email)
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ContactWidget(
                          containerColor: themeData3().primaryColor,
                          theIcon: const Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                          iconColor: Colors.white),
                      phone.isEmpty
                          ? const EmptyCardContact()
                          : CustomListViewContact(contactList: phone)
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ContactWidget(
                          containerColor: themeData3().primaryColor,
                          theIcon: const FaIcon(
                            FontAwesomeIcons.twitter,
                            color: Colors.white,
                          ),
                          iconColor: Colors.white),
                      twitter.isEmpty
                          ? const EmptyCardContact()
                          : CustomListViewContact(contactList: twitter)
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      ContactWidget(
                          containerColor: themeData3().primaryColor,
                          theIcon: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.white,
                          ),
                          iconColor: Colors.white),
                      whatsapp.isEmpty
                          ? const EmptyCardContact()
                          : CustomListViewContact(contactList: whatsapp)
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
