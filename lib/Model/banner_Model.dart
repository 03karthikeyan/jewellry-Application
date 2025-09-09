class BannerModel {
  final String title;
  final String image;

  BannerModel({required this.title, required this.image});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    String cleanImage = (json['image'] ?? '').toString().trim();
    cleanImage = cleanImage.replaceAll("\n", ""); // remove unwanted newline

    return BannerModel(
      title: json['title']?.toString().trim() ?? '',
      image: cleanImage,
    );
  }
}
