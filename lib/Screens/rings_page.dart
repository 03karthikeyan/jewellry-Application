import 'package:flutter/material.dart';
import 'details_page.dart'; // Import the DetailsPage

class RingsPage extends StatelessWidget {
  final List<Map<String, String>> products = List.generate(
    8,
    (index) => {
      'image': 'assets/ring_${index + 1}.jpg',
      'name': 'Graceful Overlap Gold Bangles ${index + 1}',
      'price': '₹169300',
      'oldPrice': '₹189300',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text(
          'Rings',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.brown),
            onPressed: () {
              // Handle favorite action
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined, color: Colors.brown),
            onPressed: () {
              // Handle shopping bag action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for jewellery',
                prefixIcon: Icon(Icons.search, color: Colors.brown),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Filter and Sort Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle filter action
                  },
                  icon: Icon(Icons.filter_list),
                  label: Text("Filter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.brown,
                    side: BorderSide(color: Colors.brown),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle sort action
                  },
                  icon: Icon(Icons.sort),
                  label: Text("Sort By"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.brown,
                    side: BorderSide(color: Colors.brown),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          // Product Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to DetailsPage with product details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(
                          name: product['name']!,
                          price: product['price']!,
                          imagePath: product['image']!,
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
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Product Image with Favorite Icon
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                product['image']!,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Icon(Icons.favorite_border, color: Colors.brown),
                            ),
                          ],
                        ),

                        // Product Name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            product['name']!,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 6),

                        // Product Price
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                product['price']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                product['oldPrice']!,
                                style: TextStyle(
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
              },
            ),
          ),
        ],
      ),
    );
  }
}