import 'package:flutter/material.dart';

class CustomHeadline extends StatelessWidget {
  final String heading;
  final bool isRequired;

  const CustomHeadline(this.heading, {super.key, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
      child: RichText(
        text: TextSpan(
            text: heading,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
            ]),
      ),
    );
  }
}
