import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  Position? _currentPosition;
  MapType _currentMapType = MapType.normal;
  List<LatLng> _trackedPositions = [];
  List<Marker> _markers = [];
  double _totalDistance = 0.0;
  bool _isTracking = false;
  Polyline? _pathPolyline;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get the current location of the user
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    _addMarker(_currentPosition!);

    // Move the camera to the current position after getting the location
    _moveCameraToCurrentPosition();

    if (_isTracking) {
      _startTracking();
    }
  }

  // Add a marker to the current location
  void _addMarker(Position position) {
    _markers.add(
      Marker(
        markerId: MarkerId('current_location'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            _isTracking ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Current Location'),
      ),
    );
  }

  // Move the camera to the current position
  void _moveCameraToCurrentPosition() async {
    if (_currentPosition != null) {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15,
      ));
    }
  }

  // Start tracking the user's location
  void _startTracking() {
    Geolocator.getPositionStream().listen((Position position) {
      if (_trackedPositions.isNotEmpty) {
        LatLng previousPosition = _trackedPositions.last;
        double distanceInMeters = Geolocator.distanceBetween(
          previousPosition.latitude,
          previousPosition.longitude,
          position.latitude,
          position.longitude,
        );
        setState(() {
          _totalDistance += distanceInMeters;
        });
      }
      setState(() {
        _trackedPositions.add(LatLng(position.latitude, position.longitude));
      });

      _addMarker(position);

      _mapController.future.then((controller) {
        controller.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ));
      });
    });
  }

  // Toggle tracking state (start/stop)
  void _toggleTracking() {
    if (_isTracking) {
      setState(() {
        _isTracking = false;
      });
      _drawPolyline(); // Draw polyline when tracking is stopped
    } else {
      setState(() {
        _isTracking = true;
        _trackedPositions
            .clear(); // Clear previous tracked positions when starting fresh
        _totalDistance = 0.0; // Reset distance when starting a new tracking
      });
      _startTracking();
    }
  }

  // Draw polyline connecting the tracked positions
  void _drawPolyline() {
    if (_trackedPositions.isNotEmpty) {
      setState(() {
        _pathPolyline = Polyline(
          polylineId: PolylineId('path'),
          color: Colors.blue,
          width: 5,
          points: _trackedPositions,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: _currentMapType,
          initialCameraPosition: CameraPosition(
            target: LatLng(21.2163,
                81.3824), // Default position if location is not available
            zoom: 12,
          ),
          markers: Set<Marker>.of(_markers),
          polylines: _pathPolyline != null ? {_pathPolyline!} : {},
          onMapCreated: (GoogleMapController controller) {
            _mapController.complete(controller);
          },
        ),
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            child: Icon(
              _currentMapType == MapType.normal ? Icons.satellite : Icons.map,
              color: Colors.black,
            ),
            onPressed: () {
              _getCurrentLocation();
              setState(() {
                _currentMapType = _currentMapType == MapType.normal
                    ? MapType.satellite
                    : MapType.normal;
              });
            },
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: _isTracking
                ? Colors.red
                : const Color.fromARGB(255, 22, 28, 112),
            child: Icon(
              _isTracking ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _toggleTracking, // Toggle tracking
          ),
        ),
        Positioned(
          bottom: 80,
          right: 16,
          child: FloatingActionButton(
            child: const Icon(Icons.my_location),
            onPressed: () {
              _getCurrentLocation(); // Ensures the location is updated and the camera moves
            },
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: Text(
              'Distance: ${(_totalDistance / 1000).toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
