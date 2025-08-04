//kavins code
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Model/address_Model.dart';

class OrderSummaryPage extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  final String userId;
  final Address address;

  const OrderSummaryPage({
    Key? key,
    required this.productDetails,
    required this.userId,
    required this.address,
  }) : super(key: key);

  @override
  _OrderSummaryPageState createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  int currentStep = 0;
  List<Address> addresses = [];
  Address? selectedAddress;
  bool isLoading = true;
  String selectedPayment = 'UPI';
  bool isPlacingOrder = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://pheonixconstructions.com/mobile/getAddress.php?user_id=${widget.userId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final addressList =
              (data['data'] as List).map((e) => Address.fromJson(e)).toList();

          setState(() {
            addresses = addressList;
            selectedAddress = addresses.isNotEmpty ? addresses.first : null;
            isLoading = false;
          });
        } else {
          setState(() {
            addresses = [];
            selectedAddress = null;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          addresses = [];
          selectedAddress = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        addresses = [];
        selectedAddress = null;
        isLoading = false;
      });
    }
  }

  Future<void> _addAddress(Map<String, String> addressData) async {
    try {
      final url =
          'https://pheonixconstructions.com/mobile/addAddress.php'
          '?user_id=${widget.userId}'
          '&door_no=${Uri.encodeComponent(addressData['doorNo'] ?? '')}'
          '&street_name=${Uri.encodeComponent(addressData['streetName'] ?? '')}'
          '&area=${Uri.encodeComponent(addressData['area'] ?? '')}'
          '&city=${Uri.encodeComponent(addressData['city'] ?? '')}'
          '&district=${Uri.encodeComponent(addressData['district'] ?? '')}'
          '&pincode=${Uri.encodeComponent(addressData['pincode'] ?? '')}'
          '&first_name=${Uri.encodeComponent(addressData['first_name'] ?? '')}'
          '&last_name=${Uri.encodeComponent(addressData['last_name'] ?? '')}'
          '&contact_number=${Uri.encodeComponent(addressData['contact_number'] ?? '')}';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Address added successfully')));
        _fetchAddresses();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add address')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding address')));
    }
  }

  Future<void> _editAddress(Address address) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder:
          (context) => AddressFormDialog(
            initialData: {
              'doorNo': address.doorNo,
              'streetName': address.streetName,
              'area': address.area,
              'city': address.city,
              'district': address.district,
              'pincode': address.pincode,
            },
          ),
    );
    if (result != null) {
      final url =
          'https://pheonixconstructions.com/mobile/editAddress.php'
          '?id=${address.id}'
          '&door_no=${Uri.encodeComponent(result['doorNo'] ?? '')}'
          '&street_name=${Uri.encodeComponent(result['streetName'] ?? '')}'
          '&area=${Uri.encodeComponent(result['area'] ?? '')}'
          '&city=${Uri.encodeComponent(result['city'] ?? '')}'
          '&district=${Uri.encodeComponent(result['district'] ?? '')}'
          '&pincode=${Uri.encodeComponent(result['pincode'] ?? '')}';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Address updated')));
        _fetchAddresses();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update address')));
      }
    }
  }

  Future<void> _confirmDeleteAddress(Address address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Address'),
            content: Text('Are you sure you want to delete this address?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await _deleteAddress(address.id);
    }
  }

  Future<void> _deleteAddress(String id) async {
    final url =
        'https://pheonixconstructions.com/mobile/deleteAddress.php?id=$id';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Address deleted')));
      _fetchAddresses();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete address')));
    }
  }

  Future<void> _showAddressForm() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AddressFormDialog(),
    );
    if (result != null) {
      await _addAddress(result);
    }
  }

  //Place Order

  Future<void> _placeOrder() async {
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => isPlacingOrder = true);

    final String userId = widget.userId;
    final String grandTotal = widget.productDetails['price']?.toString() ?? '0';
    final String addressId = selectedAddress?.id?.toString() ?? '';
    final String cartId = '379'; // Update dynamically if needed

    final url =
        'https://pheonixconstructions.com/mobile/placeOrder.php?user_id=${widget.userId}'
        '&grandtotal=$grandTotal'
        '&address_id=$addressId'
        '&cart_id=$cartId';

    print('Placing order... URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Order Confirmed"),
                    ],
                  ),
                  content: Text(
                    data['message'] ??
                        'Your order has been placed successfully!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to place order')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
    } finally {
      setState(() => isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Summary'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Stepper(
                currentStep: currentStep,
                onStepContinue: () {
                  if (currentStep == 0 && selectedAddress == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select or add an address'),
                      ),
                    );
                    return;
                  }
                  if (currentStep < 2) setState(() => currentStep += 1);
                },
                onStepCancel: () {
                  if (currentStep > 0) setState(() => currentStep -= 1);
                },
                steps: [
                  Step(
                    title: Text('Address'),
                    content: _addressStep(),
                    isActive: currentStep >= 0,
                  ),
                  Step(
                    title: Text('Summary'),
                    content: _orderSummaryStep(),
                    isActive: currentStep >= 1,
                  ),
                  Step(
                    title: Text('Payment'),
                    content: _paymentStep(),
                    isActive: currentStep >= 2,
                  ),
                ],
              ),
    );
  }

  Widget _addressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Delivery Address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        if (addresses.isEmpty)
          Text('No addresses found. Please add an address.')
        else
          ...addresses.map(
            (address) => Card(
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(address.getFullAddress()),
                leading: Radio<Address>(
                  value: address,
                  groupValue: selectedAddress,
                  onChanged: (value) => setState(() => selectedAddress = value),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editAddress(address),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteAddress(address),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _showAddressForm,
          icon: Icon(Icons.add),
          label: Text('Add New Address'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
        ),
      ],
    );
  }

  Widget _orderSummaryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text('Product: ${widget.productDetails['pname']}'),
        Text('Price: ₹${widget.productDetails['price']}'),
        SizedBox(height: 20),
        Text(
          'Delivery Address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        selectedAddress != null
            ? Text(selectedAddress!.getFullAddress())
            : Text('No address selected', style: TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _paymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Payment Method'),
        ListTile(
          title: Text('UPI'),
          leading: Radio(
            value: 'UPI',
            groupValue: selectedPayment,
            onChanged: (v) => setState(() => selectedPayment = v!),
          ),
        ),
        ListTile(
          title: Text('Cash on Delivery'),
          leading: Radio(
            value: 'COD',
            groupValue: selectedPayment,
            onChanged: (v) => setState(() => selectedPayment = v!),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Amount Payable: ₹${widget.productDetails['price']}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: isPlacingOrder ? null : _placeOrder,
          child:
              isPlacingOrder
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Text('Place Order'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }
}

class AddressFormDialog extends StatefulWidget {
  final Map<String, String>? initialData;

  AddressFormDialog({this.initialData});

  @override
  _AddressFormDialogState createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _doorNoController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _contactnumberController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    if (data != null) {
      _doorNoController.text = data['doorNo'] ?? '';
      _streetNameController.text = data['streetName'] ?? '';
      _areaController.text = data['area'] ?? '';
      _cityController.text = data['city'] ?? '';
      _districtController.text = data['district'] ?? '';
      _pincodeController.text = data['pincode'] ?? '';
      _firstnameController.text = data['first_name'] ?? '';
      _lastnameController.text = data['last_name'] ?? '';
      _contactnumberController.text = data['contact_number'] ?? '';
    }
  }

  @override
  void dispose() {
    _doorNoController.dispose();
    _streetNameController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _contactnumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Address'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstnameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _lastnameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _contactnumberController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _doorNoController,
                decoration: InputDecoration(labelText: 'Door/Flat No.'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _streetNameController,
                decoration: InputDecoration(labelText: 'Street Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _areaController,
                decoration: InputDecoration(labelText: 'Area/Locality'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(labelText: 'District'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'doorNo': _doorNoController.text.trim(),
                'streetName': _streetNameController.text.trim(),
                'area': _areaController.text.trim(),
                'city': _cityController.text.trim(),
                'district': _districtController.text.trim(),
                'pincode': _pincodeController.text.trim(),
              });
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
