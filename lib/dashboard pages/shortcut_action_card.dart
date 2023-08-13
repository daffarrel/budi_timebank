import 'package:flutter/material.dart';

class ShortcutActionCard extends StatelessWidget {
  const ShortcutActionCard(
      {super.key,
      required this.title,
      required this.description,
      required this.icon,
      this.borderColor,
      this.backgroundColor,
      required this.foregroundColor,
      required this.destination});

  final String title;
  final String description;
  final IconData icon;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color foregroundColor;
  final Route destination;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          side: borderColor != null
              ? BorderSide(
                  width: 3,
                  color: borderColor!,
                )
              : BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        color: backgroundColor,
        child: InkWell(
          onTap: () => Navigator.of(context).push(destination),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: foregroundColor, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: foregroundColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
