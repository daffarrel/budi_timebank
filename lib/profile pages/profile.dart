import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../auth pages/setup_profile.dart';
import '../components/profile_avatar.dart';
import '../custom widgets/custom_headline.dart';
import '../custom%20widgets/theme.dart';
import '../db_helpers/client_user.dart';
import '../my_extensions/extension_string.dart';

import '../model/contact.dart';
import '../model/profile.dart';
import 'contact_widget.dart';
import 'empty_card_contact.dart';
import 'custom_list_view_contact.dart';

class ProfilePage extends StatefulWidget {
  final bool isMyProfile;
  const ProfilePage({super.key, required this.isMyProfile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final userUid = FirebaseAuth.instance.currentUser!.uid;
  late Future<Profile> futureProfile;
  List<String> skills = [];
  List<String> email = [];
  List<String> phone = [];
  List<String> twitter = [];
  List<String> whatsapp = [];

  @override
  void initState() {
    super.initState();
    futureProfile = ClientUser.getUserProfileById(userUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData2().primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SetupProfile(
                      editProfile: true,
                    ),
                  )).then((value) => setState(
                    () {
                      futureProfile = ClientUser.getUserProfileById(userUid);
                    },
                  ));
            },
          )
        ],
        title: const Text('Profile Page'),
      ),
      body: FutureBuilder(
          future: futureProfile,
          builder: (context, AsyncSnapshot<Profile> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            skills = snapshot.data!.skills;
            email = snapshot.data!.contacts
                .where((element) => element.contactType == ContactType.email)
                .map((e) => e.value)
                .toList();
            phone = snapshot.data!.contacts
                .where((element) => element.contactType == ContactType.phone)
                .map((e) => e.value)
                .toList();
            whatsapp = snapshot.data!.contacts
                .where((element) => element.contactType == ContactType.whatsapp)
                .map((e) => e.value)
                .toList();
            twitter = snapshot.data!.contacts
                .where((element) => element.contactType == ContactType.twitter)
                .map((e) => e.value)
                .toList();

            return ListView(
              padding: EdgeInsets.all(14),
              children: [
                if (kDebugMode)
                  Text(
                    userUid,
                    style: const TextStyle(color: Colors.red),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomHeadline(
                                  snapshot.data!.name.toString().titleCase()),
                              const SizedBox(height: 10),
                              Text(
                                  snapshot.data!.identification
                                      .identificationType.name
                                      .toString()
                                      .capitalize(),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              Text(snapshot.data!.identification.value,
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 10),
                              const Text('Gender',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  snapshot.data!.gender.name
                                      .toString()
                                      .capitalize(),
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          ProfileAvatar(imageUrl: snapshot.data!.avatar),
                        ],
                      ),
                    ),
                  ),
                ),
                const CustomHeadline(' Skill List'),
                skills.isEmpty
                    ? const Text('No skills entered')
                    : Wrap(
                        children: [
                          for (var skill in skills)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Chip(
                                elevation: 4,
                                backgroundColor: Colors.white,
                                label: Text(skill.toString().capitalize()),
                              ),
                            ),
                        ],
                      ),

                // ListView.builder(
                //     physics: const BouncingScrollPhysics(),
                //     scrollDirection: Axis.horizontal,
                //     shrinkWrap: true,
                //     itemCount: skills.length,
                //     itemBuilder: (context, index) {
                //       return Card(
                //         elevation: 5,
                //         child: Padding(
                //           padding: const EdgeInsets.all(8.0),
                //           child: Center(
                //               child: Text(
                //                   skills[index].toString().capitalize())),
                //         ),
                //       );
                //     },
                //   ),

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
                // RatingCardWidget(
                //   isProvider: true,
                //   title: 'Provider Rating',
                //   iconRating: Icons.emoji_people,
                //   userRating: profile.user.rating.asProvider,
                // ),
                // RatingCardWidget(
                //   isProvider: false,
                //   title: 'Requestor Rating',
                //   iconRating: Icons.handshake,
                //   userRating: profile.user.rating.asRequestor,
                // ),
              ],
            );
          }),
    );
  }
}
