class Address {
  final String id;
  final String doorNo;
  final String streetName;
  final String area;
  final String city;
  final String district;
  final String pincode;

  Address({
    required this.id,
    required this.doorNo,
    required this.streetName,
    required this.area,
    required this.city,
    required this.district,
    required this.pincode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      doorNo: json['door_no'] ?? '',
      streetName: json['street_name'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }

  String getFullAddress() {
    return '$doorNo, $streetName, $area, $city, $district - $pincode';
  }
}
