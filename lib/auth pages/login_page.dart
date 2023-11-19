import 'package:flutter/material.dart';

import '../components/app_theme.dart';
import 'login_fragment.dart';
import 'password_recovery_page.dart';
import 'sign_up_fragment.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BUDI',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.themeData.primaryColor,
                  fontSize: 65,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: [const LoginFragment(), const SignUpFragment()][pageIndex],
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor:
                            AppTheme.themeData.secondaryHeaderColor),
                    onPressed: (() {
                      setState(() {
                        pageIndex = pageIndex == 0 ? 1 : 0;
                      });
                    }),
                    child: Text(
                      pageIndex == 0 ? 'Sign Up' : 'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: pageIndex == 0
                            ? AppTheme.themeData.secondaryHeaderColor
                            : AppTheme.themeData.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    height: 15,
                    child: VerticalDivider(
                      color: Colors.black,
                      width: 1,
                    )),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor:
                            AppTheme.themeData.secondaryHeaderColor),
                    onPressed: (() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PasswordRecoveryPage(),
                          ));
                    }),
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: pageIndex == 0
                            ? AppTheme.themeData.secondaryHeaderColor
                            : AppTheme.themeData.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
