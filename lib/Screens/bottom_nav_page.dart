import 'package:flutter/material.dart';
import 'home_page.dart'; // Import HomePage
import 'category_page.dart'; // Import CategoryPage
import 'orders_page.dart'; // Import OrdersPage
import 'profile_page.dart'; // Import ProfilePage
import 'more_page.dart'; // Import MorePage

class BottomNavPage extends StatefulWidget {
  @override
  _BottomNavPageState createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _currentIndex = 0; // Track the selected tab index

  // Define the list of pages for each BottomNavigationBar item
  final List<Widget> _pages = [
    HomePage(), // Home Page
    CategoryPage(), // Category Page
    OrdersPage(), // Orders Page
    ProfilePage(), // Profile Page
    MorePage(), // More Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the current index when a tab is selected
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.brown, // Highlighted color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        showUnselectedLabels: true, // Show labels for unselected items
        currentIndex: _currentIndex, // Track the currently selected index
        onTap: _onItemTapped, // Handle taps on tabs
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }
}
