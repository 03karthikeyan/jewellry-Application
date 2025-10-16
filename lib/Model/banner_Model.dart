class BannerModel {
  final String title;
  final String image;

  BannerModel({required this.title, required this.image});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    String rawImage = json['image'] ?? '';

    // 🧠 Fix duplicate 'banner_image/assets' if it exists
    String fixedImage = rawImage.replaceAll(
      'assets/banner_image/assets/',
      'assets/',
    );

    // 🧩 Ensure correct base URL
    if (!fixedImage.startsWith('http')) {
      fixedImage = 'https://afosindia.com/mobile/$fixedImage';
    }

    return BannerModel(title: json['title'] ?? '', image: fixedImage);
  }
}
