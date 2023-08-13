import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/constants.dart';
import '../components/app_theme.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  PasswordRecoveryPageState createState() => PasswordRecoveryPageState();
}

class PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();

  Future<void> _passwordRecover() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      if (mounted) {
        context.showSnackBar(
            message: 'Check your email for password recovery!');
      }
    } on FirebaseAuthException catch (error) {
      context.showErrorSnackBar(message: error.message.toString());
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occured');
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Change'),
        backgroundColor: AppTheme.themeData2.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text(
            'Enter the email you used to create your account. You will receive an email with a link to reset your password.',
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(
                color: Color.fromARGB(255, 89, 175, 89),
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 89, 175, 89))),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isLoading ? null : _passwordRecover,
            child: Text(_isLoading ? 'Loading' : 'Submit'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
