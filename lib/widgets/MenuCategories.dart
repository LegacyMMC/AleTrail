import 'package:flutter/material.dart';
import '../classes/MenuItem.dart';

class MenuCategoryWidget extends StatelessWidget {
  final String category;
  final List<MenuItem> items;
  final VoidCallback? onTap;
  final bool edit;

  const MenuCategoryWidget({
    super.key,
    required this.category,
    required this.items,
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
                      // Handle delete action
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
