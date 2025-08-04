import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Screens/order_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> wishlist = [];
  bool isLoading = true;
  String? userId;
  String? errorMessage;
  late TabController _tabController;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '1';
    fetchOrders();
    fetchCart();
    fetchWishlist();
  }

  //Cart Tab method

  void _updateQuantity(String cartId, int change) {
    setState(() {
      final index = cart.indexWhere((item) => item['cart_id'] == cartId);
      if (index != -1) {
        int qty = int.tryParse(cart[index]['quantity'].toString()) ?? 1;
        qty += change;
        if (qty > 0) cart[index]['quantity'] = qty;
      }
    });
  }

  double _calculateTotalPrice() {
    return cart.fold(0, (sum, item) {
      double price = double.tryParse(item['unit_price'].toString()) ?? 0;
      int qty = int.tryParse(item['quantity'].toString()) ?? 1;
      return sum + (price * qty);
    });
  }

  void _goToCheckout() {
    // Navigate to checkout screen
  }

  Future<void> fetchCart() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://pheonixconstructions.com/mobile/fetchCartDetails.php?user_id=$userId',
        ),
      );
      print(
        'Cart fetch response: ${response.statusCode} - ${response.body.length} chars',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Map<String, dynamic>> cartItems = [];
        if (data['success'] == true && data['cart_items'] != null) {
          cartItems = List<Map<String, dynamic>>.from(data['cart_items']);
        }

        print('Cart items found: ${cartItems.length}');
        setState(() {
          cart = cartItems;
        });
      }
    } catch (e) {
      print('Cart fetch error: $e');
    }
  }

  Future<void> _deleteCartItem(String cartId) async {
    try {
      final url =
          'https://pheonixconstructions.com/mobile/cartDelete.php?user_id=$userId&cart_id=$cartId';
      print('Delete cart item URL: $url');

      final response = await http.get(Uri.parse(url));
      print('Delete response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        if (responseBody.contains('success') ||
            responseBody.contains('Success') ||
            responseBody == 'Success') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Item removed from cart')));
          // Add delay and force refresh
          await Future.delayed(Duration(milliseconds: 500));
          await fetchCart();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('API Response: $responseBody')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTTP Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Delete error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _clearAllCart() async {
    try {
      final url =
          'https://pheonixconstructions.com/mobile/cartDeleteAll.php?user_id=$userId';
      print('Clear all cart URL: $url');

      final response = await http.get(Uri.parse(url));
      print('Clear all response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        if (responseBody.contains('success') ||
            responseBody.contains('Success') ||
            responseBody == 'Success') {
          setState(() {
            cart.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('All items removed from cart')),
          );
          await fetchCart();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('API Response: $responseBody')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTTP Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Clear all error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> fetchWishlist() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://pheonixconstructions.com/mobile/wishlistFetch.php?user_id=$userId',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true &&
            data['wishlist_product_details'] != null) {
          setState(() {
            wishlist = List<Map<String, dynamic>>.from(
              data['wishlist_product_details'],
            );
          });
        }
      }
    } catch (e) {}
  }

  Future<void> _removeWishlistItem(String productId) async {
    try {
      final url =
          'https://pheonixconstructions.com/mobile/wishlistRemove.php?user_id=$userId&product_id=$productId';
      print('Remove wishlist item URL: $url');

      final response = await http.get(Uri.parse(url));
      print(
        'Remove wishlist response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        if (responseBody.contains('success') ||
            responseBody.contains('Success') ||
            responseBody == 'Success') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Item removed from wishlist')));
          await fetchWishlist();
        } else if (responseBody.toLowerCase().contains('not in wishlist') ||
            responseBody.toLowerCase().contains('already removed')) {
          // Item was already removed from database, remove from UI
          setState(() {
            wishlist.removeWhere((item) => item['id']?.toString() == productId);
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Item removed from wishlist')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('API Response: $responseBody')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTTP Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Remove wishlist error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://pheonixconstructions.com/mobile/myOrders.php?user_id=$userId',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> orderList = jsonData['data'];

          if (orderList.isEmpty) {
            setState(() {
              orders = []; // No orders
              isLoading = false;
            });
          } else {
            setState(() {
              orders =
                  orderList
                      .map<Map<String, dynamic>>(
                        (order) => {
                          "order_id": order['order_id'].toString(),
                          "productName": "Order #${order['order_id']}",
                          "productImage":
                              "assets/order_placeholder.jpg", // Placeholder until actual image
                          "price": "₹${order['total_price']}",
                          "status":
                              "Processing", // You can replace this with actual status if available
                          "date": order['created_at'],
                          "details":
                              order, // full order map if needed for detail screen
                        },
                      )
                      .toList();
              isLoading = false;
            });
          }
        } else {
          setState(() {
            orders = [];
            errorMessage = 'No orders found.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load orders. Please try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Account',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.brown),
        //   onPressed: () => Navigator.pop(context),
        // ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.brown,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.brown,
          onTap: (index) {
            if (index == 1) {
              // My Cart tab
              fetchCart();
            } else if (index == 2) {
              // My Wishlist tab
              fetchWishlist();
            }
          },
          tabs: [
            Tab(text: 'My Orders'),
            Tab(text: 'My Cart'),
            Tab(text: 'My Wishlist'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOrdersTab(), _buildCartTab(), _buildWishlistTab()],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.brown))
        : orders.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "You haven't placed any orders yet!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                "Start shopping now and track your orders here.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final product = order['product_details'] ?? {};
            final imageUrl =
                product['image'] != null
                    ? 'https://pheonixconstructions.com/admin/uploads/${product['image']}'
                    : '';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => OrderDetailsPage(
                          orderId: int.parse(order["order_id"].toString()),
                        ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      // borderRadius: BorderRadius.horizontal(
                      //   left: Radius.circular(12),
                      // ),
                      child:
                          imageUrl.isNotEmpty
                              ? Image.network(
                                imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.brown,
                                      ),
                                    ),
                              )
                              : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.brown,
                                ),
                              ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['product_name'] ?? 'Product Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Order ID: ${order['order_id']}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "₹ ${order['total_price']}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              order['created_at'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  Widget _buildCartTab() {
    return cart.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.brown.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18, color: Colors.brown),
              ),
            ],
          ),
        )
        : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Cart (${cart.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _clearAllCart,
                    child: Text('Clear All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                item['product_image'] != null &&
                                        item['product_image']
                                            .toString()
                                            .trim()
                                            .isNotEmpty
                                    ? Image.network(
                                      item['product_image'],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 30,
                                            color: Colors.brown,
                                          ),
                                        );
                                      },
                                    )
                                    : Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 30,
                                        color: Colors.brown,
                                      ),
                                    ),
                          ),

                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['product_name'] ?? 'Product',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '₹${item['unit_price']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    // IconButton(
                                    //   icon: Icon(Icons.remove_circle_outline),
                                    //   onPressed:
                                    //       () => _updateQuantity(
                                    //         item['cart_id'],
                                    //         -1,
                                    //       ),
                                    // ),
                                    Text(
                                      'Quantity: ${item['quantity']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    // IconButton(
                                    //   icon: Icon(Icons.add_circle_outline),
                                    //   onPressed:
                                    //       () => _updateQuantity(
                                    //         item['cart_id'],
                                    //         1,
                                    //       ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                () => _deleteCartItem(
                                  item['cart_id']?.toString() ?? '',
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // 🟨 Sticky Bottom Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '₹${_calculateTotalPrice()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _goToCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Checkout',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
  }

  Widget _buildWishlistTab() {
    return wishlist.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_outline,
                size: 80,
                color: Colors.brown.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                'Your wishlist is empty',
                style: TextStyle(fontSize: 18, color: Colors.brown),
              ),
            ],
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: wishlist.length,
          itemBuilder: (context, index) {
            final item = wishlist[index];
            final imageUrl = item['product_image'] ?? '';

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  Product Image with fallback
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          imageUrl.isNotEmpty
                              ? Image.network(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                              : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                    SizedBox(width: 12),
                    // Product Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['pname'] ?? 'Product Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            item['product_details'] ??
                                'No description available.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            (item['price'] != null &&
                                    item['price'].toString().trim().isNotEmpty)
                                ? '₹${item['price']}'
                                : 'Price on Request',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  (item['price'] != null &&
                                          item['price']
                                              .toString()
                                              .trim()
                                              .isNotEmpty)
                                      ? Colors.brown
                                      : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //  Remove Button
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      onPressed:
                          () =>
                              _removeWishlistItem(item['id']?.toString() ?? ''),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }
}

class OrderCard extends StatelessWidget {
  final String orderId;
  final String productName;
  final String productImage;
  final String price;
  final String status;
  final String date;
  final VoidCallback onTap;

  const OrderCard({
    required this.orderId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.status,
    required this.date,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors for different statuses
    Color statusColor;
    switch (status) {
      case "Delivered":
        statusColor = Colors.green;
        break;
      case "In Transit":
        statusColor = Colors.orange;
        break;
      case "Cancelled":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  productImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Order Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      price,
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Order Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        // Order Date
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
