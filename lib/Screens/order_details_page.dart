import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Model/order_details_model.dart';
import 'package:jewellery/Model/product_Model.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  const OrderDetailsPage({required this.orderId, super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  OrderDetailsModel? orderDetails;
  String? productName;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://pheonixconstructions.com/mobile/orderDetails.php?order_id=${widget.orderId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'].isNotEmpty) {
          final order = OrderDetailsModel.fromJson(data['data'][0]);
          final pname = await fetchProductName(order.productId);

          setState(() {
            orderDetails = order;
            productName = pname;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'No order details found.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load order details.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<String> fetchProductName(int productId) async {
    final response = await http.get(
      Uri.parse(
        'https://pheonixconstructions.com/mobile/productDetails.php?product_id=$productId',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true && data['data'] != null) {
        // Use your ProductModel here if needed
        final product = ProductModel.fromJson(data['data']);
        return product.name; // or product.pname depending on API field
      } else {
        return "Product #$productId"; // fallback
      }
    } else {
      return "Product #$productId"; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.brown),
              )
              : orderDetails == null
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name & Date
                        Text(
                          productName ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Ordered on: ${orderDetails!.createdAt}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Divider(height: 30, thickness: 1),

                        // Order Info
                        _infoRow(
                          Icons.confirmation_number,
                          "Order ID",
                          "${orderDetails!.orderId}",
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          Icons.inventory_2_rounded,
                          "Quantity",
                          "${orderDetails!.quantity}",
                        ),
                        _infoRow(
                          Icons.currency_rupee_rounded,
                          "Total Price",
                          "₹${orderDetails!.totalPrice}",
                        ),

                        const Divider(height: 30, thickness: 1),
                        const Text(
                          "Variants",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _variantRow("Size", orderDetails!.variants['size']),
                        _variantRow("Color", orderDetails!.variants['color']),

                        const Divider(height: 30, thickness: 1),
                        const Text(
                          "Metal Info",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _variantRow("Type", orderDetails!.metalDetails['type']),
                        _variantRow(
                          "Purity",
                          orderDetails!.metalDetails['purity'],
                        ),
                        _variantRow(
                          "Weight",
                          "${orderDetails!.metalDetails['weight']} g",
                        ),

                        const Divider(height: 30, thickness: 1),
                        const Text(
                          "Stone Info",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _variantRow("Type", orderDetails!.stoneDetails['type']),
                        _variantRow(
                          "Weight",
                          "${orderDetails!.stoneDetails['weight']} ct",
                        ),
                        _variantRow(
                          "Clarity",
                          orderDetails!.stoneDetails['clarity'],
                        ),

                        const Divider(height: 30, thickness: 1),
                        _infoRow(
                          Icons.verified,
                          "Purity Info",
                          orderDetails!.purityInfo,
                        ),

                        const SizedBox(height: 25),

                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Reorder logic
                          },
                          icon: const Icon(
                            Icons.shopping_cart_checkout_rounded,
                          ),
                          label: const Text("Reorder"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade700,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

//Helper Widgets

Widget _infoRow(IconData icon, String title, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 22, color: Colors.brown.shade400),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _variantRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
