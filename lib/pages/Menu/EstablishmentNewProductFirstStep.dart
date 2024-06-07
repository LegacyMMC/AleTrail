import 'package:AleTrail/constants/ThemeConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/ProductTypes.dart';
import '../../firebase_api_controller.dart';

class EstablishmentProductOnePage extends StatefulWidget {
  final String menuId;
  const EstablishmentProductOnePage({super.key, required this.menuId});

  @override
  State<EstablishmentProductOnePage> createState() => _EstablishmentOnePageState();
}

class _EstablishmentOnePageState extends State<EstablishmentProductOnePage> {
  // User parameters
  String ProductName = "";
  String ProductPrice = "";
  String ProductDesc = "";
  String selectedProductType = ""; // New variable for selected product type

  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Define relative positions and sizes based on screen dimensions
    final double orangeCornerBottom = screenHeight * 0.0000001 - 110;
    final double aleTrailTitleTop = screenHeight * 0.15;
    final double registerButtonTop = screenHeight * 0.65;

    return Scaffold(
      resizeToAvoidBottomInset:
      false, // Prevents resizing when keyboard appears
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              bottom: orangeCornerBottom,
              left: 0,
              child: SvgPicture.asset(
                "lib/assets/images/svg/orangeCorner.svg",
                colorFilter:
                const ColorFilter.mode(Colors.orange, BlendMode.srcIn),
                semanticsLabel: 'Orange Corner SVG',
              ),
            ),
            Positioned(
              top: aleTrailTitleTop,
              right: screenWidth * 0.07,
              child: SvgPicture.asset(
                "lib/assets/images/svg/AletrailNewProduct.svg",
                semanticsLabel: 'AleTrail New Product',
              ),
            ),
            Positioned(
              top: registerButtonTop *
                  0.45, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border:
                  Border.all(color: Colors.grey, width: 2), // Outer border
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  elevation: 35, // Set the elevation here
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 50, // Set the desired height for multi-line support
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines:
                      null, // Allows the TextField to support multiple lines
                      onChanged: (value) {
                        ProductName = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Product Name',
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20,
                            15), // Adjust padding for multi-line support
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: registerButtonTop *
                  0.60, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border:
                  Border.all(color: Colors.grey, width: 2), // Outer border
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  elevation: 35, // Set the elevation here
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 50, // Set the desired height for multi-line support
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number, // Ensure number input
                      onChanged: (value) {
                        ProductPrice = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Product Price',
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20,
                            15), // Adjust padding for multi-line support
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // New dropdown for product type
            Positioned(
              top: registerButtonTop * 0.75,
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border:
                  Border.all(color: Colors.grey, width: 2), // Outer border
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  elevation: 35, // Set the elevation here
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 50, // Set the desired height for the dropdown
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedProductType.isEmpty
                          ? null
                          : selectedProductType,
                      onChanged: (value) {
                        setState(() {
                          selectedProductType = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Select Product Type',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                      ),
                      items: Products()
                          .productTypes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: registerButtonTop *
                  0.90, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border:
                  Border.all(color: Colors.grey, width: 2), // Outer border
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  elevation: 35, // Set the elevation here
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height:
                    200, // Set the desired height for multi-line support
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines:
                      null, // Allows the TextField to support multiple lines
                      onChanged: (value) {
                        ProductDesc = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Product Description',
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20,
                            15), // Adjust padding for multi-line support
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: registerButtonTop * 1.35,
              right: screenWidth * 0.11,
              child: ElevatedButton(
                style: const ButtonStyle(
                  elevation: MaterialStatePropertyAll(15),
                  backgroundColor: MaterialStatePropertyAll(secondaryButton),
                ),
                onPressed: () async {
                  // Check if name, price, and product type are not empty
                  if (ProductName != "" &&
                      ProductPrice != "" &&
                      selectedProductType != "") {
                    // Validate ProductPrice to be a number
                    if (double.tryParse(ProductPrice) != null) {
                      // Register to backend
                      String stepCompleted = await addNewProductToFirebase(
                          widget.menuId,
                          ProductName,
                          ProductPrice,
                          ProductDesc,
                          selectedProductType); // Include product type
                      if (stepCompleted != "") {
                        Navigator.of(context).pop();
                      }
                    } else {
                      // Show error message if ProductPrice is not a valid number
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid price'),
                        ),
                      );
                    }
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.24),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: 0,
              child: SvgPicture.asset(
                "lib/assets/images/svg/yellowCorner.svg",
                semanticsLabel: 'Yellow Corner SVG',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
