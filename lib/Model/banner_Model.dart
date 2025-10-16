class BannerModel {
  final String title;
  final String image;

  BannerModel({required this.title, required this.image});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    String rawImage = json['image'] ?? '';

    // Remove accidental duplicated folder paths
    String cleanedImage = rawImage.replaceAll(
      'assets/banner_image/assets/',
      'assets/banner_image/',
    );

    // ✅ Prepend base URL if it's a relative path
    if (!cleanedImage.startsWith('http')) {
      cleanedImage = 'https://afosindia.com/mobile/$cleanedImage';
    }

    return BannerModel(
      title: json['title'] ?? '',
      image: cleanedImage,
    );
  }
}
