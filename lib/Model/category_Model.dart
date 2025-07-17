class CategoryModel {
  final String id;
  final String title;
  final String image;

  CategoryModel({required this.id, required this.title, required this.image});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      title: json['title'],
      image: 'https://pheonixconstructions.com/' + json['image'],
    );
  }
}
