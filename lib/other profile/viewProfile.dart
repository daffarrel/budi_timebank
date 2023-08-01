import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../custom widgets/custom_headline.dart';
import '../custom%20widgets/theme.dart';
import '../db_helpers/client_user.dart';
import '../my_extensions/extension_string.dart';

import '../model/contact.dart';
import '../model/profile.dart';
import '../profile pages/contact_widget.dart';
import '../profile pages/empty_card_contact.dart';
import '../profile pages/custom_list_view_contact.dart';

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
      if (myProfile.contacts[i].contactType.toString() == 'Email') {
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
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
                            CustomHeadline(profile.name.toString().titleCase()),
                            const SizedBox(height: 8),
                            const Text('Gender',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(profile.gender.name.capitalize(),
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // const CustomHeadline(' Ratings'),
                  const CustomHeadline(' Skill List'),
                  skills.isEmpty
                      ? const Text('No skills entered')
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
                          : CustomListviewContact(contactList: email)
                    ],
                  ),
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
                          : CustomListviewContact(contactList: phone)
                    ],
                  ),
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
                          : CustomListviewContact(contactList: twitter)
                    ],
                  ),
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
                          : CustomListviewContact(contactList: whatsapp)
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
