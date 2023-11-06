import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../db_helpers/client_user.dart';
import '../model/rating.dart';

/// New rating and review page
class RatingReviewPage extends StatelessWidget {
  const RatingReviewPage({super.key, required this.ratings});

  final List<Rating> ratings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating & Review'),
      ),
      body: ListView.builder(
        itemCount: ratings.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: FutureBuilder(
                  future:
                      ClientUser.getUserProfileById(ratings[index].authorId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    }
                    return const Text('');
                  }),
              subtitle: ratings[index].message != null
                  ? Text(ratings[index].message!)
                  : null,
              trailing: Column(
                children: [
                  const SizedBox(height: 8),
                  RatingBar(
                    onRatingUpdate: (value) {},
                    ignoreGestures: true,
                    initialRating: ratings[index].rating.toDouble(),
                    itemSize: 20,
                    ratingWidget: RatingWidget(
                      full: const Icon(Icons.star, color: Colors.orange),
                      half: const Icon(Icons.star_half, color: Colors.orange),
                      empty:
                          const Icon(Icons.star_border, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
