import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/hospital.dart';
import 'package:flutter/foundation.dart';

class HospitalService {
  Future<List<Hospital>> getNearbyHospitals(
    double latitude,
    double longitude,
  ) async {
    final String query =
        '''
[out:json];
(
  node["amenity"="hospital"](around:5000,$latitude,$longitude);
  way["amenity"="hospital"](around:5000,$latitude,$longitude);
  
);
out center;
''';
    final response = await http.post(
      Uri.parse('https://maps.mail.ru/osm/tools/overpass/api/interpreter'),
      body: {'data': query},
    );
    if (response.statusCode != 200) {
      debugPrint("Hospital API Status: ${response.statusCode}");
      debugPrint("Hospital API Response: ${response.body}");
      throw Exception("Failed to load hospitals (${response.statusCode})");
    }
    final data = jsonDecode(response.body);
    final elements = data['elements'] as List;
    debugPrint("Hospital API returned ${elements.length} hospitals");
    List<Hospital> hospitals = [];
    for (var element in elements) {
      final tags = element['tags'] ?? {};

      final name = tags['name'] ?? "Unknown Hospital";
      double lat;

      double lon;

      if (element['lat'] != null && element['lon'] != null) {
        lat = element['lat'];
        lon = element['lon'];
      } else if (element['center'] != null) {
        lat = element['center']['lat'];
        lon = element['center']['lon'];
      } else {
        continue; // Skip invalid entries
      }
      double distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        lat,
        lon,
      );
      distance = distance / 1000;
      hospitals.add(
        Hospital(name: name, latitude: lat, longitude: lon, distance: distance),
      );
    }
    hospitals.sort((a, b) => a.distance.compareTo(b.distance));

    return hospitals;
  }
}
