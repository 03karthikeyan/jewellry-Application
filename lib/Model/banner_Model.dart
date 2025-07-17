class BannerModel {
  final String title;
  final String image;

  BannerModel({required this.title, required this.image});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      title: json['title'],
      image: 'http://pheonixconstructions.com/' + json['image'],
    );
  }
}
