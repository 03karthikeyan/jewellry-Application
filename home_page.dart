import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sri_chandra_jewel/Bloc/banner_Bloc.dart';
import 'package:sri_chandra_jewel/Bloc/category_Bloc.dart';
import 'package:sri_chandra_jewel/Event/banner_Event.dart';
import 'package:sri_chandra_jewel/Event/category_Event.dart';
import 'package:sri_chandra_jewel/Model/banner_Model.dart';
import 'package:sri_chandra_jewel/Model/recently_AddedProducts_Model.dart';
import 'package:sri_chandra_jewel/Screens/category_page.dart';
import 'package:sri_chandra_jewel/Screens/details_page.dart';
import 'package:sri_chandra_jewel/Screens/diamond_jewellery_page.dart';
import 'package:sri_chandra_jewel/Screens/earrings_page.dart';
import 'package:sri_chandra_jewel/Screens/gold_jewellery_page.dart';
import 'package:sri_chandra_jewel/Screens/login_screen.dart';
import 'package:sri_chandra_jewel/Screens/necklaces_page.dart';
import 'package:sri_chandra_jewel/Screens/orders_page.dart';
import 'package:sri_chandra_jewel/Screens/productList_Page.dart';
import 'package:sri_chandra_jewel/Screens/profile_page.dart';
import 'package:sri_chandra_jewel/Screens/rings_page.dart';
import 'package:sri_chandra_jewel/Screens/shimmer_Loader.dart';
import 'package:sri_chandra_jewel/State/banner_State.dart';
import 'package:sri_chandra_jewel/State/category_State.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:marquee/marquee.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  bool _isSearchActive = false; // Track if the search box is active
  List<String> _bannerImages = [];
  List<RecentlyAddedProduct>? _recentProducts;
  bool _isLoadingProducts = true;

  List<RecentlyAddedProduct> _filteredProducts = [];
  TextEditingController _searchController = TextEditingController();

  // final List<String> _bannerImages = [
  //   'assets/banner1.webp',
  //   'assets/banner2.webp',
  //   'assets/banner3.webp',
  // ];

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    context.read<CategoryBloc>().add(FetchCategoryEvent());
    context.read<BannerBloc>().add(FetchBannerEvent());
    _startBannerAutoSlide(_bannerImages.length);

    _loadRecentlyAddedProducts();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startBannerAutoSlide(int bannerCount) {
    _autoSlideTimer?.cancel(); // cancel previous timer if exists

    if (bannerCount <= 1) return; // no need to slide if only 1 banner

    _autoSlideTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!_pageController.hasClients) return;

      if (_currentPage < bannerCount - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  //Recently Added Products API integration

  Future<void> _loadRecentlyAddedProducts() async {
    try {
      final products = await fetchRecentlyAddedProducts();
      setState(() {
        _recentProducts = products;
        _filteredProducts = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _recentProducts = [];
        _filteredProducts = [];
        _isLoadingProducts = false;
      });
    }
  }

  void _filterProducts(String query) {
    if (_recentProducts == null) return;

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _recentProducts!;
      } else {
        _filteredProducts =
            _recentProducts!
                .where(
                  (product) => product.pname!.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  Future<List<RecentlyAddedProduct>> fetchRecentlyAddedProducts() async {
    final response = await http.get(
      Uri.parse(
        'https://pheonixconstructions.com/mobile/recentlyAddedProduct.php',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['result'] == 'Success') {
        List list = jsonData['storeList'];
        return list.map((item) => RecentlyAddedProduct.fromJson(item)).toList();
      }
    }
    throw Exception('Network issue to load products');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Sri Chandra Jewel Crafts',
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pacifico', // Use Pacifico font
            ),
          ),
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: Colors.brown),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchActive ? Icons.close : Icons.search,
              color: Colors.brown,
            ),
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive; // Toggle search box
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add the OfferMarquee here
                OfferMarquee(),

                // Banner Section (Stack with PageView)
                BlocBuilder<BannerBloc, BannerState>(
                  builder: (context, state) {
                    if (state is BannerLoading) {
                      return SizedBox(
                        height: 100,
                        child: ShimmerLoadingBanner(), // shimmer for banner
                      );
                    } else if (state is BannerLoaded) {
                      final banners = state.banners;

                      _startBannerAutoSlide(banners.length);

                      return Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: banners.length,
                              itemBuilder: (context, index) {
                                return BannerCard(
                                  imagePath: banners[index].image,
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ), // small gap between banner and dots
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: banners.length,
                            effect: WormEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              spacing: 6,
                              dotColor: Colors.grey.shade300,
                              activeDotColor: Colors.blueAccent,
                            ),
                          ),
                        ],
                      );
                    } else if (state is BannerError) {
                      return SizedBox(
                        height: 200,
                        child: Center(child: Text("Failed to load banners")),
                      );
                    }

                    return SizedBox(height: 200); // fallback
                  },
                ),

                SizedBox(height: 16),

                // Categories Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Discover Our Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return SizedBox(
                          height: 100, // ✅ reserve space
                          child: ShimmerLoadingCategory(),
                        );
                      } else if (state is CategoryLoaded) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 16, // horizontal space between items
                            runSpacing: 16, // vertical space between rows
                            children:
                                state.categories
                                    .map(
                                      (category) => CategoryItem(
                                        title: category.title,
                                        imagePath: category.image,
                                        categoryId: category.id,
                                      ),
                                    )
                                    .toList(),
                          ),
                        );
                      } else if (state is CategoryError) {
                        return Center(child: Text('Error: ${state.message}'));
                      }
                      return Container();
                    },
                  ),
                ),

                SizedBox(height: 16),

                // New "Choose Your Style" Section
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: Text(
                //     'Choose Your Style',
                //     style: TextStyle(
                //       fontSize: 18,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.brown,
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: SingleChildScrollView(
                //     scrollDirection: Axis.horizontal,
                //     child: Row(
                //       children: [
                //         ChoiceItem(
                //           title: 'Diamond',
                //           imagePath: 'assets/diamond.jpg',
                //         ),
                //         SizedBox(width: 12),
                //         ChoiceItem(title: 'Gold', imagePath: 'assets/gold.jpg'),
                //         SizedBox(width: 12),
                //         ChoiceItem(
                //           title: 'Silver',
                //           imagePath: 'assets/silver.jpg',
                //         ),
                //         SizedBox(width: 12),
                //         ChoiceItem(
                //           title: 'Platinum',
                //           imagePath: 'assets/platinum.jpg',
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // Continue with the rest of the existing sections...
                // SizedBox(height: 16),
                // Recently Added Products Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'New Arrived Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                _isLoadingProducts
                    ? Center(child: ShimmerLoadingFilter())
                    : (_filteredProducts.isEmpty)
                    ? Center(child: Text('No products found.'))
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            _filteredProducts
                                .length, // ✅ Use filtered list here
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final product =
                              _filteredProducts[index]; // ✅ Use filtered list here
                          return ProductCard(
                            name: product.pname ?? 'No Name',
                            imageUrl: product.pimage ?? '',
                            productId: product.id ?? '',
                          );
                        },
                      ),
                    ),

                SizedBox(height: 16),
              ],
            ),
          ),

          // Search Box Overlay
          if (_isSearchActive)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _filterProducts(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for products...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterProducts('');
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      drawer: AppDrawer(), // <-- Add this line
    );
  }
}

class BannerCard extends StatelessWidget {
  final String imagePath;

  const BannerCard({required this.imagePath, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox.expand(
        child: Image.network(
          imagePath,
          fit: BoxFit.fill,
          errorBuilder:
              (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, color: Colors.grey, size: 60),
              ),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final String categoryId;

  const CategoryItem({
    required this.title,
    required this.imagePath,
    required this.categoryId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ProductListPage(categoryId: categoryId, title: title),
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(imagePath),
            onBackgroundImageError: (_, __) {
              // Handles broken image gracefully
            },
            child:
                imagePath.isEmpty
                    ? Icon(Icons.broken_image, size: 40, color: Colors.brown)
                    : null,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.brown,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ));
    }
}

class GenderCategory extends StatelessWidget {
  final String title;
  final String imagePath;

  GenderCategory({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 14, color: Colors.brown)),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String productId; // ✅ Add this

  const ProductCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.productId, // ✅ Require it
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DetailsPage(
                  productId: productId, // ✅ Pass dynamic productId
                  imagePath: imageUrl,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with NEW label
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product Name
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New reusable widget for the "Choose Your Style" section
class ChoiceItem extends StatelessWidget {
  final String title;
  final String imagePath;

  ChoiceItem({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // if (title == 'Diamond') {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => DiamondJewelleryPage()),
        //   );
        // } else if (title == 'Gold') {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => GoldJewelleryPage()),
        //   );
        // } else if (title == 'Silver') {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => SilverJewelleryPage()),
        //   );
        // }
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.brown)),
        ],
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  OfferCard({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.asset(
              imagePath,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedSection extends StatefulWidget {
  final Widget child;

  AnimatedSection({required this.child});

  @override
  _AnimatedSectionState createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _displayName = 'Sri Chandra Jewelers';
  String? _phone;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final first = prefs.getString('user_firstname') ?? '';
    final last = prefs.getString('user_lastname') ?? '';
    final phone = prefs.getString('user_phone');
    final name = (first + ' ' + last).trim();
    if (name.isNotEmpty) {
      setState(() => _displayName = name);
    }
    if (phone != null && phone.isNotEmpty) {
      setState(() => _phone = phone);
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored preferences
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(  // Changed from ListView to Column
          children: [
            Expanded(  // Wrap the ListView in Expanded
              child: ListView(
                padding: EdgeInsets.zero,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Container( // Replace DrawerHeader with Container for more control
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.brown.shade100, Colors.brown.shade200],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Prevents expansion
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/profile.jpg', // Changed from Sri_Chandra_Jewelryn_webvvv.png
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _displayName,
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_phone != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _phone ?? 'Elegance in Every Detail',
                            style: TextStyle(
                              color: Colors.brown.shade400,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.brown),
                    title: Text('Home'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer only
                    },
                  ),

                  ListTile(
                    leading: Icon(Icons.category, color: Colors.brown),
                    title: Text('Categories'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CategoryPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.favorite, color: Colors.brown),
                    title: Text('Wishlist'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OrdersPage()), // adjust target if needed
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_bag, color: Colors.brown),
                    title: Text('My Orders'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OrdersPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.brown),
                    title: Text('Profile'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfilePage()),
                      );
                    },
                  ),

                  Divider(),

                  // Removed About Us as requested

                  // (optional) Logout - keep commented or enable as needed
                  // ListTile(
                  //   leading: Icon(Icons.logout, color: Colors.brown),
                  //   title: Text('Logout'),
                  //   onTap: () async { ... },
                  // ),
                ],
              ),
            ),
            // Add Logout button at bottom
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text('Logout', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Paste your OfferMarquee widget here or import it if it's in another file
class OfferMarquee extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Color(0xFFFFCC04),
      child: Marquee(
        text:
            'Limited-Time Offer   •   Return extended to 60 days   •   Life-time Guarantee',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 50.0,
        velocity: 50.0,
        pauseAfterRound: Duration(seconds: 0),
        startPadding: 10.0,
        accelerationDuration: Duration(seconds: 0),
        accelerationCurve: Curves.linear,
        decelerationDuration: Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}
