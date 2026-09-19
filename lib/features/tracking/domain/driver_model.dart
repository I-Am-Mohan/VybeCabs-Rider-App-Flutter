class DriverModel {
  final String id;
  final String name;
  final String photoUrl;
  final String vehicleModel;
  final String vehicleNumber;
  final double rating;
  final int totalRides;
  final String phone;

  const DriverModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.vehicleModel,
    required this.vehicleNumber,
    required this.rating,
    required this.totalRides,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'vehicleModel': vehicleModel,
      'vehicleNumber': vehicleNumber,
      'rating': rating,
      'totalRides': totalRides,
      'phone': phone,
    };
  }

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      vehicleModel: map['vehicleModel'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
      totalRides: (map['totalRides'] as num?)?.toInt() ?? 1250,
      phone: map['phone'] ?? '+91 98301 22345',
    );
  }

  static const DriverModel sampleCarDriver = DriverModel(
    id: 'drv_101',
    name: 'Subhashish Mukherjee',
    photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
    vehicleModel: 'Maruti Suzuki Dzire (White)',
    vehicleNumber: 'WB 06 H 4920',
    rating: 4.92,
    totalRides: 3410,
    phone: '+91 98312 45876',
  );

  static const DriverModel sampleBikeDriver = DriverModel(
    id: 'drv_102',
    name: 'Rahul Chakraborty',
    photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
    vehicleModel: 'Honda Shine 125 (Black)',
    vehicleNumber: 'WB 07 BK 9012',
    rating: 4.88,
    totalRides: 1820,
    phone: '+91 98308 11234',
  );

  static const DriverModel sampleTirriDriver = DriverModel(
    id: 'drv_103',
    name: 'Dilip Kumar Das',
    photoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e',
    vehicleModel: 'Mayuri E-Rickshaw Deluxe (Green)',
    vehicleNumber: 'WB 19 ER 7781',
    rating: 4.95,
    totalRides: 2190,
    phone: '+91 98319 76543',
  );
}
