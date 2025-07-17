import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery/Bloc/product_Bloc.dart';
import 'package:jewellery/Event/product_Event.dart';
import 'package:jewellery/Screens/details_page.dart';
import 'package:jewellery/Screens/shimmer_Loader.dart';
import 'package:jewellery/State/product_State.dart';

class ProductListPage extends StatefulWidget {
  final String categoryId;
  final String title;

  const ProductListPage({required this.categoryId, required this.title});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();

    // 👇 Trigger API call
    context.read<ProductBloc>().add(FetchProductEvent(widget.categoryId));
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
                color: Colors.grey[100], // Light background
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7, 
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),

                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => DetailsPage(
                                  name: product.name,
                                  price: '₹123000',
                                  imagePath: product.image,
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.favorite_border,
                                        size: 18,
                                        color: Colors.brown,
                                      ),
                                    ),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '₹123000',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '₹145000',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
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

            return Container(); // Initial or unknown state
          },
        ),
      ),
    );
  }
}
