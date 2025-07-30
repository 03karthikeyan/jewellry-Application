// //Details screen Kavin

// // File: details_page.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:jewellery/Model/address_Model.dart';
// import 'package:jewellery/Screens/orderSummary_Page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DetailsPage extends StatefulWidget {
//   String productId; // Make this non-final so we can change it for fallback
//   final String imagePath;

//   DetailsPage({required this.productId, required this.imagePath});

//   @override
//   _DetailsPageState createState() => _DetailsPageState();
// }

// class _DetailsPageState extends State<DetailsPage> {
//   Map<String, dynamic>? productDetails;
//   bool isLoading = true;
//   List<Map<String, dynamic>> variants = [];
//   bool isInWishlist = false;
//   String? userId;
//   bool isWishlistLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     loadUserIdAndThenInit();
//     fetchProductDetails();
//   }

//   Future<void> loadUserIdAndThenInit() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedUserId = prefs.getString('user_id');
//     print('Loaded userId from SharedPreferences: $savedUserId');

//     setState(() {
//       userId = savedUserId; // Store in your class-level userId
//     });

//     if (userId != null && userId!.isNotEmpty) {
//       checkWishlistStatus(); // now safe to call with valid userId
//       fetchProductDetails(); // if needed
//     } else {
//       print(
//         "Error: userId is null even after splash. Check Splash/Login storage.",
//       );
//     }
//   }

//   Future<void> checkWishlistStatus() async {
//     if (userId == null) {
//       print('Cannot check wishlist: userId is null');
//       return;
//     }

//     setState(() {
//       isWishlistLoading = true;
//     });

//     try {
//       // Make sure product ID is clean
//       String cleanProductId = widget.productId.replaceAll('"', '');

//       // Try the wishlist check API first
//       final url =
//           'https://pheonixconstructions.com/mobile/checkWishlist.php?user_id=$userId&product_id=$cleanProductId';
//       print('Checking wishlist status: $url');

//       final response = await http.get(Uri.parse(url));
//       print('Check wishlist status code: ${response.statusCode}');
//       print('Check wishlist response: ${response.body}');

//       if (response.statusCode == 200) {
//         try {
//           final data = json.decode(response.body);

//           // More flexible check for success
//           bool isInList = false;
//           if (data.containsKey('result') && data['result'] == 'Success') {
//             isInList = true;
//           } else if (data.containsKey('exists') && data['exists'] == true) {
//             isInList = true;
//           } else if (data.containsKey('status') && data['status'] == 'found') {
//             isInList = true;
//           }

//           setState(() {
//             isInWishlist = isInList;
//           });
//           print('Product is in wishlist: $isInWishlist');
//         } catch (e) {
//           print('Error parsing wishlist check response: $e');
//           // Fallback to wishlist list API if check API fails
//           await checkWishlistUsingListAPI();
//         }
//       } else {
//         // Fallback to wishlist list API if check API returns error
//         await checkWishlistUsingListAPI();
//       }
//     } catch (e) {
//       print('Error checking wishlist status: $e');
//       // Try fallback method
//       await checkWishlistUsingListAPI();
//     } finally {
//       setState(() {
//         isWishlistLoading = false;
//       });
//     }
//   }

//   Future<void> checkWishlistUsingListAPI() async {
//     try {
//       print('Trying fallback wishlist check using list API');
//       final url =
//           'https://pheonixconstructions.com/mobile/wishlistList.php?user_id=$userId';
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('Wishlist list response: ${response.body}');

//         if (data.containsKey('wishlist') && data['wishlist'] is List) {
//           List<dynamic> wishlist = data['wishlist'];
//           String cleanProductId = widget.productId.replaceAll('"', '');

//           // Check if product exists in wishlist
//           bool found = wishlist.any(
//             (item) =>
//                 (item is Map &&
//                     item.containsKey('product_id') &&
//                     item['product_id'].toString() == cleanProductId),
//           );

//           setState(() {
//             isInWishlist = found;
//           });
//           print('Product found in wishlist list: $found');
//         }
//       }
//     } catch (e) {
//       print('Error in fallback wishlist check: $e');
//     }
//   }

//   Future<void> toggleWishlist() async {
//     if (userId == null || userId!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("User not logged in. Please login first.")),
//       );
//       print("Cannot toggle wishlist. userId is null.");
//       return;
//     }

//     final productId = widget.productId;

//     setState(() => isWishlistLoading = true);

//     final url =
//         isInWishlist
//             ? 'https://pheonixconstructions.com/mobile/wishlistRemove.php?user_id=$userId&product_id=$productId'
//             : 'https://pheonixconstructions.com/mobile/wishlistAdd.php?user_id=$userId&product_id=$productId';

//     print('Calling wishlist API: $url');

//     try {
//       final response = await http.get(Uri.parse(url));
//       final data = json.decode(response.body);

//       if (data['result'] == 'success') {
//         setState(() {
//           isInWishlist = !isInWishlist;
//         });
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Success: ${data['text']}")));
//       }
//     } catch (e) {
//       print('Error calling wishlist API: $e');
//     }

//     setState(() => isWishlistLoading = false);
//   }

//   Future<void> fetchProductDetails() async {
//     try {
//       String cleanProductId = widget.productId.replaceAll('"', '');
//       // Update the productId with clean version
//       widget.productId = cleanProductId;

//       final url =
//           'https://pheonixconstructions.com/mobile/productDetails.php?product_id=$cleanProductId';
//       print('Fetching product details from: $url');

//       final response = await http.get(Uri.parse(url));
//       print('Response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('API response result: ${data['result']}');

//         if (data['result'] == 'Success' && data['Product_Details'] != null) {
//           setState(() {
//             variants = List<Map<String, dynamic>>.from(data['Product_Details']);
//             productDetails = variants.isNotEmpty ? variants[0] : null;
//             isLoading = false;
//           });
//         } else {
//           // No fallback, just show user-friendly message
//           setState(() {
//             productDetails = null;
//             isLoading = false;
//           });
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching product details: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     if (productDetails == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Product Details'),
//           backgroundColor: Colors.white,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: Colors.brown),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.info_outline, size: 80, color: Colors.orange),
//               SizedBox(height: 16),
//               Text(
//                 'Oops! No details found for this product.',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 'Please try another product or go back.',
//                 style: TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('Go Back', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.brown),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           productDetails!['pname'] ?? '',
//           style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           isWishlistLoading
//               ? Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.brown,
//                   ),
//                 ),
//               )
//               : IconButton(
//                 icon: Icon(
//                   isInWishlist ? Icons.favorite : Icons.favorite_border,
//                   color: isInWishlist ? Colors.red : Colors.brown,
//                 ),
//                 onPressed: toggleWishlist,
//               ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 32), // Add space above image
//               Center(
//                 child: Image.network(
//                   widget.imagePath,
//                   height: 250,
//                   fit: BoxFit.contain,
//                   errorBuilder:
//                       (context, error, stackTrace) => Container(
//                         height: 250,
//                         width: double.infinity,
//                         color: Colors.grey[200],
//                         child: const Center(
//                           child: Icon(
//                             Icons.broken_image,
//                             size: 60,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(blurRadius: 5, color: Colors.brown.shade100),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       productDetails!['pname'] ?? '',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.brown,
//                       ),
//                     ),
//                     SizedBox(height: 6),
//                     Text(
//                       'Type: ${productDetails!['variant_type_name'] ?? ''} - ${productDetails!['variant_option_name'] ?? ''}',
//                       style: TextStyle(color: Colors.brown, fontSize: 14),
//                     ),
//                     SizedBox(height: 6),
//                     Text(
//                       'Price: ₹${productDetails!['price'] ?? '0'}',
//                       style: TextStyle(
//                         color: Colors.green[800],
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (productDetails!['discount_price'] != null &&
//                         productDetails!['discount_price'] !=
//                             productDetails!['price'])
//                       Padding(
//                         padding: const EdgeInsets.only(top: 4.0),
//                         child: Text(
//                           'Original Price: ₹${productDetails!['discount_price']}',
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 14,
//                             decoration: TextDecoration.lineThrough,
//                           ),
//                         ),
//                       ),
//                     SizedBox(height: 12),
//                     Divider(),
//                     SizedBox(height: 6),
//                     if (productDetails!['purity'] != null)
//                       Text(
//                         'Purity: ${productDetails!['purity']}%',
//                         style: TextStyle(color: Colors.brown, fontSize: 14),
//                       ),
//                     if (productDetails!['purity'] != null) SizedBox(height: 6),

//                     if (productDetails!['metal_weight'] != null)
//                       Text(
//                         'Weight: ${productDetails!['metal_weight']} gm',
//                         style: TextStyle(color: Colors.brown, fontSize: 14),
//                       ),
//                     if (productDetails!['metal_weight'] != null)
//                       SizedBox(height: 6),

//                     if (productDetails!['mprice'] != null)
//                       Text(
//                         'Rate per gram: ₹${productDetails!['mprice']}',
//                         style: TextStyle(color: Colors.brown, fontSize: 14),
//                       ),
//                     if (productDetails!['mprice'] != null) SizedBox(height: 6),

//                     if (productDetails!['making_charges'] != null)
//                       Text(
//                         'Making Charges: ${productDetails!['making_charges']}%',
//                         style: TextStyle(color: Colors.brown, fontSize: 14),
//                       ),
//                     if (productDetails!['making_charges'] != null)
//                       SizedBox(height: 6),

//                     if (productDetails!['wastage_percent'] != null)
//                       Text(
//                         'Wastage: ${productDetails!['wastage_percent']}%',
//                         style: TextStyle(color: Colors.brown, fontSize: 14),
//                       ),
//                     if (productDetails!['wastage_percent'] != null)
//                       SizedBox(height: 6),

//                     if (productDetails!['delivery_days'] != null)
//                       Text(
//                         'Delivery Days: ${productDetails!['delivery_days']}',
//                         style: TextStyle(color: Colors.brown, fontSize: 14),
//                       ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: 16),

//               // Variants Selection
//               if (variants.length > 1)
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       BoxShadow(blurRadius: 5, color: Colors.brown.shade100),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Available Variants',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.brown,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children:
//                             variants.map((variant) {
//                               bool isSelected = variant == productDetails;
//                               return GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     productDetails = variant;
//                                   });
//                                 },
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 8,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color:
//                                           isSelected
//                                               ? Colors.brown
//                                               : Colors.grey,
//                                     ),
//                                     borderRadius: BorderRadius.circular(20),
//                                     color:
//                                         isSelected
//                                             ? Colors.brown.shade50
//                                             : Colors.white,
//                                   ),
//                                   child: Text(
//                                     variant['variant_option_name'] ?? '',
//                                     style: TextStyle(
//                                       color:
//                                           isSelected
//                                               ? Colors.brown
//                                               : Colors.grey,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                       ),
//                     ],
//                   ),
//                 ),

//               SizedBox(height: 16),
//               _expansionTile(
//                 'Description',
//                 productDetails!['variant_option_description'] ??
//                     'No description available',
//               ),
//               _expansionTile(
//                 'Product Specification',
//                 'Metal Type: ${productDetails!['metal_type_name'] ?? 'Not specified'}\nStock: ${productDetails!['stock'] ?? '0'} units available',
//               ),

//               SizedBox(height: 16),

//               // Add this button before the bottomNavigationBar
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.brown,
//                     padding: EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   onPressed: () {
//                     showModalBottomSheet(
//                       context: context,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(16),
//                         ),
//                       ),
//                       builder:
//                           (context) => BuyByGramsSheet(
//                             pricePerGram:
//                                 double.tryParse(
//                                   productDetails!['mprice']?.toString() ?? '0',
//                                 ) ??
//                                 0,
//                           ),
//                     );
//                   },
//                   child: Text(
//                     'Buy By Grams',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: EdgeInsets.all(16),
//         color: Colors.brown,
//         child: SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.brown,
//               padding: EdgeInsets.symmetric(vertical: 14),
//             ),

//             onPressed: () async {
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               String? userId = prefs.getString('user_id');

//               if (userId != null && userId.isNotEmpty) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (_) => OrderSummaryPage(
//                           productDetails: productDetails ?? {},
//                           userId: userId, // Correctly pass user ID
//                           address: Address(
//                             id: '',
//                             doorNo: '',
//                             streetName: '',
//                             area: '',
//                             city: '',
//                             district: '',
//                             pincode: '',
//                           ),
//                         ),
//                   ),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text("User ID not found. Please log in again."),
//                   ),
//                 );
//               }
//             },

//             child: Text(
//               'Proceed to Buy',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _expansionTile(String title, String content) {
//     return ExpansionTile(
//       title: Text(
//         title,
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
//       ),
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Text(
//             content,
//             style: TextStyle(fontSize: 13, color: Colors.grey),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class BuyByGramsSheet extends StatefulWidget {
//   final double pricePerGram;
//   BuyByGramsSheet({required this.pricePerGram});

//   @override
//   _BuyByGramsSheetState createState() => _BuyByGramsSheetState();
// }

// class _BuyByGramsSheetState extends State<BuyByGramsSheet> {
//   double grams = 1;
//   @override
//   Widget build(BuildContext context) {
//     double total = grams * widget.pricePerGram;
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Enter grams:',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   keyboardType: TextInputType.numberWithOptions(decimal: true),
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     hintText: 'e.g. 2.5',
//                   ),
//                   onChanged: (val) {
//                     setState(() {
//                       grams = double.tryParse(val) ?? 1;
//                     });
//                   },
//                 ),
//               ),
//               SizedBox(width: 12),
//               Text('g', style: TextStyle(fontSize: 16)),
//             ],
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Total Price: ₹${total.toStringAsFixed(2)}',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.brown,
//               fontSize: 18,
//             ),
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
//             onPressed: () {
//               // Handle purchase logic here
//               Navigator.pop(context);
//             },
//             child: Text(
//               'Proceed to Buy',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//New Updated code
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
      String unitPrice = productDetails!['price']?.toString() ?? '0';
      String unitMrp =
          productDetails!['discount_price']?.toString() ?? unitPrice;
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
                      'Price: ₹${productDetails!['price'] ?? '0'}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (productDetails!['discount_price'] != null &&
                        productDetails!['discount_price'] !=
                            productDetails!['price'])
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Original Price: ₹${productDetails!['discount_price']}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
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
