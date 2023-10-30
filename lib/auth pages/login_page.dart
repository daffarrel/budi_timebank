import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/constants.dart';
import '../components/app_theme.dart';
import 'password_recovery_page.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  bool _passwordVisible = false;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final StreamSubscription<User?> _authStateSubscription;

  Future<void> _logIn() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      context.showErrorSnackBar(message: error.message.toString());
    } catch (error) {
      context.showErrorSnackBar(message: 'Unable to log in!!');
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (_redirecting) return;
      if (user != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/navigation');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(15),
          children: [
            Text(
              'BUDI',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.themeData.primaryColor,
                  fontSize: 65,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'Log in with your email and password',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppTheme.themeData.primaryColor),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppTheme.themeData.primaryColor),
                ),
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    // Update the state i.e. toogle the state of passwordVisible variable
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.themeData.secondaryHeaderColor,
                foregroundColor: Colors.white,
                // side: BorderSide(
                //   width: 3.0,
                //   color: AppTheme.themeData.secondaryHeaderColor,
                // )
              ),
              onPressed: _isLoading ? null : _logIn,
              child: Text(
                _isLoading ? 'Loading' : 'Login',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: (() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PasswordRecoveryPage(),
                    ));
              }),
              child: const Text('Forgot Password',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: AppTheme.themeData.secondaryHeaderColor),
              onPressed: (() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ));
              }),
              child: const Text(
                'Sign Up',
              ),
            ),
            // ElevatedButton(
            //     onPressed: (() {
            //       Navigator.of(context).pushNamed('/navigation');
            //     }),
            //     child: const Text('Skip (for developers)'))
          ],
        ),
      ),
    );
  }
}
