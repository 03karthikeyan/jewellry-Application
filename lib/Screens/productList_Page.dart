import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Bloc/product_Bloc.dart';
import 'package:jewellery/Event/product_Event.dart';
import 'package:jewellery/Screens/details_page.dart';
import 'package:jewellery/Screens/shimmer_Loader.dart';
import 'package:jewellery/State/product_State.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductListPage extends StatefulWidget {
  final String categoryId;
  final String title;

  const ProductListPage({required this.categoryId, required this.title});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final Set<String> _wishlistedProductIds = {}; // Track wishlist status
  // final String userId = "1"; // Replace with logged-in user ID if available
  String? userId;
  bool _isUserIdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load user ID on widget init
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '1';
      _isUserIdLoaded = true;
    });
  }

  Future<void> toggleWishlist(String productId) async {
    if (userId == null || productId.isEmpty) {
      print('User ID or product ID missing.');
      return;
    }

    final isWishlisted = _wishlistedProductIds.contains(productId);

    final uri = Uri.parse(
      isWishlisted
          ? 'https://pheonixconstructions.com/mobile/wishlistRemove.php?user_id=$userId&product_id=$productId'
          : 'https://pheonixconstructions.com/mobile/wishlistAdd.php?user_id=$userId&product_id=$productId',
    );

    try {
      final response = await http.get(uri);
      final data = json.decode(response.body);

      if (data['result'] == 'success') {
        setState(() {
          if (isWishlisted) {
            _wishlistedProductIds.remove(productId);
          } else {
            _wishlistedProductIds.add(productId);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isWishlisted ? 'Removed from wishlist' : 'Added to wishlist',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isWishlisted ? Colors.red : Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${data['message'] ?? 'Try again'}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Wishlist error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error. Please try again')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc()..add(FetchProductEvent(widget.categoryId)),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return Center(child: ShimmerLoading());
            } else if (state is ProductLoaded) {
              final products = state.products;

              if (products.isEmpty) {
                return Center(child: Text("No products available"));
              }

              return Container(
                color: Colors.grey[100],
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isWishlisted = _wishlistedProductIds.contains(
                      product.id,
                    );

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => DetailsPage(
                                  imagePath: product.image,
                                  productId: product.id,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    product.image,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              height: 140,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(16),
                                                    ),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: () {
                                      // if (_isUserIdLoaded) {
                                      //   toggleWishlist(product.id);
                                      // } else {
                                      //   ScaffoldMessenger.of(
                                      //     context,
                                      //   ).showSnackBar(
                                      //     SnackBar(
                                      //       content: Text(
                                      //         "User not loaded yet, please wait.",
                                      //       ),
                                      //     ),
                                      //   );
                                      // }
                                    },

                                    // child: Container(
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.white,
                                    //     shape: BoxShape.circle,
                                    //     boxShadow: [
                                    //       BoxShadow(
                                    //         color: Colors.black12,
                                    //         blurRadius: 4,
                                    //       ),
                                    //     ],
                                    //   ),
                                    //   padding: const EdgeInsets.all(6),
                                    //   child: Icon(
                                    //     isWishlisted
                                    //         ? Icons.favorite
                                    //         : Icons.favorite_border,
                                    //     size: 18,
                                    //     color:
                                    //         isWishlisted
                                    //             ? Colors.red
                                    //             : Colors.brown,
                                    //   ),
                                    // ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 8,
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       Text(
                            //         '₹123000',
                            //         style: TextStyle(
                            //           fontSize: 14,
                            //           fontWeight: FontWeight.bold,
                            //           color: Colors.green[800],
                            //         ),
                            //       ),
                            //       SizedBox(width: 6),
                            //       Text(
                            //         '₹145000',
                            //         style: TextStyle(
                            //           fontSize: 12,
                            //           color: Colors.grey,
                            //           decoration: TextDecoration.lineThrough,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is ProductError) {
              return Center(child: Text("Error: ${state.message}"));
            }

            return Container(); // Default fallback
          },
        ),
      ),
    );
  }
}
