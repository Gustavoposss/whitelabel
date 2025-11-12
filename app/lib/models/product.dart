class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? category;
  final String? image;
  final String provider; // 'brazilian' or 'european'
  final bool? hasDiscount;
  final String? discountValue;
  final Map<String, dynamic>? details;
  final List<String>? gallery;
  final String? departamento;
  final String? material;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
    this.image,
    required this.provider,
    this.hasDiscount,
    this.discountValue,
    this.details,
    this.gallery,
    this.departamento,
    this.material,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] is num) ? json['price'].toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
      category: json['category'],
      image: json['image'],
      provider: json['provider'] ?? 'brazilian',
      hasDiscount: json['hasDiscount'],
      discountValue: json['discountValue']?.toString(),
      details: json['details'] != null ? Map<String, dynamic>.from(json['details']) : null,
      gallery: json['gallery'] != null ? List<String>.from(json['gallery']) : null,
      departamento: json['departamento'],
      material: json['material'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image': image,
      'provider': provider,
      'hasDiscount': hasDiscount,
      'discountValue': discountValue,
      'details': details,
      'gallery': gallery,
      'departamento': departamento,
      'material': material,
    };
  }
}

