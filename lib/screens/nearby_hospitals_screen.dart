import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/hospital.dart';
import '../services/hospital_service.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen> {
  final HospitalService _hospitalService = HospitalService();

  List<Hospital> hospitals = [];
  bool isLoading = true;

  Position? currentPosition;

  String currentLocationName = 'Getting your location...';

  // QuickAlert colors
  static const Color navy = Color(0xFF123B78);
  static const Color red = Color(0xFFE53935);
  static const Color green = Color(0xFF22A06B);
  static const Color background = Color(0xFFF7F9FC);

  @override
  void initState() {
    super.initState();
    loadHospitals();
  }

  // ============================================================
  // LOAD HOSPITALS
  // ============================================================

  Future<void> loadHospitals() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception("Location services are disabled.");
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission permanently denied.");
      }

      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      currentPosition = position;

      debugPrint(
        "Latitude: ${position.latitude}, "
        "Longitude: ${position.longitude}",
      );

      // Get readable location name
      await getLocationName(position.latitude, position.longitude);

      final result = await _hospitalService.getNearbyHospitals(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        hospitals = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Hospital Error: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ============================================================
  // GET LOCATION NAME
  // ============================================================

  Future<void> getLocationName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final parts = <String>[];

        if (place.locality != null && place.locality!.trim().isNotEmpty) {
          parts.add(place.locality!.trim());
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.trim().isNotEmpty) {
          parts.add(place.subAdministrativeArea!.trim());
        }

        if (place.administrativeArea != null &&
            place.administrativeArea!.trim().isNotEmpty) {
          parts.add(place.administrativeArea!.trim());
        }

        String locationName = parts.join(', ');

        if (locationName.isEmpty) {
          locationName = 'Current Location';
        }

        if (mounted) {
          setState(() {
            currentLocationName = locationName;
          });
        }
      }
    } catch (e) {
      debugPrint("Reverse geocoding error: $e");

      if (mounted) {
        setState(() {
          currentLocationName = 'Current Location';
        });
      }
    }
  }

  // ============================================================
  // GOOGLE MAPS - HOSPITAL
  // ============================================================

  Future<void> openGoogleMaps(Hospital hospital) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/dir/"
      "?api=1"
      "&destination=${hospital.latitude},"
      "${hospital.longitude}"
      "&travelmode=driving",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open Google Maps"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ============================================================
  // GOOGLE MAPS - CURRENT LOCATION
  // ============================================================

  Future<void> openCurrentLocation() async {
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Current location is not available"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final latitude = currentPosition!.latitude;
    final longitude = currentPosition!.longitude;

    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/"
      "?api=1"
      "&query=$latitude,$longitude",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open Google Maps"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget buildHeader() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: red.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.local_hospital_rounded, color: red, size: 42),
        ),

        const SizedBox(height: 16),

        const Text(
          'NEARBY HOSPITALS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: navy,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Find medical assistance near your location',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  // ============================================================
  // LOCATION INFO
  // ============================================================

  Widget buildLocationInfo() {
    return InkWell(
      onTap: openCurrentLocation,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: navy.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: navy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: navy,
                size: 23,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Current Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    currentLocationName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    'Tap to view on Google Maps',
                    style: TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(Icons.arrow_forward_ios_rounded, color: navy, size: 17),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HOSPITAL CARD
  // ============================================================

  Widget buildHospitalCard(Hospital hospital, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: red,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: navy,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: red,
                          size: 17,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          '${hospital.distance.toStringAsFixed(2)} km away',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                openGoogleMaps(hospital);
              },
              icon: const Icon(Icons.navigation_rounded, size: 20),
              label: const Text(
                'NAVIGATE TO HOSPITAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING UI
  // ============================================================

  Widget buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: red.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(22),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(red),
              ),
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Finding nearby hospitals...',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Using your current location',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: navy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_outlined,
                color: navy,
                size: 48,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No hospitals found nearby',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'We could not find any hospitals '
              'around your current location.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 22),

            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });

                loadHospitals();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('TRY AGAIN'),
              style: OutlinedButton.styleFrom(
                foregroundColor: navy,
                side: const BorderSide(color: navy),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: navy,
        centerTitle: true,
        title: const Text(
          'QuickAlert',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),

      body: isLoading
          ? buildLoading()
          : hospitals.isEmpty
          ? buildEmptyState()
          : RefreshIndicator(
              color: red,
              onRefresh: loadHospitals,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                children: [
                  buildHeader(),

                  const SizedBox(height: 24),

                  buildLocationInfo(),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      const Icon(
                        Icons.medical_services_outlined,
                        color: navy,
                        size: 20,
                      ),

                      const SizedBox(width: 7),

                      Text(
                        '${hospitals.length} '
                        'hospital'
                        '${hospitals.length == 1 ? '' : 's'} found',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 13),

                  ...List.generate(hospitals.length, (index) {
                    return buildHospitalCard(hospitals[index], index);
                  }),
                ],
              ),
            ),
    );
  }
}
