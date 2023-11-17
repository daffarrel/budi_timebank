import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../auth pages/setup_profile.dart';
import '../components/constants.dart';
import '../components/profile_avatar.dart';
import '../custom widgets/custom_headline.dart';
import '../components/app_theme.dart';
import '../db_helpers/client_rating.dart';
import '../db_helpers/client_user.dart';
import '../model/identification.dart';
import '../model/rating.dart';
import '../my_extensions/extension_string.dart';

import '../model/contact.dart';
import '../model/profile.dart';
import '../rate pages/rating_review_page.dart';
import '../splash_page.dart';
import 'contact_widget.dart';
import 'empty_card_contact.dart';
import 'custom_list_view_contact.dart';
import 'profile_photo_page.dart';
import 'rating_card_widget.dart';

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

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException {
      context.showErrorSnackBar(message: 'error signing out');
    } catch (error) {
      context.showErrorSnackBar(message: 'Unable to signout');
    }
    if (mounted) {
      //Navigator.of(context).pushReplacementNamed('/');
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const SplashPage()),
      );
    }
  }

  Future<(int? totalRating, double? averageRating)>
      getRequestorRatings() async {
    List<Rating> myReceivedRatings = await ClientRating.getAllReceivedRating();

    int totalRating = 0;
    int totalNumberOfRatings = myReceivedRatings.length;

    for (var rating in myReceivedRatings) {
      totalRating += rating.rating;
    }

    // calculate average rating
    final averageRating = totalRating / totalNumberOfRatings;

    if (averageRating.isNaN) {
      return (null, null);
    }

    return (totalNumberOfRatings, averageRating);
  }

  String identificationLabel(IdentificationType type) {
    switch (type) {
      case IdentificationType.mykad:
        return 'MyKad';
      case IdentificationType.staffno:
        return 'Staff ID';
      case IdentificationType.matricno:
        return 'Matric No';
      default:
        return type.name.capitalize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.themeData2.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
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
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Confirm Log Out?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => _signOut(),
                    child: const Text('Log Out',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
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
              padding: const EdgeInsets.all(14),
              children: [
                if (kDebugMode)
                  Text(
                    userUid,
                    style: const TextStyle(color: Colors.red),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: SelectionArea(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data!.name.toString().titleCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (snapshot.data!.ownerType ==
                                    OwnerType.organization) ...[
                                  const Text('Organization',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  Text(snapshot.data!.organizationName!,
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 10),
                                ],
                                Text(
                                  '${identificationLabel(snapshot.data!.identification.identificationType)}: ${snapshot.data!.identification.value}',
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Gender: ${snapshot.data!.gender.name.capitalize()}',
                                ),
                              ],
                            ),
                            Hero(
                              tag: 'profile-photo',
                              child: GestureDetector(
                                  onTap: () {
                                    if (snapshot.data!.avatar == null) return;
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProfilePhotoPage(
                                          name: snapshot.data!.name,
                                          image: NetworkImage(
                                              snapshot.data!.avatar!),
                                        ),
                                      ),
                                    );
                                  },
                                  child: ProfileAvatar(
                                      imageUrl: snapshot.data!.avatar)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder(
                    future: getRequestorRatings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final (numberOfRating, averageRating) = snapshot.data!;

                      return RatingCardWidget(
                        isProvider: false,
                        title: 'Rating:',
                        leadingIcon: Icons.handshake,
                        totalRating: numberOfRating,
                        rating: averageRating,
                        onTap: averageRating != null
                            ? () async {
                                final ratings =
                                    await ClientRating.getAllReceivedRating();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RatingReviewPage(ratings: ratings),
                                  ),
                                );
                              }
                            : null,
                      );
                    }),
                const SizedBox(height: 10),
                const CustomHeadline(' Skill List'),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                const CustomHeadline(' Contact List'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ContactWidget(
                        containerColor: AppTheme.themeData3.primaryColor,
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
                const SizedBox(height: 5),
                Row(
                  children: [
                    ContactWidget(
                        containerColor: AppTheme.themeData3.primaryColor,
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
                const SizedBox(height: 5),
                Row(
                  children: [
                    ContactWidget(
                        containerColor: AppTheme.themeData3.primaryColor,
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
                const SizedBox(height: 5),
                Row(
                  children: [
                    ContactWidget(
                        containerColor: AppTheme.themeData3.primaryColor,
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
                //   // userRating: profile.user.rating.asProvider,
                //   userRating: "3",
                // ),

                const SizedBox(height: 10),
              ],
            );
          }),
    );
  }
}
