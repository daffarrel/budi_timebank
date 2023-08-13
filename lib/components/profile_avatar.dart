import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Show avatar. If [imageUrl] is null, show avatar placeholder instead
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.showLoadingSpinner = false,
    this.radius = 40,
  });
  final String? imageUrl;
  final bool showLoadingSpinner;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: imageUrl == null ? Colors.blueGrey.shade50 : null,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? const FaIcon(FontAwesomeIcons.user)
          : showLoadingSpinner
              ? Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  child: const CircularProgressIndicator(),
                )
              : null,
    );
  }
}
