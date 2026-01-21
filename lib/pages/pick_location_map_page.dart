import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PickLocationResult {
  final LatLng point;
  final String displayName;
  PickLocationResult(this.point, this.displayName);
}

class PickLocationMapPage extends StatefulWidget {
  final LatLng initialCenter;
  final String title;

  const PickLocationMapPage({
    super.key,
    required this.initialCenter,
    required this.title,
  });

  @override
  State<PickLocationMapPage> createState() => _PickLocationMapPageState();
}

class _PickLocationMapPageState extends State<PickLocationMapPage> {
  final MapController _mapController = MapController();

  LatLng? _picked;
  String _pickedName = "Chạm lên bản đồ để chọn điểm";

  LatLng? _myLocation;
  bool _locating = false;

  static const LatLng hcmCenter = LatLng(10.7769, 106.7009);

  @override
  void initState() {
    super.initState();
    _initMyLocationOrHcm();
  }

  Future<void> _reverseGeocode(LatLng p) async {
    final uri = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse"
          "?format=jsonv2&lat=${p.latitude}&lon=${p.longitude}",
    );
    try {
      final res = await http.get(uri, headers: {
        "User-Agent": "hethonggoiyxebus/1.0 (education project)",
        "Accept-Language": "vi",
      });
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final name = (data["display_name"] as String?) ?? "Điểm đã chọn";
      if (!mounted) return;
      setState(() => _pickedName = name);
    } catch (_) {}
  }

  Future<bool> _ensureLocationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> _initMyLocationOrHcm() async {
    // mặc định bay về HCM để khỏi nhảy Mỹ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(hcmCenter, 13.5);
    });

    final ok = await _ensureLocationPermission();
    if (!ok) return;

    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final me = LatLng(pos.latitude, pos.longitude);

      if (!mounted) return;
      setState(() => _myLocation = me);

      _mapController.move(me, 15.5);
    } catch (_) {}
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      final ok = await _ensureLocationPermission();
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chưa có quyền vị trí hoặc GPS đang tắt.")),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final me = LatLng(pos.latitude, pos.longitude);

      if (!mounted) return;
      setState(() => _myLocation = me);

      _mapController.move(me, 15.5);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không lấy được vị trí hiện tại.")),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: hcmCenter, // ✅ luôn lấy HCM làm trung tâm mặc định
              initialZoom: 13,
              onTap: (tapPosition, point) async {
                setState(() {
                  _picked = point;
                  _pickedName = "Đang lấy địa chỉ...";
                });
                await _reverseGeocode(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.hethonggoiyxebus",
              ),
              MarkerLayer(
                markers: [
                  if (_myLocation != null)
                    Marker(
                      point: _myLocation!,
                      width: 38,
                      height: 38,
                      child: const Icon(Icons.my_location, size: 28),
                    ),
                  if (_picked != null)
                    Marker(
                      point: _picked!,
                      width: 44,
                      height: 44,
                      child: const Icon(Icons.location_on, size: 38),
                    ),
                ],
              ),
            ],
          ),


          Positioned(
            right: 12,
            bottom: 210,
            child: FloatingActionButton(
              heroTag: "my_location_btn",
              onPressed: _locating ? null : _goToMyLocation,
              child: _locating
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
            ),
          ),

          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Chạm để chọn điểm",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 3))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pickedName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _picked == null
                          ? null
                          : () {
                        Navigator.pop(
                          context,
                          PickLocationResult(_picked!, _pickedName),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Chọn điểm này"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
