import 'package:flutter/material.dart';

class CategoryDetailPage extends StatelessWidget {
  final String name;
  final String imagePath;

  const CategoryDetailPage({
    required this.name,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          name,
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
      body: Column(
        children: [
          // Category Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Category Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 8),
          // Placeholder for Category Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Explore a wide range of $name and find the perfect piece to complement your look.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          // Placeholder for Category Products
          Expanded(
            child: Center(
              child: Text(
                'Products will be displayed here.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}