import 'package:flutter/material.dart';

class MenuProductWidget extends StatelessWidget {
  final String productName;
  final String productImage;
  final String productPrice;
  final String productDesc;

  const MenuProductWidget({
    super.key,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productDesc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(height: 200 ,child:  Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0), // Ensure the ripple effect is rounded
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Network image with rounded corners at the top
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                child: Image.network(
                  'https://wallpapercave.com/wp/rpBDuCI.jpg', // Replace with your image URL
                  height: 80.0, // Set a fixed height for the image
                  width: double.infinity, // Make the image span the full width of the card
                  fit: BoxFit.cover, // Ensure the image covers the area
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    }
                  },
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return const Center(child: Icon(Icons.query_builder_outlined, color: Colors.red));
                  },
                ),
              ),
              // Padding to ensure space between image and text
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add your text here
                    Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: 3.0), // Space between text elements
                    Text(
                      productDesc,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 11.0,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      productPrice,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
