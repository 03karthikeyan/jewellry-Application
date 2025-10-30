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

    // 🧹 Step 1: Remove wrong duplicate folder names
    rawImage = rawImage
        .replaceAll('product_image/assets/images/category/', 'assets/images/category/')
        .replaceAll('product_image/assets/images/product_image/', 'assets/images/product_image/')
        .replaceAll('assets/images/product_image/assets/images/category/', 'assets/images/category/')
        .replaceAll('assets/images/product_image/assets/images/product_image/', 'assets/images/product_image/');

    // 🔄 Step 2: Fix backslashes (just in case)
    rawImage = rawImage.replaceAll(r'\', '/');

    // ✅ Step 3: Ensure full base URL
    if (!rawImage.startsWith('http')) {
      rawImage = 'https://pheonixconstructions.com/jew/beta/$rawImage';
    }

    return CategoryModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      image: rawImage,
    );
  }
}
