import 'package:AleTrail/constants/ThemeConstants.dart';
import 'package:flutter/material.dart';
import '../classes/MenuItem.dart';
import '../firebase_api_controller.dart';

class BusinessMenuCategoryWidget extends StatelessWidget {
  final String category;
  final String establishmentId;
  final List<MenuItem> items;
  final VoidCallback? onTap;
  final bool edit;

  const BusinessMenuCategoryWidget({
    super.key,
    required this.category,
    required this.items,
    required this.establishmentId,
    this.onTap,
    required this.edit
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            title: Text(
              category,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (edit)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Deletion", style: TextStyle(color: primaryButton),),
                            content: const Text("Are you sure you want to delete this menu?", style: TextStyle(color: secondaryButton),),
                            actions: [
                              TextButton(
                                child: const Text("Cancel", style: TextStyle(color: secondaryButton)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  // Handle delete action
                                  Navigator.of(context).pop();
                                  // Perform the actual delete operation here
                                  deleteMenuFromEstablishment(establishmentId, items.first.menuId);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
