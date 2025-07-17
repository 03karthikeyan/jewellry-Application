import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  // Sample orders data
  final List<Map<String, String>> orders = [
    {
      "productName": "Classic Gold Ring",
      "productImage": "assets/gold_ring.avif",
      "price": "₹16,930",
      "status": "Delivered",
      "date": "20 Apr 2025"
    },
    {
      "productName": "Elegant Necklace",
      "productImage": "assets/necklace_1.jpg",
      "price": "₹50,000",
      "status": "In Transit",
      "date": "30 Apr 2025"
    },
    {
      "productName": "Silver Bracelet",
      "productImage": "assets/bracelet_1.jpg",
      "price": "₹8,500",
      "status": "Cancelled",
      "date": "15 Mar 2025"
    },
    {
      "productName": "Diamond Earrings",
      "productImage": "assets/diamond_earring.jpg",
      "price": "₹35,000",
      "status": "Delivered",
      "date": "10 Feb 2025"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Orders',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: orders.isEmpty
          ? Center(
              child: Text(
                'No orders found.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.brown,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(
                  productName: order["productName"]!,
                  productImage: order["productImage"]!,
                  price: order["price"]!,
                  status: order["status"]!,
                  date: order["date"]!,
                );
              },
            ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String productName;
  final String productImage;
  final String price;
  final String status;
  final String date;

  const OrderCard({
    required this.productName,
    required this.productImage,
    required this.price,
    required this.status,
    required this.date,
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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
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
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12),
            // Order Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Order Status
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        style: TextStyle(
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
    );
  }
}