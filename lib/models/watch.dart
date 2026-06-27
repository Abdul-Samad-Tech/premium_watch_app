class Watch {
  final String id;
  final String name;
  final String brand;
  final double price;
  final List<String> images;
  final String description;
  final Map<String, String> specs;
  final String category;
  final bool isNew;
  final String style;
  final double caseSize; // in mm
  final List<String> colors;

  Watch({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.images,
    required this.description,
    required this.specs,
    required this.category,
    this.isNew = false,
    required this.style,
    required this.caseSize,
    required this.colors,
  });

  factory Watch.fromJson(Map<String, dynamic> json) {
    return Watch(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images'] as List),
      description: json['description'] as String,
      specs: Map<String, String>.from(json['specs'] as Map),
      category: json['category'] as String,
      isNew: json['isNew'] as bool? ?? false,
      style: json['style'] as String? ?? 'casual',
      caseSize: (json['caseSize'] as num?)?.toDouble() ?? 40.0,
      colors: List<String>.from(json['colors'] as List? ?? ['silver']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'images': images,
      'description': description,
      'specs': specs,
      'category': category,
      'isNew': isNew,
      'style': style,
      'caseSize': caseSize,
      'colors': colors,
    };
  }

  Watch copyWith({
    String? id,
    String? name,
    String? brand,
    double? price,
    List<String>? images,
    String? description,
    Map<String, String>? specs,
    String? category,
    bool? isNew,
    String? style,
    double? caseSize,
    List<String>? colors,
  }) {
    return Watch(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      images: images ?? this.images,
      description: description ?? this.description,
      specs: specs ?? this.specs,
      category: category ?? this.category,
      isNew: isNew ?? this.isNew,
      style: style ?? this.style,
      caseSize: caseSize ?? this.caseSize,
      colors: colors ?? this.colors,
    );
  }
}
