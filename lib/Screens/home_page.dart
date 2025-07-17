import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery/Bloc/banner_Bloc.dart';
import 'package:jewellery/Bloc/category_Bloc.dart';
import 'package:jewellery/Event/banner_Event.dart';
import 'package:jewellery/Event/category_Event.dart';
import 'package:jewellery/Model/banner_Model.dart';
import 'package:jewellery/Screens/details_page.dart';
import 'package:jewellery/Screens/diamond_jewellery_page.dart';
import 'package:jewellery/Screens/earrings_page.dart';
import 'package:jewellery/Screens/gold_jewellery_page.dart';
import 'package:jewellery/Screens/necklaces_page.dart';
import 'package:jewellery/Screens/productList_Page.dart';
import 'package:jewellery/Screens/rings_page.dart';
import 'package:jewellery/Screens/shimmer_Loader.dart';
import 'package:jewellery/Screens/silver_jewellery_page.dart';
import 'package:jewellery/State/banner_State.dart';
import 'package:jewellery/State/category_State.dart';
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

  // final List<String> _bannerImages = [
  //   'assets/banner1.webp',
  //   'assets/banner2.webp',
  //   'assets/banner3.webp',
  // ];

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _videoController = VideoPlayerController.asset('assets/jewel-video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(0); // Mute the video
        _videoController.play();
        // fetchBannerImages();
        context.read<CategoryBloc>().add(FetchCategoryEvent());
        context.read<BannerBloc>().add(FetchBannerEvent());
      });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < _bannerImages.length - 1) {
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

  //banner API integration

  // Future<void> fetchBannerImages() async {
  //   final response = await http.get(
  //     Uri.parse('http://pheonixconstructions.com/mobile/bannerList.php'),
  //   );

  //   if (response.statusCode == 200) {
  //     final jsonData = jsonDecode(response.body);
  //     final List<dynamic> storeList = jsonData['storeList'];
  //     print('Working banners');

  //     setState(() {
  //       _bannerImages =
  //           storeList
  //               .map(
  //                 (item) => 'http://pheonixconstructions.com/' + item['image'],
  //               )
  //               .toList()
  //               .cast<String>();
  //     });
  //   } else {
  //     print('Failed to load banners');
  //   }
  // }

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
                      return Center(child: ShimmerLoading());
                    } else if (state is BannerLoaded) {
                      final List<BannerModel> banners = state.banners;

                      return Stack(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: banners.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return BannerCard(
                                  imagePath:
                                      banners[index]
                                          .image, // ✅ Use banners list, not _bannerImages
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                banners.length,
                                (index) => AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentPage == index ? 12 : 8,
                                  height: _currentPage == index ? 12 : 8,
                                  decoration: BoxDecoration(
                                    color:
                                        _currentPage == index
                                            ? Colors.brown
                                            : Colors.brown.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (state is BannerError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            state.message,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    // ✅ Return fallback UI for BannerInitial or unknown states
                    return SizedBox(height: 200); // or a placeholder banner
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
                        return Center(child: ShimmerLoadingFilter());
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Choose Your Style',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ChoiceItem(
                        title: 'Diamond',
                        imagePath: 'assets/diamond.png',
                      ),
                      ChoiceItem(title: 'Gold', imagePath: 'assets/gold.png'),
                      ChoiceItem(
                        title: 'Silver',
                        imagePath: 'assets/silver.png',
                      ),
                    ],
                  ),
                ),

                // Continue with the rest of the existing sections...
                SizedBox(height: 16),
                // Featured Products Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Featured Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        name: 'Graceful Overlap Gold Bangles ${index + 1}',
                        price: '₹169300',
                        originalPrice: '₹169300',
                        imagePath: 'assets/ring_${index + 1}.jpg',
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),

                // Add this below the "Featured Products" section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Exclusive Offers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DetailsPage(
                                      name: 'Flat 20% Off',
                                      price: 'On all diamond jewellery',
                                      imagePath: 'assets/diamond1.png',
                                    ),
                              ),
                            );
                          },
                          child: OfferCard(
                            title: 'Flat 20% Off',
                            description: 'On all diamond jewellery',
                            imagePath: 'assets/diamond1.png',
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DetailsPage(
                                      name: 'Buy 1 Get 1',
                                      price: 'On selected gold rings',
                                      imagePath: 'assets/gold1.png',
                                    ),
                              ),
                            );
                          },
                          child: OfferCard(
                            title: 'Buy 1 Get 1',
                            description: 'On selected gold rings',
                            imagePath: 'assets/gold1.png',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sparkle Every Day Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Sparkle Every Day',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Image.asset(
                    'assets/sparkle_banner.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16),
                // Surprise for Her Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Surprise For Her',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Image.asset(
                    'assets/surprise_for_her.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16),

                // Unleash Your Ride Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Unleash Your Ride',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 220, // Increase this value as needed
                    width: double.infinity,
                    child:
                        _videoController.value.isInitialized
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: VideoPlayer(_videoController),
                            )
                            : Container(
                              color: Colors.black12,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                  ),
                ),
                SizedBox(height: 16),

                // Shop by Gender Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Shop by Gender',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GenderCategory(
                        title: 'Men',
                        imagePath: 'assets/men.webp',
                      ),
                      GenderCategory(
                        title: 'Women',
                        imagePath: 'assets/women.jpg',
                      ),
                      GenderCategory(
                        title: 'Children',
                        imagePath: 'assets/children.jpg',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Box Overlay
          if (_isSearchActive)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    hintText: 'Search for jewellery',
                    prefixIcon: Icon(Icons.search, color: Colors.brown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    // Handle search logic
                    setState(() {
                      _isSearchActive =
                          false; // Close search box after submission
                    });
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          // Open chat screen
        },
      ),
      drawer: AppDrawer(), // <-- Add this line
    );
  }
}

class BannerCard extends StatelessWidget {
  final String imagePath;

  BannerCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final String categoryId;

  CategoryItem({
    required this.title,
    required this.imagePath,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // if (title == 'Rings') {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => RingsPage()),
        //   );
        // } else if (title == 'Earrings') {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => EarringsPage()),
        //   );
        // } else if (title == 'Necklaces') {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => NecklacesPage()),
        //   );
        // }

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
          CircleAvatar(radius: 40, backgroundImage: AssetImage(imagePath)),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.brown)),
        ],
      ),
    );
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
  final String price;
  final String originalPrice;
  final String imagePath;

  ProductCard({
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to DetailsPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    DetailsPage(name: name, price: price, imagePath: imagePath),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  Text(
                    originalPrice,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
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
        if (title == 'Diamond') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiamondJewelleryPage()),
          );
        } else if (title == 'Gold') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GoldJewelleryPage()),
          );
        } else if (title == 'Silver') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SilverJewelleryPage()),
          );
        }
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

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.brown.shade100),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(
                      'assets/profile_picture.jpg',
                    ), // Use your logo or user image
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.brown),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.category, color: Colors.brown),
              title: Text('Categories'),
              onTap: () {
                // Navigate to categories or scroll to categories section
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.brown),
              title: Text('Wishlist'),
              onTap: () {
                // Navigate to wishlist
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.brown),
              title: Text('My Orders'),
              onTap: () {
                // Navigate to orders
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.brown),
              title: Text('Profile'),
              onTap: () {
                // Navigate to profile
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info, color: Colors.brown),
              title: Text('About Us'),
              onTap: () {
                // Navigate to about
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.brown),
              title: Text('Logout'),
              onTap: () {
                // Handle logout
                Navigator.pop(context);
              },
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
