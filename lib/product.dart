class Product {
  Product({
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.quantity,
    this.imagePath,
  });

  final String name;
  final double price;
  final String description;
  final String category;
  final int quantity;
  final String? imagePath;
}
