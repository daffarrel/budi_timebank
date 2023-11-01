import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../components/constants.dart';
import '../components/profile_avatar.dart';
import '../custom widgets/custom_headline.dart';
import '../components/app_theme.dart';
import '../db_helpers/client_user.dart';
import '../my_extensions/extension_string.dart';
import '../model/contact.dart';
import '../model/identification.dart';
import '../model/profile.dart';

enum FileUploadStatus { notSelected, uploading, uploaded, error }

class SetupProfile extends StatefulWidget {
  const SetupProfile({super.key, this.editProfile = false});

  /// Flag to indicate this page is not first time user is setting up profile
  /// [editProfile] is false when it shows after user sign up
  /// [editProfile] is true when user is editing profile from profile tab
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
  String? imageUrl;
  bool _loading = true;
  bool _isUplaodingImage = false;

  double _distanceToField = 1;

  FileUploadStatus? _fileUploadStatus = FileUploadStatus.notSelected;
  File? _organizationLetter;
  String? _organizationLetterUrl;

  final TextfieldTagsController _skillsInputController =
      TextfieldTagsController();
  // only to be used when editing profile
  List<String>? _initalSkills;

  /// Convert enum value to proper full name
  String getFullNameIndentificationType(IdentificationType type) {
    switch (type) {
      case IdentificationType.mykad:
        return "MyKad";
      case IdentificationType.matricno:
        return "Matric No.";
      case IdentificationType.staffno:
        return "Staff No.";
      case IdentificationType.passport:
        return "Passport";
    }
  }

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

  /// Called when not first time setup profile
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
    imageUrl = userProfile.avatar;

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
    if (_selectedOwnerType == OwnerType.organization) {
      if (_organizationLetter == null) {
        throw Exception('Organization letter not uploaded');
      }
    }
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
      avatar: imageUrl,
      identification: userIdentification,
      ownerType: _selectedOwnerType,
      gender: Gender.values[userGenderIndex],
      organizationName: orgName,
      organizationLetterUrl: _organizationLetterUrl,
    );

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profile': newProfile.toMap(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        context.showSnackBar(
            message: widget.editProfile
                ? 'Successfully updated profile!'
                : 'Welcome to Budi!');
      }
    } on FirebaseException catch (error) {
      context.showErrorSnackBar(message: error.message.toString());
      return;
    } catch (error) {
      context.showErrorSnackBar(message: 'Unable to Update Profile');
      return;
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<File?> _selectImage() async {
    // show dialog to select destination where to pick image
    ImageSource? imgSource = await showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageSource.camera);
                },
                child: const Text('Camera'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
                child: const Text('Gallery'),
              ),
            ],
          );
        });

    // if user cancel picking image
    if (imgSource == null) return null;

    // pick image from selected source
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: imgSource,
      maxWidth: 300,
      maxHeight: 300,
    );

    // if user cancel picking image
    if (imageFile == null) return null;

    return File(imageFile.path);
  }

  void _pickAndUploadVerificationLetter() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result == null) return;

    File file = File(result.files.single.path!);
    setState(() {
      _organizationLetter = file;
      _fileUploadStatus = FileUploadStatus.uploading;
    });

    // upload to firebase storage
    try {
      _organizationLetterUrl = await ClientUser.uploadVerificationLetter(file);
      Fluttertoast.showToast(msg: 'File uploaded');
      setState(() {
        _fileUploadStatus = FileUploadStatus.uploaded;
      });
    } on FirebaseException catch (error) {
      context.showErrorSnackBar(message: error.message.toString());
      return;
    } catch (error) {
      context.showErrorSnackBar(
          message: 'Unable to upload verification letter');
      return;
    }
  }

  String _getFilenameFromFile(File file) => file.path.split('/').last;

  String _getFileSizeFromFile(File file) {
    var fileSizeInBytes = file.lengthSync();
    var fileSizeInKB = fileSizeInBytes / 1024;
    if (fileSizeInKB < 1024) {
      return '${fileSizeInKB.toStringAsFixed(2)} KB';
    } else {
      var fileSizeInMB = fileSizeInKB / 1024;
      return '${fileSizeInMB.toStringAsFixed(2)} MB';
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
        backgroundColor: AppTheme.themeData2.primaryColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                children: [
                  Row(
                    children: [
                      ProfileAvatar(
                        imageUrl: imageUrl,
                        showLoadingSpinner: _isUplaodingImage,
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () async {
                          final selectedFile = await _selectImage();
                          if (selectedFile == null) return;
                          setState(() => _isUplaodingImage = true);
                          final newImageUrl =
                              await ClientUser.uploadProfilePicture(
                                  selectedFile);
                          // if user first time setup, do not edit directly yet.
                          if (widget.editProfile) {
                            await ClientUser.setProfilePicture(newImageUrl);
                            if (mounted) {
                              context.showSnackBar(
                                  message: 'Successfully updated profile!');
                            }
                          }
                          setState(() {
                            _isUplaodingImage = false;
                            imageUrl = newImageUrl;
                          });
                        },
                        label: Text(widget.editProfile
                            ? 'Change profile photo'
                            : 'Set profile photo'),
                        icon: const Icon(Icons.camera_alt_outlined),
                      ),
                    ],
                  ),
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
                        //     AppTheme.themeData2.,
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
                              color: AppTheme.themeData2.primaryColor,
                              width: 2,
                            )),
                        child: DropdownButton<IdentificationType>(
                          isExpanded: true,
                          underline: Container(
                            height: 0,
                          ),
                          iconEnabledColor: AppTheme.themeData2.primaryColor,
                          value: _selectedIdType,
                          items: idUser
                              .map<DropdownMenuItem<IdentificationType>>((e) {
                            return DropdownMenuItem<IdentificationType>(
                                value: e,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    getFullNameIndentificationType(e),
                                    style: TextStyle(
                                        color: AppTheme.themeData2.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedIdType = value!);
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
                              color: AppTheme.themeData2.primaryColor,
                              width: 2,
                            )),
                        child: DropdownButton<OwnerType>(
                          isExpanded: true,
                          underline: Container(
                            height: 0,
                          ),
                          iconEnabledColor: AppTheme.themeData2.primaryColor,
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
                                        color: AppTheme.themeData2.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedOwnerType = value!);
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
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Organization letter',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (_fileUploadStatus == FileUploadStatus.notSelected)
                          ElevatedButton(
                            onPressed: _pickAndUploadVerificationLetter,
                            child: const Text('Select file'),
                          ),
                      ],
                    ),
                    if (_organizationLetter != null)
                      Card(
                        child: ListTile(
                          tileColor: Colors.blueGrey.shade50,
                          title:
                              Text(_getFilenameFromFile(_organizationLetter!)),
                          subtitle:
                              Text(_getFileSizeFromFile(_organizationLetter!)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_fileUploadStatus ==
                                  FileUploadStatus.uploading)
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(),
                                ),
                              if (_fileUploadStatus ==
                                  FileUploadStatus.uploaded) ...[
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                                IconButton(
                                  onPressed: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (_) =>
                                            _DeleteOrganizationLetterDialog(
                                                fileurl:
                                                    _organizationLetterUrl!));
                                    setState(() {
                                      _organizationLetter = null;
                                      _fileUploadStatus =
                                          FileUploadStatus.notSelected;
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                    // Text(verificationLetterFilename ??
                    //     'Please upload orgaization letter'),
                    const SizedBox(height: 8),
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
                      // This part may be wrongly triggered when pressing comma
                      // from PC keyboard (Nothing to worry about when in production)
                      if (_skillsInputController.getTags != null &&
                          _skillsInputController.getTags!.contains(tag)) {
                        return 'Recent tag already added';
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
                      color: AppTheme.themeData2.primaryColor,
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
                              iconEnabledColor:
                                  AppTheme.themeData2.primaryColor,
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
                                          color:
                                              AppTheme.themeData2.primaryColor,
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
                                        color: AppTheme.themeData2.primaryColor,
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
                                foregroundColor:
                                    AppTheme.themeData2.primaryColor,
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      try {
                        await _saveProfile();
                      } on Exception catch (e) {
                        context.showErrorSnackBar(message: e.toString());
                        return;
                      }

                      // add points during registration
                      if (!widget.editProfile) {
                        await ClientUser.addPoints(
                          points: _selectedOwnerType == OwnerType.individual
                              ? 10
                              : 200,
                        );
                      }
                      if (widget.editProfile) {
                        // go to previous page
                        Navigator.of(context).pop();
                      } else {
                        // go to dahsboard page
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/navigation', (Route<dynamic> route) => false);
                      }
                    },
                    child: Text(
                      _loading
                          ? 'Loading...'
                          : widget.editProfile
                              ? 'Update'
                              : 'Save',
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }
}

class _AddedContactWidget extends StatelessWidget {
  const _AddedContactWidget(
      {required this.onContactDelete,
      required this.contactType,
      required this.iconData,
      required this.value});

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
          color: AppTheme.themeData2.primaryColor,
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

class _DeleteOrganizationLetterDialog extends StatefulWidget {
  // ignore: unused_element
  const _DeleteOrganizationLetterDialog({super.key, required this.fileurl});

  final String fileurl;

  @override
  State<_DeleteOrganizationLetterDialog> createState() =>
      __DeleteOrganizationLetterDialogState();
}

class __DeleteOrganizationLetterDialogState
    extends State<_DeleteOrganizationLetterDialog> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete organization letter?'),
      content: const Text('Are you sure you want to delete this letter?'),
      actions: [
        if (_loading)
          const SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            setState(() => _loading = true);
            await ClientUser.deleteVerificationLetter(widget.fileurl);
            setState(() => _loading = false);
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
