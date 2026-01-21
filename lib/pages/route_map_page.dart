import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_suggestion.dart';

class RouteMapPage extends StatelessWidget {
  final RouteOption option;
  const RouteMapPage({super.key, required this.option});

  LatLng _center(List<RoutePolylineSegment> segs) {
    for (final s in segs) {
      if (s.points.isNotEmpty) return s.points[s.points.length ~/ 2];
    }
    return const LatLng(10.7720, 106.6983);
  }

  String _fmt(double meters) => meters >= 1000 ? "${(meters / 1000).toStringAsFixed(1)} km" : "${meters.toStringAsFixed(0)} m";

  IconData _stepIcon(StepType t) {
    switch (t) {
      case StepType.walk: return Icons.directions_walk;
      case StepType.bus: return Icons.directions_bus;
      case StepType.transfer: return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _center(option.segments);

    final polylines = option.segments.map((s) {
      return Polyline(
        points: s.points,
        strokeWidth: s.isBus ? 6 : 4,
        color: s.color,
      );
    }).toList();

    final markers = <Marker>[
      // highlights
      for (int i = 0; i < option.highlights.length; i++)
        Marker(
          point: option.highlights[i],
          width: 44,
          height: 44,
          child: Icon(
            i == 0 ? Icons.trip_origin : (i == option.highlights.length - 1 ? Icons.flag : Icons.location_on),
            size: 34,
          ),
        ),


      if (option.transferPoint != null)
        Marker(
          point: option.transferPoint!,
          width: 52,
          height: 52,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(blurRadius: 6)],
            ),
            child: const Icon(Icons.directions_bus, size: 34),
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(option.title)),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 12.8,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "com.example.hethonggoiyxebus",
                ),
                PolylineLayer(polylines: polylines),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: const [BoxShadow(blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "⏱ ${option.totalMinutes.toStringAsFixed(0)} phút • 📍 ${_fmt(option.totalMeters)} • 💰 ${option.totalPriceVnd}đ",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    itemCount: option.steps.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final s = option.steps[i];
                      return ListTile(
                        dense: true,
                        leading: Icon(_stepIcon(s.type)),
                        title: Text(s.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text("${_fmt(s.distanceMeters)} • ${s.durationMinutes.toStringAsFixed(0)} phút"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
