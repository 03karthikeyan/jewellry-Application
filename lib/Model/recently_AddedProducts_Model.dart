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
  return RecentlyAddedProduct(
    id: json['id'],
    pname: json['pname'],
    pimage: 'https://afosindia.com/mobile/' + json['pimage'], // ✅ prepend base URL
    manufacturedBy: json['manufactured_by'],
    inWishlist: json['in_wishlist'] ?? false,
  );
}

}
