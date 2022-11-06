//import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testfyp/components/avatar.dart';
import 'package:testfyp/components/constants.dart';
//import 'package:testfyp/dashboard.dart';
import 'package:testfyp/navigation.dart';
import 'package:testfyp/splash_page.dart';
//import '../profile pages/profile.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _matricController = TextEditingController();
  final _genderController = TextEditingController();
  final _descriptionController = TextEditingController();
  //final _skillsController = TextEditingController(); //array?
  late String _avatarUrl = '';
  // late List<String> skill;
  // late List<dynamic> contact;
  var _loading = false;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id; //map the user ID
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single() as Map;
      _usernameController.text = (data['username'] ?? '') as String;
      _websiteController.text = (data['website'] ?? '') as String;
      _matricController.text = (data['matricNum'] ?? '') as String;
      _genderController.text = (data['gender'] ?? '') as String;
      _descriptionController.text = (data['description'] ?? '') as String;
      _avatarUrl = (data['avatar_url'] ?? '') as String;
      //_skillsController.text = (data['skills'] ?? '') as Array;
    } on PostgrestException catch (error) {
      if (_usernameController.text == '') {
        context.showSnackBar(message: 'Welcome to BUDI!');
      } else {
        context.showErrorSnackBar(message: error.message);
      }
    } catch (error) {
      context.showErrorSnackBar(message: 'Missing Description');
    }

    setState(() {
      _loading = false;
    });
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final userName = _usernameController.text;
    final website = _websiteController.text;
    final matricNum = _matricController.text;
    final user = supabase.auth.currentUser;
    final gender = _genderController.text;
    final description = _descriptionController.text;
    //print(user!.id);
    //final avatar =
    //final skills = _skillsController;
    final updates = {
      'id': user!.id,
      'username': userName,
      //'skills': skill,
      //'contacts': contact,
      'website': website,
      'updated_at': DateTime.now().toIso8601String(),
      'matricNum': matricNum,
      'gender': gender,
      'description': description,
      'avatar_url': _avatarUrl,
      //'skills': skills,
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        context.showSnackBar(message: 'Successfully updated profile!');
        // Navigator.of(context).pop();
        // Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => BottomBarNavigation()));
      }
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unable to Update Profile');
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
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

  // Called when image has been uploaded to Supabase storage from within Avatar widget
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'avatar_url': imageUrl,
      });
      if (mounted) {
        context.showSnackBar(message: 'Updated your profile image!');
      }
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unable to change picture');
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    //_getProfile();
    Future.delayed(Duration.zero, _getProfile);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    _matricController.dispose();
    _genderController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        // backgroundColor: Color.fromARGB(255, 127, 17, 224),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          Avatar(
            imageUrl: _avatarUrl,
            onUpload: _onUpload,
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'User Name'),
          ),
          TextFormField(
            controller: _genderController,
            decoration: const InputDecoration(labelText: 'Gender'),
          ),
          TextFormField(
            controller: _matricController,
            decoration: const InputDecoration(labelText: 'Matric Number'),
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(labelText: 'Website'),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _updateProfile,
            child: Text(_loading ? 'Saving...' : 'Update'),
          ),
          //const SizedBox(height: 18),
          ElevatedButton(
            onPressed: (() {
              Navigator.of(context).popUntil((route) => route.isFirst);
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //         builder: (BuildContext context) =>
              //             BottomBarNavigation()));
            }),
            child: Text('Go to DashBoard'),
          ),
          TextButton(onPressed: _signOut, child: const Text('Sign Out')),
        ],
      ),
    );
  }
}
