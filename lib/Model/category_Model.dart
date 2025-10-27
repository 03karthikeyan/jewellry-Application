class CategoryModel {
  final String id;
  final String title;
  final String image;

  CategoryModel({
    required this.id,
    required this.title,
    required this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    String rawImage = json['image'] ?? '';

    // 🧹 Clean up duplicate path parts like "product_image/assets/"
    rawImage = rawImage.replaceAll(
      RegExp(r'assets/images/product_image/assets/'),
      'assets/images/',
    );

    // 🔄 Replace backslashes with forward slashes
    rawImage = rawImage.replaceAll(r'\', '/');

    // ✅ Ensure it starts with the correct base URL
    if (!rawImage.startsWith('http')) {
      rawImage = 'https://pheonixconstructions.com/jew/beta/$rawImage';
    }

    return CategoryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: rawImage,
    );
  }
}
