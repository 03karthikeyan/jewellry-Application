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
    // ⚡ Fix: Use correct folder for product images
    String imageUrl = 'https://afosindia.com/mobile/assets/images/product_image/${json['pimage']}';

    // Optional: remove extra slashes if server sends them
    imageUrl = imageUrl.replaceAll('//', '/');
    if (!imageUrl.startsWith('https://')) {
      imageUrl = 'https://afosindia.com/$imageUrl';
    }

    return RecentlyAddedProduct(
      id: json['id'],
      pname: json['pname'],
      pimage: imageUrl,
      manufacturedBy: json['manufactured_by'] ?? '',
      inWishlist: json['in_wishlist'] ?? false,
    );
  }
}
