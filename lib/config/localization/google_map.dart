import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/widgets/myButton.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  LatLng? _currentPosition;
  GoogleMapController? _mapController;
  Set<Marker> _marker = {};
  TextEditingController searchController = TextEditingController();
  String _currentCity = ""; // User ki current city store hogi
  String _selectedAddress = "";
  MapType _currentMapType = MapType.normal;



  // Pakistan lat/lng bounds
  static const double minLat = 23.6345;
  static const double maxLat = 37.1333;
  static const double minLng = 60.8727;
  static const double maxLng = 77.8375;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  bool _isInPakistan(LatLng latLng) {
    return latLng.latitude >= minLat &&
        latLng.latitude <= maxLat &&
        latLng.longitude >= minLng &&
        latLng.longitude <= maxLng;
  }

  void _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError("Location permissions are denied");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError("Location permissions are permanently denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      if (!_isInPakistan(latLng)) {
        _showError("Your location is outside Pakistan.");
        return;
      }

      // Get city from current location
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      String city = placemarks.isNotEmpty
          ? placemarks.first.locality ?? ""
          : "";

      setState(() {
        _currentPosition = latLng;
        _currentCity = city; // Store current city
        _marker = {
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: latLng,
            infoWindow: const InfoWindow(title: "Your Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 18),
        ),
      );

      _updateSearchBar(latLng);
    } catch (e) {
      print("Error determining location: $e");
    }
  }

  Future<void> _updateSearchBar(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final fullAddress =
            "${place.name ?? ""}, ${place.locality ?? ""}, ${place.administrativeArea ?? ""}, ${place.country ?? ""}";
        setState(() {
          searchController.text = fullAddress;
          _selectedAddress = fullAddress;
          _currentCity = place.locality ?? ""; 
        });
      }
    } catch (e) {
      print("Error updating search bar: $e");
    } 
  }

  void _onMapTap(LatLng latLng) {
    if (!_isInPakistan(latLng)) {
      _showError("Please select a location within Pakistan.");
      return;
    }
    _setMarker(latLng, "Selected Location");
  }

  void _setMarker(LatLng latLng, String title) {
    setState(() {
      _marker = {
        Marker(
          markerId: MarkerId(title),
          position: latLng,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    _updateSearchBar(latLng);
  }

  void _onSearchSubmitted(String value) async {
    if (value.isEmpty) return;

    try {
      // Automatically append current city for accurate search
      String query = value;
      if (_currentCity.isNotEmpty) {
        query += ", $_currentCity, Pakistan";
      }

      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        LatLng latLng = LatLng(loc.latitude, loc.longitude);

        if (!_isInPakistan(latLng)) {
          _showError("Selected location is outside Pakistan.");
          return;
        }

        _setMarker(latLng, value);
      } else {
        _showError("Location not found");
      }
    } catch (e) {
      _showError("Error searching location");
    }
  }

  void _confirmLocation() {
    if (_marker.isNotEmpty) {
      LatLng selectedLatLng = _marker.first.position;
      Navigator.pop(context, {
        'address': _selectedAddress,
        'lat': selectedLatLng.latitude,
        'lng': selectedLatLng.longitude,
        "city": _currentCity
      }); // ye Map return karega AddRestaurant ko
    } else {
      _showError("Please select a location first.");
    }
  }

  Future<void> _goToCurrentLocationAndSelect() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError("Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError("Location permission permanently denied");
        return;
      }

      // ✅ Get current position
      Position position = await Geolocator.getCurrentPosition();
      LatLng latLng = LatLng(position.latitude, position.longitude);

      if (!_isInPakistan(latLng)) {
        _showError("Location outside Pakistan");
        return;
      }

      // ✅ Camera move
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 18),
        ),
      );

      // ✅ Marker + selection + address update
      setState(() {
        _currentPosition = latLng;
        _marker = {
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: latLng,
            infoWindow: const InfoWindow(title: "Current Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        };
      });

      // ✅ Update address + search bar
      await _updateSearchBar(latLng);
    } catch (e) {
      _showError("Failed to get current location");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? const LatLng(24.8607, 67.0011),
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _marker,
            onTap: _onMapTap,
          ),

          // Search bar
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "Search for location",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
                onSubmitted: _onSearchSubmitted,
              ),
            ),
          ),

          // Bottom container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedAddress.isEmpty
                        ? "Select a location on map"
                        : _selectedAddress,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                  MyButton(title: "Confirm Location", ontap: _confirmLocation),
                ],
              ),
            ),
          ),


          
     Positioned(
      bottom: 200,
      left: 20,
      child: 
        InkWell(
  onTap:  (){
     setState(() {
        _currentMapType =
            _currentMapType == MapType.normal
                ? MapType.satellite
                : MapType.normal;
      });
  },
  borderRadius: BorderRadius.circular(100),
  child: Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      image: DecorationImage(image:
       _currentMapType == MapType.normal
        ? const AssetImage("assets/png_images/map_image.png")
        : const AssetImage("assets/png_images/map_image2.png"),),
      
      color: Colors.grey.shade400,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(width: 1,color: Colors.white),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ), 
  ),
)
    
    ),



    // RIGHT BUTTON
    Positioned(
      bottom: 200,
      right: 20,
      child: 
      InkWell(
  onTap:  _goToCurrentLocationAndSelect,
  borderRadius: BorderRadius.circular(100),
  child: Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.grey.shade400,
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child:  const Icon(Icons.my_location_outlined,color: Colors.black,), 
  ),
)
    
    
    ),  

            
        ],
      ),
    );
  }
}
