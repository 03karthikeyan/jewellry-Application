class BannerModel {
  final String title;
  final String image;

  BannerModel({required this.title, required this.image});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'] ?? '';

    // Decode escaped slashes if any
    imageUrl = imageUrl.replaceAll(r'\/', '/');

    // If the URL is relative, prepend the base URL
    if (!imageUrl.startsWith('http')) {
      imageUrl = 'https://pheonixconstructions.com/$imageUrl';
    }

    return BannerModel(
      title: json['title'] ?? '',
      image: imageUrl,
    );
  }
}
