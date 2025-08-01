class ProductModel {
  final String id;
  final String name;
  final String image;

  ProductModel({required this.id, required this.name, required this.image});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['pname'],
      image:
          'https://pheonixconstructions.com/assets/images/product_image/${json['pimage']}',
    );
  }
}
