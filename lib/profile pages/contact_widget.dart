import 'package:flutter/material.dart';


class ContactWidget extends StatelessWidget {
  final Color containerColor;
  final Widget theIcon;
  final Color iconColor;
  const ContactWidget({
    super.key,
    required this.containerColor,
    required this.theIcon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: containerColor, borderRadius: BorderRadius.circular(18)),
      child: Padding(padding: const EdgeInsets.all(8.0), child: theIcon),
    );
  }
}
