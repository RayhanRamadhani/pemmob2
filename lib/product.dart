class Product {
  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.quantity,
    this.imagePath,
    this.imageId,
  });

  final String? id;
  final String name;
  final double price;
  final String description;
  final String category;
  final int quantity;
  final String? imagePath;
  final String? imageId;

  String? get imageUrl =>
      imageId == null ? null : 'https://pos.cicd.web.id/assets/$imageId';

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageValue = json['image_url'];
    return Product(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      imageId: imageValue?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'description': description,
    'category': category,
    'quantity': quantity,
    if (imageId != null) 'image_url': imageId,
  };
}
