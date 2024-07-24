import 'package:flutter/material.dart';
import '../classes/MenuItem.dart';
import '../constants/ThemeConstants.dart';

class MenuButtonWidget extends StatelessWidget {
  final String category;
  final List<MenuItem> items;
  final VoidCallback? onTap;
  final bool edit;
  final bool isSelected;

  const MenuButtonWidget({
    super.key,
    required this.category,
    required this.items,
    this.onTap,
    required this.edit,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        color: isSelected ? selectedYellowAccentButton : notSelectedGreyAccentButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.0), // Ensure the ripple effect is rounded
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 25.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (edit)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      // Handle delete action
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
