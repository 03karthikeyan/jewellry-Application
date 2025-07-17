// File: category_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jewellery/Bloc/category_Bloc.dart';
import 'package:jewellery/Event/category_Event.dart';
import 'dart:io';
// import 'package:jewellery/Screens/earrings_page.dart';
// import 'package:jewellery/Screens/necklaces_page.dart';
import 'package:jewellery/Screens/productList_Page.dart';
import 'package:jewellery/Screens/shimmer_Loader.dart';
// import 'package:jewellery/Screens/rings_page.dart';
import 'package:jewellery/State/category_State.dart';

class CategoryPage extends StatefulWidget {
  // final String categoryId;
  // final String title;

  // const CategoryPage({});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // final List<Map<String, String>> categories = [
  //   {"name": "Earrings", "imagePath": "assets/earing.jpg"},
  //   {"name": "Rings", "imagePath": "assets/ring.avif"},
  //   {"name": "Necklaces", "imagePath": "assets/necklace.avif"},
  //   {"name": "Bangles", "imagePath": "assets/bangle.png"},
  //   {"name": "Bracelets", "imagePath": "assets/bracelet.jpg"},
  //   {"name": "Pendants", "imagePath": "assets/pendant.avif"},
  //   {"name": "Chains", "imagePath": "assets/chain.png"},
  //   {"name": "Customize", "imagePath": ""},
  // ];

  @override
  void initState() {
    super.initState();

    // 👇 Trigger API call
    context.read<CategoryBloc>().add(FetchCategoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Categories',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.brown),
        //   onPressed: () => Navigator.pop(context),
        // ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.brown),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => BuyByGramsSheet(pricePerGram: 5000),
                  );
                },
                child: Card(
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(Icons.scale, color: Colors.brown, size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Buy Jewellery by Gram',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.brown,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return Center(child: ShimmerLoading());
                  } else if (state is CategoryLoaded) {
                    final categories = state.categories;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: categories.length + 1, // +1 for Customize card
                      itemBuilder: (context, index) {
                        if (index == categories.length) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomUploadForm(),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  size: 40,
                                  color: Colors.brown,
                                ),
                              ),
                            ),
                          );
                        }

                        final category = categories[index];
                        return CategoryCard(
                          name: category.title,
                          imagePath: category.image,
                          categoryId: category.id,
                        );
                      },
                    );
                  } else if (state is CategoryError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final String categoryId;

  const CategoryCard({
    required this.name,
    required this.imagePath,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ProductListPage(categoryId: categoryId, title: name),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomUploadForm extends StatefulWidget {
  @override
  _CustomUploadFormState createState() => _CustomUploadFormState();
}

class _CustomUploadFormState extends State<CustomUploadForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customize Request"),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child:
                    _selectedImage == null
                        ? Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.brown,
                          ),
                        )
                        : Image.file(
                          _selectedImage!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Your Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Contact Number'),
                validator:
                    (value) => value!.isEmpty ? 'Enter contact number' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Submit logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Request submitted successfully!'),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// You can place this at the bottom of category_page.dart or in a shared file.
class BuyByGramsSheet extends StatefulWidget {
  final double pricePerGram;
  BuyByGramsSheet({required this.pricePerGram});

  @override
  _BuyByGramsSheetState createState() => _BuyByGramsSheetState();
}

class _BuyByGramsSheetState extends State<BuyByGramsSheet> {
  double grams = 1;
  String selectedModel = 'Ring';
  final List<String> models = [
    'Ring',
    'Chain',
    'Necklace',
    'Bangle',
    'Bracelet',
    'Pendant',
  ];

  @override
  Widget build(BuildContext context) {
    double total = grams * widget.pricePerGram;
    return SingleChildScrollView(
      child: Container(
        // Set a higher minHeight for the bottom sheet
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height * 0.5, // 50% of screen height
        ),
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter Jewellery Model:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedModel,
              items:
                  models.map((model) {
                    return DropdownMenuItem(value: model, child: Text(model));
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedModel = val!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Enter grams:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
            Text(
              'Total Price: ₹${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
              onPressed: () {
                // Handle purchase logic here
                Navigator.pop(context);
              },
              child: Text(
                'Proceed to Buy',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
