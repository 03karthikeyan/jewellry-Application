import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sri_chandra_jewel/Model/address_Model.dart';
import 'package:sri_chandra_jewel/Screens/orderSummary_Page.dart';
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

  String _getImageUrl(String url) {
    if (url.startsWith('http')) return url;
    if (url.isEmpty) return widget.imagePath;
    return 'https://pheonixconstructions.com/mobile/assets/images/product_image/$url';
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

        // Try to find product data in any format
        dynamic productData;

        // First check if it's a direct product object
        if (data is Map && data.containsKey('pname')) {
          productData = [data];
        }
        // Then check various array formats
        else if (data['Product_Details'] is List &&
            data['Product_Details'].isNotEmpty) {
          productData = data['Product_Details'];
        } else if (data['product_details'] is List &&
            data['product_details'].isNotEmpty) {
          productData = data['product_details'];
        } else if (data['products'] is List && data['products'].isNotEmpty) {
          productData = data['products'];
        } else if (data['data'] is List && data['data'].isNotEmpty) {
          productData = data['data'];
        }
        // Check if the entire response is an array
        else if (data is List && data.isNotEmpty) {
          productData = data;
        }
        // Last resort: look for any object with product-like fields
        else if (data is Map) {
          for (var value in data.values) {
            if (value is List && value.isNotEmpty) {
              var firstItem = value.first;
              if (firstItem is Map &&
                  (firstItem.containsKey('pname') ||
                      firstItem.containsKey('product_name'))) {
                productData = value;
                break;
              }
            } else if (value is Map &&
                (value.containsKey('pname') ||
                    value.containsKey('product_name'))) {
              productData = [value];
              break;
            }
          }
        }

        if (productData != null) {
          allVariants = List<Map<String, dynamic>>.from(productData);

          variantGroups.clear();
          for (var v in allVariants) {
            String variantType = v['variant_type_name'] ?? 'Default';
            variantGroups.putIfAbsent(variantType, () => []);
            if (!variantGroups[variantType]!.any(
              (e) => e['variant_option_name'] == v['variant_option_name'],
            )) {
              variantGroups[variantType]!.add(v);
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
    if (allVariants.isEmpty) return null;

    // Try to find exact match first
    for (var variant in allVariants) {
      bool matches = true;
      for (var type in selectedOptions.keys) {
        if (variant['variant_type_name'] == type &&
            variant['variant_option_name'] !=
                selectedOptions[type]?['variant_option_name']) {
          matches = false;
          break;
        }
      }
      if (matches) return variant;
    }

    // If no exact match, return first variant
    return allVariants.first;
  }

  double _calculateFinalPrice() {
    if (productDetails == null) return 0;

    // Calculate the same way as in price breakdown
    List<dynamic> metalDetails = [];
    List<dynamic> stoneDetails = [];

    // Parse metal and stone details
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

    // Fallback for metal details
    if (metalDetails.isEmpty && productDetails!['metal_type_name'] != null) {
      String metalType =
          '${productDetails!['purity'] ?? '22'}K ${productDetails!['metal_type_name'] ?? 'Gold'}';
      if (productDetails!['variant_option_name'] != null) {
        metalType += ' ${productDetails!['variant_option_name']}';
      }
      metalDetails = [
        {
          'type': metalType,
          'rate':
              double.tryParse(productDetails!['mprice']?.toString() ?? '0') ??
              0,
          'weight':
              double.tryParse(
                productDetails!['metal_weight']?.toString() ?? '0',
              ) ??
              0,
        },
      ];
    }

    // Fallback for stone details
    if (stoneDetails.isEmpty && productDetails!['stones'] != null) {
      var stones = productDetails!['stones'];
      if (stones is String && stones.isNotEmpty) {
        try {
          stones = json.decode(stones);
        } catch (e) {
          stones = [];
        }
      }
      Map<String, double> stoneRates = {
        "Diamond 1 GRAM(1.0CARAT=0.200 MGM)": 400000,
        "CORAL 1 GRAM(1.00CARAT=0.200 MGM)": 3000,
        "Ruby 1 Gram(1.00 CARAT=0.200MGM)": 2800,
        "EAMERALD 1 GRAM(1.00CARAT=0.200 MGM)": 2500,
      };
      if (stones is List) {
        stoneDetails =
            stones
                .map(
                  (s) => {
                    'type': s['name'] ?? 'Unknown Stone',
                    'rate': stoneRates[s['name']] ?? 1000,
                    'weight':
                        (s['weight'] is String)
                            ? double.tryParse(s['weight']) ?? 0
                            : (s['weight'] ?? 0).toDouble(),
                  },
                )
                .toList();
      }
    }

    // Calculate totals
    double totalMetalValue = metalDetails.fold<double>(
      0,
      (sum, m) => sum + ((m['rate'] ?? 0) * (m['weight'] ?? 0)),
    );
    double totalStoneValue = stoneDetails.fold<double>(
      0,
      (sum, s) => sum + ((s['rate'] ?? 0) * (s['weight'] ?? 0)),
    );
    double makingPercent =
        double.tryParse(productDetails!['making_charges']?.toString() ?? '0') ??
        0;
    double wastagePercent =
        double.tryParse(
          productDetails!['wastage_percent']?.toString() ?? '0',
        ) ??
        0;
    double makingCharges =
        (totalMetalValue + totalStoneValue) * makingPercent / 100;
    double wastageCharges =
        (totalMetalValue + totalStoneValue) * wastagePercent / 100;
    double subtotal =
        totalMetalValue + totalStoneValue + makingCharges + wastageCharges;
    double gst = subtotal * 0.03;
    double discount =
        double.tryParse(productDetails!['discount_price']?.toString() ?? '0') ??
        0;
    double grandTotal = subtotal + gst - discount;

    return grandTotal;
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

  Future<String?> addToCart() async {
    if (userId == null || isAddingToCart) return null;

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

      // Additional product details
      String metalWeight = productDetails!['metal_weight']?.toString() ?? '0';
      String stoneWeight = productDetails!['stone_weight']?.toString() ?? '0';
      String makingPercent =
          productDetails!['making_charges']?.toString() ?? '0';
      String wastagePercent =
          productDetails!['wastage_percent']?.toString() ?? '0';
      String purityInfo = Uri.encodeComponent(
        productDetails!['purity_info']?.toString() ?? '22K Gold',
      );

      // Metal details JSON
      Map<String, dynamic> metalDetails = {
        'type': productDetails!['metal_type_name'] ?? 'gold',
        'purity': '${productDetails!['purity'] ?? '22'}K',
        'weight': double.tryParse(metalWeight) ?? 0,
      };
      String metalDetailsJson = Uri.encodeComponent(json.encode(metalDetails));

      // Stone details JSON
      Map<String, dynamic> stoneDetails = {
        'type': 'diamond',
        'weight': double.tryParse(stoneWeight) ?? 0,
        'clarity': 'VS1',
      };
      String stoneDetailsJson = Uri.encodeComponent(json.encode(stoneDetails));

      // Rates
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
          final cartId = data['cart_id']?.toString();
          return cartId; // ✅ Return cartId here
        } else {
          print('API Error: ${data['message']}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Add to cart error: $e');
    }

    setState(() => isAddingToCart = false);
    return null; // ✅ In case of failure
  }

  Widget _buildPriceBreakdown() {
    if (productDetails == null) return SizedBox();

    // Parse metal_details and stone_details from API
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

    // Fallback for old API: use single metal if metal_details is empty
    if (metalDetails.isEmpty && productDetails!['metal_type_name'] != null) {
      String metalType =
          '${productDetails!['purity'] ?? '22'}K ${productDetails!['metal_type_name'] ?? 'Gold'}';
      if (productDetails!['variant_option_name'] != null) {
        metalType += ' ${productDetails!['variant_option_name']}';
      }
      metalDetails = [
        {
          'type': metalType,
          'rate':
              double.tryParse(productDetails!['mprice']?.toString() ?? '0') ??
              0,
          'weight':
              double.tryParse(
                productDetails!['metal_weight']?.toString() ?? '0',
              ) ??
              0,
        },
      ];
    }

    // Fallback for old API: use stones if stone_details is empty
    if (stoneDetails.isEmpty && productDetails!['stones'] != null) {
      var stones = productDetails!['stones'];
      if (stones is String && stones.isNotEmpty) {
        try {
          stones = json.decode(stones);
        } catch (e) {
          stones = [];
        }
      }
      Map<String, double> stoneRates = {
        "Diamond 1 GRAM(1.0CARAT=0.200 MGM)": 400000,
        "CORAL 1 GRAM(1.00CARAT=0.200 MGM)": 3000,
        "Ruby 1 Gram(1.00 CARAT=0.200MGM)": 2800,
        "EAMERALD 1 GRAM(1.00CARAT=0.200 MGM)": 2500,
      };
      if (stones is List) {
        stoneDetails =
            stones
                .map(
                  (s) => {
                    'type': s['name'] ?? 'Unknown Stone',
                    'rate': stoneRates[s['name']] ?? 1000,
                    'weight':
                        (s['weight'] is String)
                            ? double.tryParse(s['weight']) ?? 0
                            : (s['weight'] ?? 0).toDouble(),
                  },
                )
                .toList();
      }
    }

    // Build rows for DataTable
    List<DataRow> allRows = [];
    for (var m in metalDetails) {
      allRows.add(
        DataRow(
          cells: [
            DataCell(
              Text(m['type']?.toString() ?? '', style: TextStyle(fontSize: 13)),
            ),
            DataCell(
              Text(
                '₹${(m['rate'] ?? 0).toStringAsFixed(0)}',
                textAlign: TextAlign.right,
              ),
            ),
            DataCell(
              Text(
                '${(m['weight'] ?? 0).toStringAsFixed(2)}',
                textAlign: TextAlign.right,
              ),
            ),
            DataCell(
              Text(
                '₹${((m['rate'] ?? 0) * (m['weight'] ?? 0)).toStringAsFixed(2)}',
                textAlign: TextAlign.right,
              ),
            ),
            DataCell(
              Text(
                '₹${((m['rate'] ?? 0) * (m['weight'] ?? 0)).toStringAsFixed(2)}',
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }
    for (var s in stoneDetails) {
      allRows.add(
        DataRow(
          cells: [
            DataCell(
              Text(s['type']?.toString() ?? '', style: TextStyle(fontSize: 13)),
            ),
            DataCell(
              Text(
                '₹${(s['rate'] ?? 0).toStringAsFixed(0)}',
                textAlign: TextAlign.right,
              ),
            ),
            DataCell(
              Text(
                '${(s['weight'] ?? 0).toStringAsFixed(2)}',
                textAlign: TextAlign.right,
              ),
            ),
            DataCell(
              Text(
                '₹${((s['rate'] ?? 0) * (s['weight'] ?? 0)).toStringAsFixed(2)}',
                textAlign: TextAlign.right,
              ),
            ),
            DataCell(
              Text(
                '₹${((s['rate'] ?? 0) * (s['weight'] ?? 0)).toStringAsFixed(2)}',
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    // Totals & charges
    double totalMetalValue = metalDetails.fold<double>(
      0,
      (sum, m) => sum + ((m['rate'] ?? 0) * (m['weight'] ?? 0)),
    );
    double totalStoneValue = stoneDetails.fold<double>(
      0,
      (sum, s) => sum + ((s['rate'] ?? 0) * (s['weight'] ?? 0)),
    );
    double makingPercent =
        double.tryParse(productDetails!['making_charges']?.toString() ?? '0') ??
        0;
    double wastagePercent =
        double.tryParse(
          productDetails!['wastage_percent']?.toString() ?? '0',
        ) ??
        0;
    double makingCharges =
        (totalMetalValue + totalStoneValue) * makingPercent / 100;
    double wastageCharges =
        (totalMetalValue + totalStoneValue) * wastagePercent / 100;
    double subtotal =
        totalMetalValue + totalStoneValue + makingCharges + wastageCharges;
    double gst = subtotal * 0.03;
    double discount =
        double.tryParse(productDetails!['discount_price']?.toString() ?? '0') ??
        0;
    double grandTotal = subtotal + gst - discount;

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
          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
              columns: [
                DataColumn(
                  label: Text(
                    'Component',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Rate',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Weight x Qty',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Value',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Final Value',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: allRows,
            ),
          ),
          Divider(),
          _buildSummaryRow(
            "Making Charges (${makingPercent.toStringAsFixed(0)}%)",
            "₹${makingCharges.toStringAsFixed(2)}",
          ),
          _buildSummaryRow(
            "Wastage Charges (${wastagePercent.toStringAsFixed(0)}%)",
            "₹${wastageCharges.toStringAsFixed(2)}",
          ),
          Divider(),
          _buildSummaryRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
          _buildSummaryRow("GST (3%)", "₹${gst.toStringAsFixed(2)}"),
          _buildSummaryRow(
            "Total Discount",
            "-₹${discount.toStringAsFixed(2)}",
          ),
          Divider(thickness: 1.5),
          _buildSummaryRow(
            "Grand Total",
            "₹${grandTotal.toStringAsFixed(2)}",
            isBold: true,
            isHighlight: true,
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

  Widget _buildDetailInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.brown.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isHighlight = false,
  }) {
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
                  _getImageUrl(
                    productDetails!['image_url'] ?? widget.imagePath,
                  ),
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
                    SizedBox(height: 8),
                    Text(
                      'Type: ${productDetails!['variant_type_name'] ?? ''} - ${productDetails!['variant_option_name'] ?? ''}',
                      style: TextStyle(
                        color: Colors.brown.shade600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Final Price:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '₹${_calculateFinalPrice().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'You Save:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '₹${productDetails!['discount_price']}',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 16),
                    Divider(color: Colors.brown.shade200),
                    SizedBox(height: 12),

                    // Product Details Section
                    _buildDetailInfoRow(
                      'Metal Type:',
                      '${productDetails!['metal_type_name'] ?? 'Not specified'}',
                    ),
                    _buildDetailInfoRow(
                      'Purity:',
                      '${productDetails!['purity'] ?? '22'}K',
                    ),
                    _buildDetailInfoRow(
                      'Metal Weight:',
                      '${productDetails!['metal_weight'] ?? '0'} gm',
                    ),
                    _buildDetailInfoRow(
                      'Rate per gram:',
                      '₹${productDetails!['mprice'] ?? '0'}',
                    ),
                    _buildDetailInfoRow(
                      'Making Charges:',
                      '${productDetails!['making_charges'] ?? '0'}%',
                    ),
                    _buildDetailInfoRow(
                      'Wastage Charges:',
                      '${productDetails!['wastage_percent'] ?? '0'}%',
                    ),
                    if (productDetails!['delivery_days'] != null)
                      _buildDetailInfoRow(
                        'Delivery Days:',
                        '${productDetails!['delivery_days']} days',
                      ),

                    // Stone Details if available
                    if (productDetails!['stones'] != null &&
                        (productDetails!['stones'] as List).isNotEmpty) ...[
                      SizedBox(height: 12),
                      Divider(color: Colors.brown.shade200),
                      SizedBox(height: 8),
                      Text(
                        'Stone Details:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...(productDetails!['stones'] as List).map((stone) {
                        double weight = 0;
                        if (stone['weight'] is String) {
                          weight = double.tryParse(stone['weight']) ?? 0;
                        } else if (stone['weight'] is num) {
                          weight = (stone['weight'] as num).toDouble();
                        }
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '• ${stone['name'] ?? 'Stone'}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.brown.shade700,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${weight.toStringAsFixed(2)}g',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
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
            onPressed:
                isAddingToCart
                    ? null
                    : () async {
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please login to proceed')),
                        );
                        return;
                      }

                      if (productDetails != null) {
                        final String? cartId = await addToCart();

                        if (cartId != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => OrderSummaryPage(
                                    productDetails: productDetails!,
                                    userId: userId!,
                                    address: Address(
                                      id: '',
                                      firstName: '',
                                      lastName: '',
                                      contactNumber: '',
                                      doorNo: '',
                                      streetName: '',
                                      area: '',
                                      city: '',
                                      district: '',
                                      pincode: '',
                                    ),
                                    cartId:
                                        cartId, //  Now passing valid cart ID
                                  ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add to cart')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Product details not available'),
                          ),
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

  double _getSubtotal(
    List<dynamic> metalDetails,
    List<dynamic> stoneDetails,
    Map<String, dynamic> productDetails,
  ) {
    double totalMetalValue = metalDetails.fold<double>(0, (sum, m) {
      final rate =
          (m['rate'] is String)
              ? double.tryParse(m['rate']) ?? 0
              : (m['rate'] ?? 0).toDouble();
      final weight =
          (m['weight'] is String)
              ? double.tryParse(m['weight']) ?? 0
              : (m['weight'] ?? 0).toDouble();
      return sum + (rate * weight);
    });
    double totalStoneValue = stoneDetails.fold<double>(0, (sum, s) {
      final rate =
          (s['rate'] is String)
              ? double.tryParse(s['rate']) ?? 0
              : (s['rate'] ?? 0).toDouble();
      final weight =
          (s['weight'] is String)
              ? double.tryParse(s['weight']) ?? 0
              : (s['weight'] ?? 0).toDouble();
      return sum + (rate * weight);
    });
    double makingPercent =
        double.tryParse(productDetails['making_charges']?.toString() ?? '0') ??
        0;
    double wastagePercent =
        double.tryParse(productDetails['wastage_percent']?.toString() ?? '0') ??
        0;
    double makingCharges =
        (totalMetalValue + totalStoneValue) * makingPercent / 100;
    double wastageCharges =
        (totalMetalValue + totalStoneValue) * wastagePercent / 100;
    return totalMetalValue + totalStoneValue + makingCharges + wastageCharges;
  }
}
