import 'package:flutter/material.dart';

import '../constants/ThemeConstants.dart';
import '../firebase_api_controller.dart';

class BusinessProductCard extends StatefulWidget {
  final String productName;
  final String productDescription;
  final double productPrice;
  final bool edit;
  final String? menuId;
  final String? productId;
  final String? productImage;

  const BusinessProductCard(BuildContext context,
      {super.key,
        required this.productName,
        required this.productDescription,
        required this.productPrice,
        required this.edit,
        this.menuId,
        this.productId,
        this.productImage
      });

  @override
  _BusinessProductCardState createState() => _BusinessProductCardState();
}

class _BusinessProductCardState extends State<BusinessProductCard> {
  bool isDeleted = false; // Manage isDeleted state here

  String capitalize(String input) {
    if (input == null || input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(radius: 40,
          backgroundImage: NetworkImage( widget.productImage ?? 'https://via.placeholder.com/150'), // Replace with your image URL
        ),
        title: Text(
          capitalize(widget.productName),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.productDescription),
        trailing: widget.edit
            ? IconButton(
          icon: isDeleted
              ? const Icon(Icons.remove_circle, color: Colors.grey)
              : const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () {
            if (isDeleted == false) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm Deletion",
                        style: TextStyle(color: primaryButton)),
                    content: const Text(
                        "Are you sure you want to delete this menu?",
                        style: TextStyle(color: secondaryButton)),
                    actions: [
                      TextButton(
                        child: const Text("Cancel",
                            style: TextStyle(color: secondaryButton)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text("Delete",
                            style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Perform the actual delete operation here
                          if (widget.menuId != null &&
                              widget.productId != null) {
                            deleteProductFromMenu(widget.menuId ?? "",
                                widget.productId ?? "");
                          }
                          // Toggle the state to update the UI
                          setState(() {
                            isDeleted = true;
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ) // Show icon if edit is true
            : Text(
          '£${widget.productPrice}',
          style: const TextStyle(fontSize: 15),
        ), // Show price text if edit is false
        onTap: () {
          _showProductDetails(
            context,
            widget.productName,
            widget.productDescription,
            widget.productPrice,
          );
        },
      ),
    );
  }

  void _showProductDetails(
      BuildContext context,
      String productName,
      String productDescription,
      double productPrice,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(productName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(productDescription),
              const SizedBox(height: 16),
              Text(
                'Price: £$productPrice',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
