class ProductModel {
  final String id;
  final String name;
  final String image;
  final String manufacturedBy;
  final bool inWishlist;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.manufacturedBy,
    required this.inWishlist,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    const String baseUrl =
        "https://pheonixconstructions.com/jew/beta/assets/images/product_image/";

    String imagePath = json['pimage'] ?? '';

    // Clean unwanted slashes or duplicate parts
    imagePath = imagePath.replaceAll(r'\', '/');
    imagePath = imagePath.replaceAll(RegExp(r'^/+'), '');

    // If imagePath is not full URL, prepend base URL
    if (!imagePath.startsWith('http')) {
      imagePath = baseUrl + imagePath;
    }

    return ProductModel(
      id: json['id'] ?? '',
      name: json['pname'] ?? '',
      image: imagePath,
      manufacturedBy: json['manufactured_by'] ?? '',
      inWishlist:
          json['in_wishlist'] == true ||
          json['in_wishlist'] == 'true' ||
          json['in_wishlist'] == 1,
    );
  }
}
