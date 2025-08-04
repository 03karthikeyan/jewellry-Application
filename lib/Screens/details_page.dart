import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Model/address_Model.dart';
import 'package:jewellery/Screens/orderSummary_Page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailsPage extends StatefulWidget {
  final String productId;
  final String imagePath;

  DetailsPage({required this.productId, required this.imagePath});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Map<String, dynamic>? productDetails;
  bool isLoading = true;
  List<Map<String, dynamic>> allVariants = [];
  Map<String, List<Map<String, dynamic>>> variantGroups = {};
  Map<String, Map<String, dynamic>> selectedOptions = {};
  bool isInWishlist = false;
  String? userId;
  bool isWishlistLoading = false;
  bool isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    fetchProductDetails();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '1';
    });
    checkWishlistStatus();
  }

  Future<void> fetchProductDetails() async {
    try {
      String cleanProductId = widget.productId.replaceAll('"', '');

      final url =
          'https://pheonixconstructions.com/mobile/productDetails.php?product_id=$cleanProductId';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'Success' && data['Product_Details'] != null) {
          allVariants = List<Map<String, dynamic>>.from(
            data['Product_Details'],
          );

          variantGroups.clear();
          for (var v in allVariants) {
            variantGroups.putIfAbsent(v['variant_type_name'], () => []);
            if (!variantGroups[v['variant_type_name']]!.any(
              (e) => e['variant_option_name'] == v['variant_option_name'],
            )) {
              variantGroups[v['variant_type_name']]!.add(v);
            }
          }

          selectedOptions.clear();
          variantGroups.forEach((type, options) {
            selectedOptions[type] = options.first;
          });

          productDetails = _getCurrentVariant();

          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            productDetails = null;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _getCurrentVariant() {
    return allVariants.firstWhere(
      (variant) => variantGroups.keys.every(
        (type) =>
            variant['variant_type_name'] == type &&
            variant['variant_option_name'] ==
                selectedOptions[type]?['variant_option_name'],
      ),
      orElse: () => selectedOptions.values.first,
    );
  }

  double _calculateFinalPrice() {
    if (productDetails == null) return 0;

    double metalWeight =
        double.tryParse(productDetails!['metal_weight']?.toString() ?? '0') ??
        0;
    double stoneWeight =
        double.tryParse(productDetails!['stone_weight']?.toString() ?? '0') ??
        0;
    double makingPercent =
        double.tryParse(productDetails!['making_charges']?.toString() ?? '0') ??
        0;
    double wastagePercent =
        double.tryParse(
          productDetails!['wastage_percent']?.toString() ?? '0',
        ) ??
        0;
    double metalRate =
        double.tryParse(productDetails!['mprice']?.toString() ?? '0') ?? 0;
    double discountAmount =
        double.tryParse(productDetails!['discount_price']?.toString() ?? '0') ??
        0;

    double metalValue = metalRate * metalWeight;
    double wastageCharges = metalValue * wastagePercent / 100;
    double makingCharges = metalValue * makingPercent / 100;
    double stoneRate = stoneWeight > 0 ? 50000 : 0;
    double stoneValue = stoneRate * stoneWeight;

    double subtotal = metalValue + wastageCharges + makingCharges + stoneValue;
    double gst = subtotal * 0.03;
    double totalBeforeDiscount = subtotal + gst;
    double finalPrice = totalBeforeDiscount - discountAmount;

    return finalPrice;
  }

  Widget _variantSelectors() {
    if (variantGroups.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          variantGroups.entries.map((entry) {
            final type = entry.key;
            final options = entry.value;
            final selected = selectedOptions[type]?['variant_option_name'];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      options.map((option) {
                        final isSelected =
                            selected == option['variant_option_name'];
                        return ChoiceChip(
                          label: Text(option['variant_option_name']),
                          selected: isSelected,
                          onSelected: (selectedChip) {
                            setState(() {
                              selectedOptions[type] = option;
                              productDetails = _getCurrentVariant();
                            });
                          },
                          selectedColor: Colors.brown.shade100,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.brown : Colors.black,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                ),
                SizedBox(height: 12),
              ],
            );
          }).toList(),
    );
  }

  Future<void> checkWishlistStatus() async {
    if (userId == null) return;
    setState(() => isWishlistLoading = true);
    try {
      String cleanProductId = widget.productId.replaceAll('"', '');
      final url =
          'https://pheonixconstructions.com/mobile/checkWishlist.php?user_id=$userId&product_id=$cleanProductId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bool isInList = false;
        if (data.containsKey('result') && data['result'] == 'Success')
          isInList = true;
        if (data.containsKey('exists') && data['exists'] == true)
          isInList = true;
        if (data.containsKey('status') && data['status'] == 'found')
          isInList = true;
        setState(() {
          isInWishlist = isInList;
        });
      }
    } catch (e) {}
    setState(() => isWishlistLoading = false);
  }

  Future<void> toggleWishlist() async {
    if (userId == null || isWishlistLoading) return;
    setState(() => isWishlistLoading = true);
    try {
      String cleanProductId = widget.productId.replaceAll('"', '');
      final url =
          isInWishlist
              ? 'https://pheonixconstructions.com/mobile/wishlistRemove.php?user_id=$userId&product_id=$cleanProductId'
              : 'https://pheonixconstructions.com/mobile/wishlistAdd.php?user_id=$userId&product_id=$cleanProductId';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bool isSuccess = false;
        if (data.containsKey('result') && data['result'] == 'Success')
          isSuccess = true;
        if (data.containsKey('success') && data['success'] == 1)
          isSuccess = true;
        if (data.containsKey('status') && data['status'] == 'success')
          isSuccess = true;
        if (isSuccess) {
          setState(() {
            isInWishlist = !isInWishlist;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isInWishlist ? 'Added to wishlist' : 'Removed from wishlist',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to update wishlist')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating wishlist')));
    }
    setState(() => isWishlistLoading = false);
  }

  Future<void> addToCart() async {
    if (userId == null || isAddingToCart) return;
    setState(() => isAddingToCart = true);
    try {
      String cleanProductId = widget.productId.replaceAll('"', '');
      String unitPrice = _calculateFinalPrice().toStringAsFixed(2);
      String unitMrp = productDetails!['price']?.toString() ?? unitPrice;
      String totalPrice = unitPrice;
      String totalMrp = unitMrp;

      // Build variants JSON
      Map<String, String> variants = {};
      selectedOptions.forEach((type, option) {
        variants[type.toLowerCase()] = option['variant_option_name'] ?? '';
      });
      String variantsJson = Uri.encodeComponent(json.encode(variants));

      // Get additional product details
      String metalWeight = productDetails!['metal_weight']?.toString() ?? '0';
      String stoneWeight = productDetails!['stone_weight']?.toString() ?? '0';
      String makingPercent =
          productDetails!['making_charges']?.toString() ?? '0';
      String wastagePercent =
          productDetails!['wastage_percent']?.toString() ?? '0';
      String purityInfo = Uri.encodeComponent(
        productDetails!['purity_info']?.toString() ?? '22K Gold',
      );

      // Build metal details JSON
      Map<String, dynamic> metalDetails = {
        'type': productDetails!['metal_type_name'] ?? 'gold',
        'purity': '${productDetails!['purity'] ?? '22'}K',
        'weight': double.tryParse(metalWeight) ?? 0,
      };
      String metalDetailsJson = Uri.encodeComponent(json.encode(metalDetails));

      // Build stone details JSON (if available)
      Map<String, dynamic> stoneDetails = {
        'type': 'diamond',
        'weight': double.tryParse(stoneWeight) ?? 0,
        'clarity': 'VS1',
      };
      String stoneDetailsJson = Uri.encodeComponent(json.encode(stoneDetails));

      // Calculate rates
      double makingRate =
          (double.tryParse(unitPrice) ?? 0) *
          (double.tryParse(makingPercent) ?? 0) /
          100;
      double wastageRate =
          (double.tryParse(unitPrice) ?? 0) *
          (double.tryParse(wastagePercent) ?? 0) /
          100;
      double subtotal =
          (double.tryParse(unitPrice) ?? 0) - makingRate - wastageRate;

      final url =
          'https://pheonixconstructions.com/mobile/addToCart.php'
          '?user_id=$userId'
          '&product_id=$cleanProductId'
          '&quantity=1'
          '&unit_price=$unitPrice'
          '&total_price=$totalPrice'
          '&unit_mrp=$unitMrp'
          '&total_mrp=$totalMrp'
          '&variants=$variantsJson'
          '&total_metal_weight=$metalWeight'
          '&total_stone_weight=$stoneWeight'
          '&metal_details=$metalDetailsJson'
          '&stone_details=$stoneDetailsJson'
          '&making_percent=$makingPercent'
          '&wastage_percent=$wastagePercent'
          '&making_rate=${makingRate.toStringAsFixed(2)}'
          '&wastage_rate=${wastageRate.toStringAsFixed(2)}'
          '&purity_info=$purityInfo'
          '&subtotal=${subtotal.toStringAsFixed(2)}';

      print('Add to cart URL: $url');
      final response = await http.get(Uri.parse(url));
      print('Add to cart response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to cart successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('API Error: ${data['message'] ?? 'Unknown error'}'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTTP Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Add to cart error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => isAddingToCart = false);
  }

  Widget _buildPriceBreakdown() {
    if (productDetails == null) return SizedBox();

    // Extract & calculate values (same as before)
    double basePrice =
        double.tryParse(productDetails!['price']?.toString() ?? '0') ?? 0;
    double discountAmount =
        double.tryParse(productDetails!['discount_price']?.toString() ?? '0') ??
        0;
    double metalWeight =
        double.tryParse(productDetails!['metal_weight']?.toString() ?? '0') ??
        0;
    double stoneWeight =
        double.tryParse(productDetails!['stone_weight']?.toString() ?? '0') ??
        0;
    double makingPercent =
        double.tryParse(productDetails!['making_charges']?.toString() ?? '0') ??
        0;
    double wastagePercent =
        double.tryParse(
          productDetails!['wastage_percent']?.toString() ?? '0',
        ) ??
        0;
    double metalRate =
        double.tryParse(productDetails!['mprice']?.toString() ?? '0') ?? 0;

    double metalValue = metalRate * metalWeight;
    double wastageCharges = metalValue * wastagePercent / 100;
    double makingCharges = metalValue * makingPercent / 100;
    double stoneRate = stoneWeight > 0 ? 50000 : 0;
    double stoneValue = stoneRate * stoneWeight;

    double subtotal = metalValue + wastageCharges + makingCharges + stoneValue;
    double gst = subtotal * 0.03;
    double totalBeforeDiscount = subtotal + gst;
    double finalPrice = totalBeforeDiscount - discountAmount;
    double grandTotal = finalPrice;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.brown.shade100, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🧾 Price Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade700,
            ),
          ),
          SizedBox(height: 12),

          _buildSummaryRow("Base Price", "₹${basePrice.toStringAsFixed(2)}"),
          _buildSummaryRow(
            "Discount",
            "-₹${discountAmount.toStringAsFixed(2)}",
          ),
          Divider(),

          _sectionTitle("Metal Details"),
          _buildDetailRow(
            '${productDetails!['purity'] ?? '22'}K ${productDetails!['metal_type_name'] ?? 'Gold'}',
            '₹${metalRate.toStringAsFixed(0)}',
            '${metalWeight.toStringAsFixed(1)}g',
            '₹${metalValue.toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            "Wastage Charges",
            '',
            '${wastagePercent.toStringAsFixed(0)}%',
            '₹${wastageCharges.toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            "Making Charges",
            '',
            '${makingPercent.toStringAsFixed(0)}%',
            '₹${makingCharges.toStringAsFixed(2)}',
          ),

          if (stoneWeight > 0) ...[
            SizedBox(height: 10),
            _sectionTitle("Stone Details"),
            _buildDetailRow(
              'Stone (${stoneWeight.toStringAsFixed(2)}g)',
              '₹${stoneRate.toStringAsFixed(0)}',
              '${stoneWeight.toStringAsFixed(2)}g',
              '₹${stoneValue.toStringAsFixed(2)}',
            ),
          ],

          Divider(),
          _buildSummaryRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
          _buildSummaryRow("GST (3%)", "₹${gst.toStringAsFixed(2)}"),

          Divider(thickness: 1.5),
          _buildSummaryRow(
            "Final Price",
            "₹${grandTotal.toStringAsFixed(2)}",
            isBold: true,
            isHighlight: true,
          ),

          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.brown.shade100),
            ),
            child: Center(
              child: Text(
                'Grand Total: ₹${grandTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.brown.shade600,
      ),
    ),
  );
}

Widget _buildDetailRow(String component, String rate, String weight, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(flex: 4, child: Text(component)),
        Expanded(flex: 2, child: Text(rate, textAlign: TextAlign.right)),
        Expanded(flex: 2, child: Text(weight, textAlign: TextAlign.right)),
        Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right)),
      ],
    ),
  );
}

Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? Colors.brown : Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? Colors.brown.shade800 : Colors.black87,
          ),
        ),
      ],
    ),
  );
}


  Widget _buildPriceRow(
    String component,
    String rate,
    String weight,
    String value, {
    bool isTotal = false,
    bool isGrandTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              component,
              style: TextStyle(
                fontWeight:
                    isTotal || isGrandTotal
                        ? FontWeight.bold
                        : FontWeight.normal,
                color: isGrandTotal ? Colors.brown : Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              rate,
              style: TextStyle(
                fontWeight:
                    isTotal || isGrandTotal
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              weight,
              style: TextStyle(
                fontWeight:
                    isTotal || isGrandTotal
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontWeight:
                    isTotal || isGrandTotal
                        ? FontWeight.bold
                        : FontWeight.normal,
                color: isGrandTotal ? Colors.brown : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expansionTile(String title, String content) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            content,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (productDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Details'),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.brown),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 80, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Oops! No details found for this product.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10),
              Text(
                'Please try another product or go back.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go Back', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    List<dynamic> metalDetails = [];
    List<dynamic> stoneDetails = [];
    try {
      if (productDetails!['metal_details'] != null &&
          productDetails!['metal_details'].toString().isNotEmpty &&
          productDetails!['metal_details'].toString() != "[]") {
        metalDetails = json.decode(productDetails!['metal_details']);
      }
      if (productDetails!['stone_details'] != null &&
          productDetails!['stone_details'].toString().isNotEmpty &&
          productDetails!['stone_details'].toString() != "[]") {
        stoneDetails = json.decode(productDetails!['stone_details']);
      }
    } catch (e) {}

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          productDetails!['pname'] ?? '',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        actions: [
          isWishlistLoading
              ? Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.brown,
                  ),
                ),
              )
              : IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : Colors.brown,
                ),
                onPressed: toggleWishlist,
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              Center(
                child: Image.network(
                  productDetails!['image_url'] ?? widget.imagePath,
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(blurRadius: 5, color: Colors.brown.shade100),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productDetails!['pname'] ?? '',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Type: ${productDetails!['variant_type_name'] ?? ''} - ${productDetails!['variant_option_name'] ?? ''}',
                      style: TextStyle(color: Colors.brown, fontSize: 14),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Final Price: ₹${_calculateFinalPrice().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (productDetails!['discount_price'] != null &&
                        double.tryParse(
                              productDetails!['discount_price'].toString(),
                            ) !=
                            null &&
                        double.tryParse(
                              productDetails!['discount_price'].toString(),
                            )! >
                            0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'You Save: ₹${productDetails!['discount_price']}',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    SizedBox(height: 12),
                    Divider(),
                    SizedBox(height: 6),
                    if (metalDetails.isNotEmpty) ...[
                      Text(
                        'Metal Details:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      ...metalDetails.map(
                        (m) =>
                            Text('Type: ${m['type']}, Weight: ${m['weight']}'),
                      ),
                      SizedBox(height: 6),
                    ],
                    if (stoneDetails.isNotEmpty) ...[
                      Text(
                        'Stone Details:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      ...stoneDetails.map(
                        (s) =>
                            Text('Type: ${s['type']}, Weight: ${s['weight']}'),
                      ),
                      SizedBox(height: 6),
                    ],
                    Text(
                      'Making Charges (%): ${productDetails!['making_charges'] ?? '-'}',
                      style: TextStyle(color: Colors.brown),
                    ),
                    Text(
                      'Wastage (%): ${productDetails!['wastage_percent'] ?? '-'}',
                      style: TextStyle(color: Colors.brown),
                    ),
                    if (productDetails!['purity_info'] != null &&
                        productDetails!['purity_info'].toString().isNotEmpty)
                      Text(
                        'Purity Info: ${productDetails!['purity_info']}',
                        style: TextStyle(color: Colors.brown),
                      ),
                    if (productDetails!['purity'] != null)
                      Text(
                        'Purity: ${productDetails!['purity']}%',
                        style: TextStyle(color: Colors.brown, fontSize: 14),
                      ),
                    if (productDetails!['metal_weight'] != null)
                      Text(
                        'Weight: ${productDetails!['metal_weight']} gm',
                        style: TextStyle(color: Colors.brown, fontSize: 14),
                      ),
                    if (productDetails!['mprice'] != null)
                      Text(
                        'Rate per gram: ₹${productDetails!['mprice']}',
                        style: TextStyle(color: Colors.brown, fontSize: 14),
                      ),
                    if (productDetails!['making_charges'] != null)
                      Text(
                        'Making Charges (old): ${productDetails!['making_charges']}%',
                        style: TextStyle(
                          color: Colors.brown,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (productDetails!['delivery_days'] != null)
                      Text(
                        'Delivery Days: ${productDetails!['delivery_days']}',
                        style: TextStyle(color: Colors.brown, fontSize: 14),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _variantSelectors(),
              SizedBox(height: 16),
              _buildPriceBreakdown(),
              SizedBox(height: 16),
              _expansionTile(
                'Description',
                productDetails!['variant_option_description'] ??
                    'No description available',
              ),
              _expansionTile(
                'Product Specification',
                'Metal Type: ${productDetails!['metal_type_name'] ?? 'Not specified'}\nStock: ${productDetails!['stock'] ?? '0'} units available',
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isAddingToCart ? null : () => addToCart(),
                  child:
                      isAddingToCart
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Add to Cart',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.brown,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please login to proceed')),
                );
                return;
              }
              if (productDetails != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => OrderSummaryPage(
                          productDetails: productDetails!,
                          userId: userId!,
                          address: Address(
                            id: '',
                            doorNo: '',
                            streetName: '',
                            area: '',
                            city: '',
                            district: '',
                            pincode: '',
                          ),
                        ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product details not available')),
                );
              }
            },
            child: Text(
              'Proceed to Buy',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
