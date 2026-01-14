import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class TrackOrderMapView extends StatefulWidget {
  final LatLng userLatLng;
  final LatLng restaurantLatLng;

  const TrackOrderMapView({
    super.key,
    required this.userLatLng,
    required this.restaurantLatLng,
  });

  @override
  State<TrackOrderMapView> createState() => _TrackOrderMapViewState();
}

class _TrackOrderMapViewState extends State<TrackOrderMapView> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Completer<GoogleMapController> _controller = Completer();

  static const double _defaultZoom = 13.5;

  @override
  void initState() {
    super.initState();
    _addMarkers();
    _drawRoute(); // Draw route after markers
  }

  void _addMarkers() {
    _markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: widget.userLatLng,
        infoWindow: const InfoWindow(title: "Your Location"),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('restaurant'),
        position: widget.restaurantLatLng,
        infoWindow: const InfoWindow(title: "Restaurant"),
      ),
    );
  }

  Future<void> _drawRoute() async {
    /// 1️⃣ Create instance with your API key
     print("User location: ${widget.userLatLng.latitude}, ${widget.userLatLng.longitude}");
  print("Restaurant location: ${widget.restaurantLatLng.latitude}, ${widget.restaurantLatLng.longitude}");
    PolylinePoints polylinePoints = PolylinePoints(apiKey: "YOUR_GOOGLE_MAPS_API_KEY");

    /// 2️⃣ Build request
    final request = PolylineRequest(
      origin: PointLatLng(widget.userLatLng.latitude, widget.userLatLng.longitude),
      destination: PointLatLng(widget.restaurantLatLng.latitude, widget.restaurantLatLng.longitude),
      mode: TravelMode.driving,
    );

    

    /// 3️⃣ Get result
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: request,
    );

    if (result.points.isNotEmpty) {
      List<LatLng> routePoints = result.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points: routePoints,
          ),
        );
      });
    } else {
      debugPrint("No route found or permission error");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Center view between user & restaurant
    LatLng center = LatLng(
      (widget.userLatLng.latitude + widget.restaurantLatLng.latitude) / 2,
      (widget.userLatLng.longitude + widget.restaurantLatLng.longitude) / 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Order"),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: center, zoom: _defaultZoom),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (controller) {
          _controller.complete(controller);
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
