
import 'service.dart';

class Company {
  final int id;
  final String name;
  final String registrationNumber;
  final List<Service> services;

  Company({
    required this.id,
    required this.name,
    required this.registrationNumber,
    this.services = const [],
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int,
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String,
      services: (json['services'] as List<dynamic>? ?? [])
          .map(
            (service) => Service.fromJson(
              service as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
