//kavins code
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sri_chandra_jewel/Model/address_Model.dart';

class OrderSummaryPage extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  final String userId;
  final Address address;
  final String cartId;

  const OrderSummaryPage({
    Key? key,
    required this.productDetails,
    required this.userId,
    required this.address,
    required this.cartId,
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
          'https://afosindia.com/mobile/getAddress.php?user_id=${widget.userId}',
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
          'https://afosindia.com/mobile/addAddress.php'
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
            isEditMode: true,
            initialData: {
              'first_name': address.firstName,
              'last_name': address.lastName,
              'contact_number': address.contactNumber,
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
          'https://afosindia.com/mobile/editAddress.php'
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
    final url = 'https://afosindia.com/mobile/deleteAddress.php?id=$id';
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
    final String grandTotal =
        widget.productDetails['final_price']?.toString() ?? '0';
    final String addressId = selectedAddress?.id?.toString() ?? '';
    final String cartId = widget.cartId;

    final url =
        'https://afosindia.com/mobile/placeOrder.php?user_id=${widget.userId}'
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
                controlsBuilder: (context, details) {
                  if (currentStep == 2)
                    return SizedBox(); // Hide controls in Payment step

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: details.onStepContinue,
                        icon: Icon(Icons.arrow_forward),
                        label: Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown, // Primary color
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                        ),
                      ),
                      SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: details.onStepCancel,
                        icon: Icon(Icons.close, color: Colors.brown),
                        label: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, color: Colors.brown),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.brown),
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  );
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
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio<Address>(
                      value: address,
                      groupValue: selectedAddress,
                      onChanged:
                          (value) => setState(() => selectedAddress = value),
                      activeColor: Colors.brown,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Optional: Name or type
                          Text(
                            address.firstName ?? 'Delivery Address',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            address.getFullAddress(),
                            style: TextStyle(fontSize: 14, height: 1.4),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Phone: ${address.contactNumber ?? ''}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editAddress(address),
                          tooltip: 'Edit Address',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteAddress(address),
                          tooltip: 'Delete Address',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _showAddressForm,
          icon: Icon(Icons.add, color: Colors.white),
          label: Text('Add New Address', style: TextStyle(color: Colors.white)),
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
        Text('Price: ₹${widget.productDetails['final_price']}'),
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
        Text(
          'Select Payment Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
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
        ListTile(
          title: Text('Bank Transfer / QR'),
          leading: Radio(
            value: 'BANK',
            groupValue: selectedPayment,
            onChanged: (v) => setState(() => selectedPayment = v!),
          ),
        ),

        // Show extra info only if BANK is selected
        if (selectedPayment == 'BANK') ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Bank Name: HDFC Bank'),
                    Text('Account No: 123456789012'),
                    Text('IFSC Code: HDFC0001234'),
                    Text('Account Holder: Sri Chandra Jewel Crafts'),
                    SizedBox(height: 16),
                    Text(
                      'Scan & Pay:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.brown.shade200),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: Image.asset(
                          'assets/qr_code.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],

        SizedBox(height: 20),
        Text(
          'Amount Payable: ₹${widget.productDetails['final_price']}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: isPlacingOrder ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.greenAccent.withOpacity(0.4),
          ),
          child:
              isPlacingOrder
                  ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_checkout, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }
}

class AddressFormDialog extends StatefulWidget {
  final Map<String, String>? initialData;
  final bool isEditMode;

  const AddressFormDialog({Key? key, this.initialData, this.isEditMode = false})
    : super(key: key);

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            widget.isEditMode
                ? Icons.edit_location_alt
                : Icons.add_location_alt,
            color: Colors.brown,
          ),
          SizedBox(width: 8),
          Text(widget.isEditMode ? 'Edit Address' : 'Add New Address'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput(_firstnameController, 'First Name'),
              _buildInput(_lastnameController, 'Last Name'),
              _buildInput(
                _contactnumberController,
                'Contact Number',
                keyboardType: TextInputType.phone,
              ),
              _buildInput(_doorNoController, 'Door/Flat No.'),
              _buildInput(_streetNameController, 'Street Name'),
              _buildInput(_areaController, 'Area/Locality'),
              _buildInput(_cityController, 'City'),
              _buildInput(_districtController, 'District'),
              _buildInput(
                _pincodeController,
                'Pincode',
                keyboardType: TextInputType.number,
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'first_name': _firstnameController.text.trim(),
                'last_name': _lastnameController.text.trim(),
                'contact_number': _contactnumberController.text.trim(),
                'doorNo': _doorNoController.text.trim(),
                'streetName': _streetNameController.text.trim(),
                'area': _areaController.text.trim(),
                'city': _cityController.text.trim(),
                'district': _districtController.text.trim(),
                'pincode': _pincodeController.text.trim(),
              });
            }
          },
          child: Text(
            widget.isEditMode ? 'Update' : 'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

Widget _buildInput(
  TextEditingController controller,
  String labelText, {
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator:
          (value) => value == null || value.trim().isEmpty ? 'Required' : null,
    ),
  );
}
