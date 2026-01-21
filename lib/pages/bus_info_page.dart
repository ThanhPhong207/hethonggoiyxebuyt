import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/hcm_bus_demo_data.dart';

class BusInfoPage extends StatelessWidget {
  BusInfoPage({super.key});

  final List<BusLine> lines = HcmBusDemoData.buildLines();
  final Map<String, BusStop> stopsById = HcmBusDemoData.stopsById;

  String _stopName(String id) => stopsById[id]?.name ?? id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tất cả tuyến xe buýt"),
        backgroundColor: Colors.green,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: lines.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final line = lines[index];
          final startId = line.stopIds.first;
          final endId = line.stopIds.last;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BusRouteDetailPage(line: line),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.green,
                    child: Text(
                      line.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text("Bắt đầu: ${_stopName(startId)}",
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text("Kết thúc: ${_stopName(endId)}",
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text("Số trạm: ${line.stopIds.length} • Tuyến demo"),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BusRouteDetailPage extends StatelessWidget {
  final BusLine line;
  const BusRouteDetailPage({super.key, required this.line});

  BusStop? _stop(String id) => HcmBusDemoData.stopsById[id];

  LatLng _center() {
    if (line.polyline.isNotEmpty) return line.polyline[line.polyline.length ~/ 2];
    return const LatLng(10.7720, 106.6983);
  }

  @override
  Widget build(BuildContext context) {
    final startId = line.stopIds.first;
    final endId = line.stopIds.last;

    final startStop = _stop(startId);
    final endStop = _stop(endId);

    final markers = <Marker>[
      if (startStop != null)
        Marker(
          point: startStop.point,
          width: 56,
          height: 56,
          child: Column(
            children: [
              const Icon(Icons.trip_origin, size: 34, color: Colors.green),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
                ),
                child: const Text("Bắt đầu", style: TextStyle(fontSize: 11)),
              )
            ],
          ),
        ),
      if (endStop != null)
        Marker(
          point: endStop.point,
          width: 56,
          height: 56,
          child: Column(
            children: [
              const Icon(Icons.flag, size: 34, color: Colors.red),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
                ),
                child: const Text("Kết thúc", style: TextStyle(fontSize: 11)),
              )
            ],
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Tuyến ${line.code}"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _center(),
                initialZoom: 12.6,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "com.example.hethonggoiyxebus",
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: line.polyline,
                      strokeWidth: 6,
                      color: Colors.green,
                    ),
                  ],
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),

          // Thông tin start/end
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("• Điểm bắt đầu: ${startStop?.name ?? startId}"),
                Text("• Điểm kết thúc: ${endStop?.name ?? endId}"),
                const SizedBox(height: 8),
                Text("• Tổng số trạm: ${line.stopIds.length}"),
                const SizedBox(height: 8),

                // (Tuỳ chọn) danh sách trạm nhanh
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    itemCount: line.stopIds.length,
                    itemBuilder: (_, i) {
                      final id = line.stopIds[i];
                      final st = _stop(id);
                      return Text("${i + 1}. ${st?.name ?? id}",
                          maxLines: 1, overflow: TextOverflow.ellipsis);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
