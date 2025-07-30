import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Model/address_Model.dart';

class OrderCheckoutPage extends StatefulWidget {
  final String userId;
  final Address address;
  final Map<String, dynamic> productDetails;

  const OrderCheckoutPage({
    Key? key,
    required this.userId,
    required this.address,
    required this.productDetails,
  }) : super(key: key);

  @override
  State<OrderCheckoutPage> createState() => _OrderCheckoutPageState();
}

class _OrderCheckoutPageState extends State<OrderCheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _grandTotalController = TextEditingController();
  final TextEditingController _cartIdController = TextEditingController();
  bool isPlacingOrder = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _grandTotalController.dispose();
    _cartIdController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isPlacingOrder = true);

    final String userId = widget.userId;
    final String grandTotal =
        widget.productDetails['price'].toString(); // Make sure it's a string
    final String addressId = widget.address.id.toString();
    final String cartId = '379'; // Or make it dynamic later

    final url =
        'https://pheonixconstructions.com/mobile/placeOrder.php?user_id=$userId'
        '&grandtotal=$grandTotal'
        '&address_id=$addressId'
        '&cart_id=$cartId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'Success') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Order Placed!')));
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to place order')));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Server error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error placing order')));
    }

    setState(() => isPlacingOrder = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        shrinkWrap: true, // Important: avoids infinite height
        physics: NeverScrollableScrollPhysics(), // Avoid scroll conflicts
        children: [
          Text(
            'Delivery Address:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(widget.address.getFullAddress()),
          SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grand Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Product: ${widget.productDetails['pname']}'),
                Text(
                  '₹${widget.productDetails['price']}',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),

                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isPlacingOrder ? null : _placeOrder,
                    child:
                        isPlacingOrder
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Place Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
