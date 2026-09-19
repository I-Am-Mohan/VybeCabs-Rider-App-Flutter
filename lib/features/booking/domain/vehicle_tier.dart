import 'package:flutter/material.dart';

enum VehicleType { car, bike, tirri }

class VehicleTier {
  final String id;
  final String name;
  final VehicleType type;
  final double basePrice;
  final int etaMinutes;
  final int capacity;
  final String description;
  final IconData icon;

  const VehicleTier({
    required this.id,
    required this.name,
    required this.type,
    required this.basePrice,
    required this.etaMinutes,
    required this.capacity,
    required this.description,
    required this.icon,
  });

  static const List<VehicleTier> defaultTiers = [
    VehicleTier(
      id: 'car_go',
      name: 'Vybe Go',
      type: VehicleType.car,
      basePrice: 185.0,
      etaMinutes: 3,
      capacity: 4,
      description: 'Affordable, compact AC cabs with top rated drivers',
      icon: Icons.directions_car_filled_rounded,
    ),
    VehicleTier(
      id: 'bike_moto',
      name: 'Vybe Moto',
      type: VehicleType.bike,
      basePrice: 55.0,
      etaMinutes: 2,
      capacity: 1,
      description: 'Beat traffic with verified riders & safety helmet',
      icon: Icons.two_wheeler_rounded,
    ),
    VehicleTier(
      id: 'tirri_toto',
      name: 'Vybe Tirri',
      type: VehicleType.tirri,
      basePrice: 35.0,
      etaMinutes: 4,
      capacity: 3,
      description: 'Zero emission, quick E-Rickshaw for local hops',
      icon: Icons.electric_rickshaw_rounded,
    ),
    VehicleTier(
      id: 'car_prime',
      name: 'Vybe Prime Sedan',
      type: VehicleType.car,
      basePrice: 245.0,
      etaMinutes: 5,
      capacity: 4,
      description: 'Spacious sedans with free Wi-Fi & top chauffeurs',
      icon: Icons.local_taxi_rounded,
    ),
  ];
}
