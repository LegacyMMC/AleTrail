import 'package:flutter/material.dart';
import '../pages/BusinessEstablishmentView.dart';
import '../pages/PubPage[LEGACY].dart';

class BusinessCard extends StatelessWidget {
  final String pubId;
  final String imageUrl;
  final String title;
  final String tags;
  final String popularity;

  const BusinessCard({
    super.key, // Make key nullable
    required this.imageUrl,
    required this.pubId,
    required this.title,
    required this.tags,
    required this.popularity,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Perform action when the card is clicked
        // For example, navigate to another screen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EstablishmentViewPage(pubId: pubId)),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 25,
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 15),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(
                  imageUrl.isNotEmpty
                      ? imageUrl
                      : "https://cdn.pixabay.com/photo/2020/12/29/23/32/house-5871895_1280.jpg",
                ),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tags,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Explicit text color
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      popularity,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black, // Explicit text color
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
