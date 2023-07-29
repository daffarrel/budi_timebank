import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../components/constants.dart';
import '../custom widgets/custom_headline.dart';
import '../custom%20widgets/theme.dart';
import '../db_helpers/client_user.dart';
import '../my_extensions/extension_string.dart';
import '../model/contact.dart';
import '../model/identification.dart';
import '../model/profile.dart';
import '../splash_page.dart';

class SetupProfile extends StatefulWidget {
  const SetupProfile({super.key, this.editProfile = false});

  /// Flag to indicate this page is not first time user is setting up profile
  final bool editProfile;

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  final _usernameController = TextEditingController();
  final _contactController = TextEditingController();
  final _idController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _emailAddressController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<bool> _selectedGender = <bool>[true, false];
  final List<Contact> otherContacts = [];
  final List<Gender> listGender = Gender.values;
  List<IdentificationType> idUser = IdentificationType.values;
  ContactType _selectedContactType = ContactType.phone;
  IdentificationType _selectedIdType = IdentificationType.mykad;
  OwnerType _selectedOwnerType = OwnerType.individual;

  final Map<ContactType, IconData> _contactTypes = {
    ContactType.whatsapp: FontAwesomeIcons.whatsapp,
    ContactType.twitter: FontAwesomeIcons.twitter,
    ContactType.phone: Icons.phone,
    ContactType.email: Icons.email,
  };

  final userId = FirebaseAuth.instance.currentUser!.uid;
  bool _loading = true;

  double _distanceToField = 1;
  final TextfieldTagsController _skillsInputController =
      TextfieldTagsController();
  // only to be used when editing profile
  List<String>? _initalSkills;

  @override
  void initState() {
    super.initState();
    widget.editProfile ? _readProfile() : _initProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.sizeOf(context).width;
  }

  void _deleteContact(Contact contact) {
    setState(() {
      otherContacts.removeWhere((element) => element == contact);
    });
  }

  _addcontact(ContactType type, String value) {
    var newContact = Contact(contactType: type, value: value);

    setState(() {
      otherContacts.add(newContact);
    });
  }

  Future<void> _readProfile() async {
    setState(() => _loading = true);
    Profile userProfile = await ClientUser.getUserProfileById(
        FirebaseAuth.instance.currentUser!.uid);
    _usernameController.text = userProfile.name;
    _initalSkills = userProfile.skills;
    _selectedOwnerType = userProfile.ownerType;
    if (_selectedOwnerType == OwnerType.organization) {
      _organizationNameController.text = userProfile.organizationName!;
    }

    _selectedGender =
        List.generate(2, (index) => userProfile.gender == listGender[index]);
    _idController.text = userProfile.identification.value;

    _emailAddressController.text = userProfile.contacts
        .firstWhere((element) => element.contactType == ContactType.email)
        .value;
    _phoneNumberController.text = userProfile.contacts
        .firstWhere((element) => element.contactType == ContactType.phone)
        .value;

    var contactOthers = userProfile.contacts;
    contactOthers.removeWhere(
        (element) => element.value == _emailAddressController.text);
    contactOthers
        .removeWhere((element) => element.value == _phoneNumberController.text);
    otherContacts.addAll(contactOthers);

    _selectedIdType = userProfile.identification.identificationType;

    setState(() => _loading = false);
  }

  Future<void> _initProfile() async {
    setState(() => _loading = true);

    try {
      // Create user profile
      FirebaseFirestore.instance.collection('users').doc(userId).set({
        'earningsHistory': [],
        'profile': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      context.showErrorSnackBar(message: error.message.toString());
      return;
    }

    // Get user email from auth
    var email = FirebaseAuth.instance.currentUser!.email;
    _emailAddressController.text = email!;

    setState(() => _loading = false);
  }

  /// Called when user taps `Save` button
  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    var userIdentification = Identification(
        identificationType: _selectedIdType, value: _idController.text);
    var orgName = _selectedOwnerType == OwnerType.individual
        ? null
        : _organizationNameController.text;

    var userGenderIndex =
        _selectedGender.indexWhere((element) => element == true);

    var contacts = [
      Contact(
          contactType: ContactType.email, value: _emailAddressController.text),
      Contact(
          contactType: ContactType.phone, value: _phoneNumberController.text),
      ...otherContacts
    ];

    var newProfile = Profile(
      name: _usernameController.text.trim(),
      skills: _skillsInputController.getTags ?? [],
      contacts: contacts,
      identification: userIdentification,
      ownerType: _selectedOwnerType,
      gender: Gender.values[userGenderIndex],
      organizationName: orgName,
    );

    try {
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'earningsHistory': [],
        'profile': newProfile.toMap(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        context.showSnackBar(message: 'Successfully updated profile!');
      }
    } on FirebaseException catch (error) {
      context.showErrorSnackBar(message: error.message.toString());
    } catch (error) {
      context.showErrorSnackBar(message: 'Unable to Update Profile');
    }

    // add points

    await ClientUser.addPoints(
        points: _selectedOwnerType == OwnerType.individual ? 10 : 200);

    setState(() {
      _loading = false;
    });
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
              builder: (BuildContext context) => const SplashPage()));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _contactController.dispose();
    _idController.dispose();
    _skillsInputController.dispose();
    _organizationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: themeData2().primaryColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                children: [
                  // Avatar(
                  //   imageUrl: _avatarUrl,
                  //   onUpload: _onUpload,
                  // ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CustomHeadline('Name'),
                  ),
                  TextFormField(
                    controller: _usernameController,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name...';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CustomHeadline('Gender'),
                      ),
                      ToggleButtons(
                        direction: Axis.horizontal,
                        onPressed: (int index) {
                          setState(() {
                            // The button that is tapped is set to true, and the others to false.
                            for (int i = 0; i < _selectedGender.length; i++) {
                              _selectedGender[i] = i == index;
                            }
                          });
                        },
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: Colors.green[700],
                        //     themeData2().,
                        selectedColor: Colors.white,
                        fillColor: Colors.green[300],
                        // color: Colors.red[400],
                        color: Colors.green[400],
                        constraints: const BoxConstraints(
                          minHeight: 40.0,
                          minWidth: 80.0,
                        ),
                        isSelected: _selectedGender,
                        children: Gender.values
                            .map((e) => Text(e.name.titleCase()))
                            .toList(),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                    child: CustomHeadline('Identification'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _idController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter identification number'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter matric number...';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        //padding: EdgeInsets.all(8),
                        width: MediaQuery.of(context).size.width / 3,
                        margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: themeData2().primaryColor,
                              width: 2,
                            )),
                        child: DropdownButton<IdentificationType>(
                          isExpanded: true,
                          underline: Container(
                            height: 0,
                          ),
                          iconEnabledColor: themeData2().primaryColor,
                          value: _selectedIdType,
                          items: idUser
                              .map<DropdownMenuItem<IdentificationType>>((e) {
                            return DropdownMenuItem<IdentificationType>(
                                value: e,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    e.name.titleCase(),
                                    style: TextStyle(
                                        color: themeData2().primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedIdType = value!;
                              //print(_genderController.text);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CustomHeadline('Account type'),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2.6,
                        //padding: EdgeInsets.all(8),
                        margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: themeData2().primaryColor,
                              width: 2,
                            )),
                        child: DropdownButton<OwnerType>(
                          isExpanded: true,
                          underline: Container(
                            height: 0,
                          ),
                          iconEnabledColor: themeData2().primaryColor,
                          value: _selectedOwnerType,
                          items: OwnerType.values
                              .map<DropdownMenuItem<OwnerType>>((e) {
                            return DropdownMenuItem<OwnerType>(
                                value: e,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    e.name.titleCase(),
                                    style: TextStyle(
                                        color: themeData2().primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOwnerType = value!;
                              //print(_genderController.text);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_selectedOwnerType == OwnerType.organization) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _organizationNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter organization name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter organization name number...';
                        }
                        return null;
                      },
                    ),
                  ],

                  const Divider(
                      //horizontal line
                      height: 30,
                      thickness: 2,
                      indent: 15,
                      endIndent: 15),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CustomHeadline('Skill'),
                  ),
                  TextFieldTags(
                    textfieldTagsController: _skillsInputController,
                    initialTags: _initalSkills,
                    textSeparators: const [','],
                    letterCase: LetterCase.normal,
                    validator: (String tag) {
                      if (_skillsInputController.getTags != null &&
                          _skillsInputController.getTags!.contains(tag)) {
                        return 'you already entered that';
                      }
                      return null;
                    },
                    inputfieldBuilder:
                        (context, tec, fn, error, onChanged, onSubmitted) {
                      return ((context, sc, tags, onTagDelete) {
                        return TextField(
                          controller: tec,
                          focusNode: fn,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(),
                            hintText: _skillsInputController.hasTags
                                ? ''
                                : "Enter skills seperated by comma...",
                            errorText: error,
                            prefixIconConstraints: BoxConstraints(
                                maxWidth: _distanceToField * 0.74),
                            prefixIcon: tags.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: SingleChildScrollView(
                                      controller: sc,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          for (var tag in tags)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4),
                                              child: InputChip(
                                                label: Text(tag),
                                                onDeleted: () =>
                                                    onTagDelete(tag),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Divider(
                      //horizontal line
                      color: themeData2().primaryColor,
                      height: 30,
                      thickness: 2,
                      indent: 15,
                      endIndent: 15),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CustomHeadline('Contacts'),
                  ),
                  TextFormField(
                    controller: _emailAddressController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Email address',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Phone Number. eg: 60192345678',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Other Contacts: '),
                  ),
                  otherContacts.isEmpty
                      ? const Text('You have not entered any contacts...')
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          //scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: otherContacts.length,
                          itemBuilder: (context, index) {
                            return _AddedContactWidget(
                                onContactDelete: () =>
                                    _deleteContact(otherContacts[index]),
                                contactType: otherContacts[index].contactType,
                                iconData: _contactTypes[
                                    otherContacts[index].contactType]!,
                                value: otherContacts[index].value);
                          },
                        ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _contactController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Add other contacts',
                            prefixIconConstraints: BoxConstraints(
                                maxWidth: _distanceToField * 0.24),
                            prefixIcon: DropdownButton<ContactType>(
                              isExpanded: true,
                              iconEnabledColor: themeData2().primaryColor,
                              underline: Container(
                                height: 0,
                              ),
                              value: _selectedContactType,
                              selectedItemBuilder: (context) {
                                return _contactTypes.entries.map((entry) {
                                  final iconData = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          iconData,
                                          color: themeData2().primaryColor,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                              items: _contactTypes.entries.map((entry) {
                                final contactType = entry.key;
                                return DropdownMenuItem<ContactType>(
                                  value: contactType,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      contactType.name.titleCase(),
                                      style: TextStyle(
                                        color: themeData2().primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedContactType = value!;
                                });
                              },
                            ),
                            //labelText: 'Contact',
                            suffixIcon: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: themeData2().primaryColor,
                              ),
                              onPressed: () {
                                if (_contactController.text.isEmpty) {
                                  context.showErrorSnackBar(
                                      message:
                                          'You have not entered any contact..');
                                } else {
                                  try {
                                    _addcontact(_selectedContactType,
                                        _contactController.text);
                                    _contactController.clear();
                                  } catch (e) {
                                    context.showErrorSnackBar(
                                        message: 'Unable to add contact');
                                  }
                                }
                              },
                              child: const Text('Add'),
                            ),
                          ),
                          maxLines: 1,
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter contacts';
                          //   }
                          //   return null;
                          // },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      await _saveProfile();
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/navigation', (route) => false);
                      }
                    },
                    child: Text(_loading
                        ? 'Loading...'
                        : widget.editProfile
                            ? 'Update'
                            : 'Save'),
                  ),
                  if (widget.editProfile)
                    TextButton(
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Confirm Sign Out?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _signOut();
                                    },
                                    child: const Text('Sign Out'),
                                  ),
                                ],
                              ),
                            ),
                        // onPressed: _signOut,
                        child: const Text('Sign Out')),
                ],
              ),
            ),
    );
  }
}

class _AddedContactWidget extends StatelessWidget {
  const _AddedContactWidget(
      {Key? key,
      required this.onContactDelete,
      required this.contactType,
      required this.iconData,
      required this.value})
      : super(key: key);

  final VoidCallback onContactDelete;
  final ContactType contactType;
  final IconData iconData;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          iconData,
          color: themeData2().primaryColor,
        ),
        subtitle: Text(contactType.name.capitalize()),
        title: Text(value),
        trailing: IconButton(
          onPressed: onContactDelete,
          icon: const Icon(
            Icons.remove_circle_outline,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
