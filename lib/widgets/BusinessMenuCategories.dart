import 'package:AleTrail/constants/ThemeConstants.dart';
import 'package:flutter/material.dart';
import '../classes/MenuItem.dart';
import '../firebase_api_controller.dart';

// Convert the widget to StatefulWidget
class BusinessMenuCategoryWidget extends StatefulWidget {
  final String category;
  final String establishmentId;
  final List<MenuItem> items;
  final VoidCallback? onTap;
  final bool edit;

  const BusinessMenuCategoryWidget(
      {super.key,
      required this.category,
      required this.items,
      required this.establishmentId,
      this.onTap,
      required this.edit});

  @override
  _BusinessMenuCategoryWidgetState createState() =>
      _BusinessMenuCategoryWidgetState();
}

class _BusinessMenuCategoryWidgetState
    extends State<BusinessMenuCategoryWidget> {
  bool isDeleted = false; // Manage isDeleted state here

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
          onTap: widget.onTap,
          child: ListTile(
            title: Text(
              widget.category,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: isDeleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.edit)
                  IconButton(
                    icon: isDeleted
                        ? const Icon(Icons.remove_circle, color: Colors.grey)
                        : const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
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
                                  deleteMenuFromEstablishment(
                                      widget.establishmentId,
                                      widget.items.first.menuId);

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
