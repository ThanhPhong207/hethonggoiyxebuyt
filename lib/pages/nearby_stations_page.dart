import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NearbyStationsPage extends StatefulWidget {
  const NearbyStationsPage({super.key});

  @override
  State<NearbyStationsPage> createState() => _NearbyStationsPageState();
}

class _NearbyStationsPageState extends State<NearbyStationsPage> {
  LatLng? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition();

    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });

    _addNearbyStations();
  }

  void _addNearbyStations() {
    final sampleStations = [
      LatLng(_currentPosition!.latitude + 0.001, _currentPosition!.longitude),
      LatLng(_currentPosition!.latitude - 0.001, _currentPosition!.longitude + 0.001),
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude - 0.001),
    ];

    final markers = sampleStations.asMap().entries.map((e) {
      return Marker(
        point: e.value,
        width: 40,
        height: 40,
        child: Tooltip(
          message: "Trạm Buýt ${e.key + 1}",
          child: const Icon(Icons.directions_bus, size: 34),
        ),
      );
    }).toSet();

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Trạm xung quanh")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _currentPosition!,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.hethonggoiyxebus',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition!,
                width: 40,
                height: 40,
                child: const Icon(Icons.my_location, size: 34),
              ),
              ..._markers,
            ],
          ),
        ],
      ),
    );
  }
}
