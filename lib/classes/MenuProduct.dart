class Menuproduct {
  final String productName;
  final String productDescription;
  final double productPrice;

  Menuproduct({
    required this.productName,
    required this.productDescription,
    required this.productPrice,
  });

  // Optionally, add a method to convert to/from JSON if needed
  factory Menuproduct.fromJson(Map<String, dynamic> json) {
    return Menuproduct(
      productName: json['ProductName'],
      productDescription: json['ProductDescription'],
      productPrice: json['ProductPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductName': productName,
      'ProductDescription': productDescription,
      'ProductPrice': productPrice,
    };
  }
}
