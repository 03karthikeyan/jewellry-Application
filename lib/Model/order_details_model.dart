import 'dart:convert';

class OrderDetailsModel {
  final int orderId;
  final int productId;
  final int quantity;
  final String subtotal;
  final String unitPrice;
  final String totalPrice;
  final String createdAt;
  final Map<String, dynamic> variants;
  final Map<String, dynamic> metalDetails;
  final Map<String, dynamic> stoneDetails;
  final String purityInfo;

  OrderDetailsModel({
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.subtotal,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
    required this.variants,
    required this.metalDetails,
    required this.stoneDetails,
    required this.purityInfo,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      subtotal: json['subtotal'],
      unitPrice: json['unit_price'],
      totalPrice: json['total_price'],
      createdAt: json['created_at'],
      variants: jsonDecode(json['variants']),
      metalDetails: jsonDecode(json['metal_details']),
      stoneDetails: jsonDecode(json['stone_details']),
      purityInfo: json['purity_info'],
    );
  }
}
