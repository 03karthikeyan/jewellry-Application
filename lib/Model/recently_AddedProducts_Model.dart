class RecentlyAddedProduct {
  final String id;
  final String pname;
  final String pimage;
  final String manufacturedBy;
  final bool inWishlist;

  RecentlyAddedProduct({
    required this.id,
    required this.pname,
    required this.pimage,
    required this.manufacturedBy,
    required this.inWishlist,
  });

  factory RecentlyAddedProduct.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['pimage'] ?? '';

    // If the image URL is not full, build it manually
    if (!imageUrl.startsWith('http')) {
      imageUrl =
          'https://pheonixconstructions.com/jew/beta/assets/images/product_image/$imageUrl';
    }

    // Clean HTML tags from manufactured_by
    final cleanManufacturedBy = (json['manufactured_by'] ?? '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();

    return RecentlyAddedProduct(
      id: json['id'] ?? '',
      pname: json['pname'] ?? '',
      pimage: imageUrl,
      manufacturedBy: cleanManufacturedBy,
      inWishlist: json['in_wishlist'] ?? false,
    );
  }
}
