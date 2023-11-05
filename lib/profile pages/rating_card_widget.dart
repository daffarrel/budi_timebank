import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/app_theme.dart';

class RatingCardWidget extends StatefulWidget {
  /// The average rating per 5. Eg: 4.5. If null, it will display 'No Rating'
  final double? rating;

  /// The total rating. Eg: 23
  final int? totalRating;

  /// The title of the rating card. Eg: 'Requester Rating'
  final String title;

  /// The leading icon of the rating card. Eg: Icons.person
  final IconData leadingIcon;

  /// Determine the colour
  final bool isProvider;

  const RatingCardWidget({
    super.key,
    required this.rating,
    required this.title,
    required this.leadingIcon,
    required this.isProvider,
    this.totalRating,
  });

  @override
  State<RatingCardWidget> createState() => _RatingCardWidgetState();
}

class _RatingCardWidgetState extends State<RatingCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: widget.isProvider
            ? AppTheme.themeData.secondaryHeaderColor
            : AppTheme.themeData.primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white),
                    child: Icon(
                      widget.leadingIcon,
                      color: widget.isProvider
                          ? AppTheme.themeData.secondaryHeaderColor
                          : AppTheme.themeData.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (widget.totalRating != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Based on ${widget.totalRating} rating${widget.totalRating == 1 ? '' : 's'}',
                          // Issue https://github.com/material-foundation/flutter-packages/issues/35
                          // preventing me to define weight by using TextStyle
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (widget.rating == null)
              const Text('No Rating',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white))
            else ...[
              RatingBar.builder(
                ignoreGestures: true,
                itemSize: 20,
                initialRating: widget.rating!,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {},
              ),
              const SizedBox(width: 5),
              Text(
                '${widget.rating?.toStringAsFixed(1)} / 5',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 10),
            ]
          ],
        ),
      ),
    );
  }
}
