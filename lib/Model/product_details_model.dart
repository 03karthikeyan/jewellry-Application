class ProductDetail {
  final String productId;
  final String variantOptionName;
  final String purity;
  final String makingCharges;
  final String metalTypeName;
  final String ratePerGram;
  final String metalWeight;
  final String deliveryDays;

  ProductDetail({
    required this.productId,
    required this.variantOptionName,
    required this.purity,
    required this.makingCharges,
    required this.metalTypeName,
    required this.ratePerGram,
    required this.metalWeight,
    required this.deliveryDays,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      productId: json['product_id'],
      variantOptionName: json['variant_option_name'],
      purity: json['purity'],
      makingCharges: json['making_charges'],
      metalTypeName: json['metal_type_name'],
      ratePerGram: json['current_rate_per_gram'],
      metalWeight: json['metal_weight'],
      deliveryDays: json['delivery_days'],
    );
  }
}
