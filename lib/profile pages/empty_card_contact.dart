import 'package:flutter/material.dart';

import '../components/app_theme.dart';

class EmptyCardContact extends StatelessWidget {
  const EmptyCardContact({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: AppTheme.themeData3.primaryColor,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          'No contact added',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
