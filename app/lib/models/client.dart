class Client {
  final int id;
  final String name;
  final String url;
  final String? description;
  final String primaryColor;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.url,
    this.description,
    required this.primaryColor,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      description: json['description'],
      primaryColor: json['primaryColor'] ?? '#3B82F6',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'description': description,
      'primaryColor': primaryColor,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

