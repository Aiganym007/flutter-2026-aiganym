class Geo {
  const Geo({required this.lat, required this.lng});
  final String lat;
  final String lng;

  factory Geo.fromJson(Map<String, dynamic> j) =>
      Geo(lat: j['lat'] as String, lng: j['lng'] as String);

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });
  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  factory Address.fromJson(Map<String, dynamic> j) => Address(
    street: j['street'] as String,
    suite: j['suite'] as String,
    city: j['city'] as String,
    zipcode: j['zipcode'] as String,
    geo: Geo.fromJson(j['geo'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'street': street,
    'suite': suite,
    'city': city,
    'zipcode': zipcode,
    'geo': geo.toJson(),
  };
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
  });
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final Address address;

  String get phoneDigits =>
      phone.split(RegExp('[xX]')).first.replaceAll(RegExp(r'[^0-9+]'), '');

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'] as int,
    name: j['name'] as String,
    username: j['username'] as String,
    email: j['email'] as String,
    phone: j['phone'] as String,
    website: j['website'] as String,
    address: Address.fromJson(j['address'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'phone': phone,
    'website': website,
    'address': address.toJson(),
  };
}
