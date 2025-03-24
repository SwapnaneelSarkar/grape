import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening Google Maps directions

import '../../color_constant/color_constant.dart';
import '../bottm nav bar/view.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(37.7749, -122.4194); // Default: SF
  Set<Marker> _markers = {};
  Set<Marker> _pharmacyMarkers = {};
  Set<Marker> _hospitalMarkers = {};
  bool _showPharmacies = true;
  bool _showHospitals = true;
  bool _locationFetched = false;
  final Dio dio = Dio();
  final String googleApiKey =
  Key_Here; // Add your API key here
  late Position _userPosition;

  // Variables to store nearest pharmacy and hospital
  Marker? _nearestPharmacy;
  Marker? _nearestHospital;

  @override
  void initState() {
    super.initState();
    debugPrint("Initializing MapView...");
    _fetchNearbyPlaces();
  }

  Future<void> _fetchNearbyPlaces() async {
    try {
      debugPrint("Fetching user location...");
      Position position = await _determinePosition();
      debugPrint("User position: ${position.latitude}, ${position.longitude}");

      setState(() {
        _userPosition = position;
        _initialPosition = LatLng(position.latitude, position.longitude);
        _locationFetched = true;
      });

      debugPrint("Fetching pharmacies...");
      _pharmacyMarkers = await _fetchAndBuildMarkers(
        position,
        "pharmacy",
        BitmapDescriptor.hueBlue,
      );
      debugPrint("Pharmacies fetched: ${_pharmacyMarkers.length}");

      debugPrint("Fetching hospitals...");
      _hospitalMarkers = await _fetchAndBuildMarkers(
        position,
        "hospital",
        BitmapDescriptor.hueRed,
      );
      debugPrint("Hospitals fetched: ${_hospitalMarkers.length}");

      // Find nearest pharmacy and hospital
      debugPrint("Finding nearest pharmacy...");
      _nearestPharmacy = _getNearestPlace(_pharmacyMarkers);
      debugPrint("Nearest pharmacy: ${_nearestPharmacy?.infoWindow.title}");

      debugPrint("Finding nearest hospital...");
      _nearestHospital = _getNearestPlace(_hospitalMarkers);
      debugPrint("Nearest hospital: ${_nearestHospital?.infoWindow.title}");

      setState(() {
        _updateMarkers();
      });
    } catch (e) {
      debugPrint("Error fetching places: $e");
    }
  }

  Future<Position> _determinePosition() async {
    debugPrint("Checking location permission...");
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint("Location permission requested.");
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    debugPrint("Getting current position...");
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    debugPrint("Current position: ${position.latitude}, ${position.longitude}");
    return position;
  }

  Future<Set<Marker>> _fetchAndBuildMarkers(
    Position position,
    String type,
    double hue,
  ) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=5000&type=$type&key=$googleApiKey";

    debugPrint("Fetching data from Google Places API for type: $type...");
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        debugPrint("API Response received successfully.");
        return response.data['results'].map<Marker>((place) {
          debugPrint("Place found: ${place['name']}");
          return Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(
              place['geometry']['location']['lat'],
              place['geometry']['location']['lng'],
            ),
            infoWindow: InfoWindow(title: place['name'], snippet: type),
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          );
        }).toSet();
      } else {
        throw Exception("Failed to fetch $type data");
      }
    } catch (e) {
      debugPrint("Error fetching $type data: $e");
      return {};
    }
  }

  void _updateMarkers() {
    debugPrint("Updating markers...");
    _markers.clear();
    if (_showPharmacies) {
      debugPrint("Adding pharmacies to markers...");
      _markers.addAll(_pharmacyMarkers);
    }
    if (_showHospitals) {
      debugPrint("Adding hospitals to markers...");
      _markers.addAll(_hospitalMarkers);
    }
  }

  // Calculate the nearest place (either pharmacy or hospital)
  Marker? _getNearestPlace(Set<Marker> places) {
    if (places.isEmpty) return null;

    Marker nearestPlace = places.first;
    double nearestDistance = Geolocator.distanceBetween(
      _userPosition.latitude,
      _userPosition.longitude,
      nearestPlace.position.latitude,
      nearestPlace.position.longitude,
    );
    debugPrint("Initial nearest place: ${nearestPlace.infoWindow.title}");

    for (Marker place in places) {
      double distance = Geolocator.distanceBetween(
        _userPosition.latitude,
        _userPosition.longitude,
        place.position.latitude,
        place.position.longitude,
      );

      debugPrint(
        "Checking distance to ${place.infoWindow.title}: $distance meters",
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestPlace = place;
        debugPrint("New nearest place: ${nearestPlace.infoWindow.title}");
      }
    }
    return nearestPlace;
  }

  // Launch Google Maps with directions to the selected location
  Future<void> _openGoogleMapsDirections(Marker marker) async {
    String url =
        'https://www.google.com/maps/dir/?api=1&origin=${_userPosition.latitude},${_userPosition.longitude}&destination=${marker.position.latitude},${marker.position.longitude}&travelmode=driving';

    debugPrint("Opening Google Maps with directions: $url");
    if (await canLaunch(url)) {
      debugPrint("Launching Google Maps...");
      await launch(url);
    } else {
      debugPrint("Could not launch Google Maps with URL: $url");
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Height of the AppBar
        child: AppBar(
          automaticallyImplyLeading: false, // This removes the back button
          title: Center(
            // This centers the title
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center, // Aligns text vertically in the center
              crossAxisAlignment:
                  CrossAxisAlignment
                      .center, // Ensures text is centered horizontally
              children: [
                Text(
                  "Nearby Pharmacies & Hospitals",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.buttonText,
                  ),
                ),
                Text(
                  "Find the closest pharmacy or hospital",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 8.0, // Adds shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          actions: [], // Removed back button
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Show Pharmacies",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    Switch(
                      value: _showPharmacies,
                      onChanged: (value) {
                        debugPrint("Show Pharmacies switched to: $value");
                        setState(() {
                          _showPharmacies = value;
                          _updateMarkers();
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Show Hospitals",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    Switch(
                      value: _showHospitals,
                      onChanged: (value) {
                        debugPrint("Show Hospitals switched to: $value");
                        setState(() {
                          _showHospitals = value;
                          _updateMarkers();
                        });
                      },
                      activeColor: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _locationFetched
                    ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _initialPosition,
                        zoom: 13.0,
                      ),
                      markers: _markers,
                      onMapCreated: (controller) {
                        debugPrint("Map Controller Created");
                        _mapController = controller;
                      },
                    )
                    : Center(child: CircularProgressIndicator()),
          ),
          // Floating box with nearest pharmacy and hospital names and buttons
          if (_nearestPharmacy != null || _nearestHospital != null)
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                children: [
                  if (_nearestPharmacy != null)
                    ListTile(
                      title: Text(
                        'Nearest Pharmacy: ${_nearestPharmacy?.infoWindow.title}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.directions),
                        onPressed:
                            () => _openGoogleMapsDirections(_nearestPharmacy!),
                      ),
                    ),
                  if (_nearestHospital != null)
                    ListTile(
                      title: Text(
                        'Nearest Hospital: ${_nearestHospital?.infoWindow.title}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.directions),
                        onPressed:
                            () => _openGoogleMapsDirections(_nearestHospital!),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3, // You can change the currentIndex based on the screen
      ),
    );
  }
}
