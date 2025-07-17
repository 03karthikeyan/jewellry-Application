// File: details_page.dart
import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;

  DetailsPage({
    required this.name,
    required this.price,
    required this.imagePath,
  });

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
          name,
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.brown),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.brown),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView( // Wrap the body in SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  imagePath,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),

              // Product Info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.brown.shade100)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '4 gram',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.brown, size: 18),
                        Icon(Icons.star, color: Colors.brown, size: 18),
                        Icon(Icons.star, color: Colors.brown, size: 18),
                        Icon(Icons.star, color: Colors.brown, size: 18),
                        Icon(Icons.star_border, color: Colors.brown, size: 18),
                        SizedBox(width: 8),
                        Text('WRITE A REVIEW', style: TextStyle(fontSize: 12, color: Colors.brown)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '₹ $price',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                    SizedBox(height: 4),
                    Text('Inclusive of all taxes', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Weight Selection
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.brown.shade100)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gross Weight ( in Gms )',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Weight and price of the jewellery item may vary subject to the stock available',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _weightOption('1.049', selected: true),
                        _weightOption('1.059'),
                        _weightOption('1.075'),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),
              _expansionTile('Description of the product'),
              _expansionTile('Product Specification'),

              SizedBox(height: 16),
              Text('Related Products', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
              SizedBox(height: 8),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => Container(
                    width: 130,
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.brown.shade100)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(imagePath, height: 80, fit: BoxFit.contain),
                        SizedBox(height: 8),
                        Text('Graceful Overlap Gold Bangles', style: TextStyle(fontSize: 12, color: Colors.brown)),
                        Text('₹169300', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                        Text('₹169300', style: TextStyle(decoration: TextDecoration.lineThrough, fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
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
            onPressed: () {},
            child: Text('Add To Cart', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _weightOption(String value, {bool selected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: selected ? Colors.brown : Colors.grey),
        borderRadius: BorderRadius.circular(20),
        color: selected ? Colors.brown.shade50 : Colors.white,
      ),
      child: Text(value, style: TextStyle(color: selected ? Colors.brown : Colors.grey)),
    );
  }

  Widget _expansionTile(String title) {
    return ExpansionTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque non nunc ut orci pharetra fermentum.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class BuyByGramsSheet extends StatefulWidget {
  final double pricePerGram;
  BuyByGramsSheet({required this.pricePerGram});

  @override
  _BuyByGramsSheetState createState() => _BuyByGramsSheetState();
}

class _BuyByGramsSheetState extends State<BuyByGramsSheet> {
  double grams = 1;
  @override
  Widget build(BuildContext context) {
    double total = grams * widget.pricePerGram;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Enter grams:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 2.5',
                  ),
                  onChanged: (val) {
                    setState(() {
                      grams = double.tryParse(val) ?? 1;
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              Text('g', style: TextStyle(fontSize: 16)),
            ],
          ),
          SizedBox(height: 16),
          Text('Total Price: ₹${total.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 18)),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            onPressed: () {
              // Handle purchase logic here
              Navigator.pop(context);
            },
            child: Text('Proceed to Buy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
