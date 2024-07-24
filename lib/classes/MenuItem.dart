import 'package:AleTrail/classes/MenuProduct.dart';

class MenuItem {
  final String name;
  final String description;
  final String menuId;
  final List<dynamic>? productIds; // Make productIds nullable
  late final List<Menuproduct>? menuProducts; // Make product nullable

  MenuItem({
    required this.name,
    required this.description,
    required this.menuId,
    this.productIds, // Make productIds optional
    this.menuProducts, // Make productIds optional
  });
}
