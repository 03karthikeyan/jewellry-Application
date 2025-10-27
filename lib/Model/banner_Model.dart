class BannerModel {
  final String title;
  final String image;

  BannerModel({required this.title, required this.image});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    String rawImage = json['image'] ?? '';

    // Convert escaped slashes from API response (e.g. https:\/\/...)
    rawImage = rawImage.replaceAll(r'\/', '/');

    // Ensure full valid URL
    if (!rawImage.startsWith('http')) {
      rawImage = 'https://pheonixconstructions.com/$rawImage';
    }

    return BannerModel(title: json['title'] ?? '', image: rawImage.trim());
  }
}
