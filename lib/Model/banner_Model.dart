class BannerModel {
  final String title;
  final String image;

  BannerModel({required this.title, required this.image});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    String rawImage = json['image'] ?? '';

    // Remove the duplicate "assets/banner_image/assets/" part
    rawImage = rawImage.replaceAll(
      RegExp(r'assets/banner_image/assets/'),
      'assets/images/', // ✅ Replace with correct path
    );

    // Replace backslashes with normal slashes
    rawImage = rawImage.replaceAll(r'\', '/');

    // Ensure it starts with the base URL
    if (!rawImage.startsWith('http')) {
      rawImage = 'https://afosindia.com/mobile/$rawImage';
    }

    return BannerModel(title: json['title'] ?? '', image: rawImage);
  }
}
