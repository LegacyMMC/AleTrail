import 'package:flutter/material.dart';

import '../pages/BusinessEstablishmentView.dart';

class BuisnessEstablishmentWidget extends StatelessWidget {
  final String establishmentName;
  final String establishmentImage;
  final String establishmentDesc;
  final String establishmentId;

  const BuisnessEstablishmentWidget({
    super.key,
    required this.establishmentName,
    required this.establishmentImage,
    required this.establishmentDesc,
    required this.establishmentId,
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
            builder: (context) => EstablishmentViewPage(pubId: establishmentId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          height: 200,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                  10.0), // Ensure the ripple effect is rounded
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Center the content horizontally
                children: [
                  // Network image with rounded corners at the top
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    child: Image.network(
                      establishmentImage, // Replace with your image URL
                      height: 80.0, // Set a fixed height for the image
                      width: double
                          .infinity, // Make the image span the full width of the card
                      fit: BoxFit.cover, // Ensure the image covers the area
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        }
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return const Center(
                            child: Icon(Icons.query_builder_outlined,
                                color: Colors.red));
                      },
                    ),
                  ),
                  // Padding to ensure space between image and text
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        5, 5, 5, 0), // Adjust padding to center content
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Center text within the column
                      children: [
                        // Add your text here
                        Text(
                          establishmentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            letterSpacing: 3,
                          ),
                          overflow: TextOverflow
                              .ellipsis, // Ensure text doesn't overflow
                          maxLines: 1, // Restrict to a single line
                        ),
                        const SizedBox(
                            height: 3.0), // Space between text elements
                        Text(
                          establishmentDesc,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 12.0,
                          ),
                          textAlign: TextAlign.center, // Center the text
                        ),
                        const SizedBox(height: 5.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
