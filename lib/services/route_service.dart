import 'dart:convert';
import 'dart:math';
import 'dart:ui' show Color;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_suggestion.dart';
import 'hcm_bus_demo_data.dart';

class RouteService {
  static final _lines = HcmBusDemoData.buildLines();
  static final _stopsById = HcmBusDemoData.stopsById;

  static const LatLng hcmCenter = LatLng(10.7769, 106.7009);
  static const double _west = 106.55;
  static const double _east = 106.90;
  static const double _north = 10.92;
  static const double _south = 10.65;

  static const double _walkSpeedKmh = 5.0;
  static const double _busSpeedKmh = 18.0;
  static const double _busWaitMin = 6.0;
  static const double _stopDwellSec = 25.0;


  Future<List<RouteOption>> suggestRoutesSmart({
    String? fromText,
    LatLng? fromPoint,
    String? toText,
    LatLng? toPoint,
    int maxTransfers = 1, // 0 = 1 xe, 1 = 2 xe...
  }) async {
    final from = fromPoint ?? await geocodeHcm(fromText ?? "");
    final to = toPoint ?? await geocodeHcm(toText ?? "");

    if (from == null || to == null) {
      throw Exception("Không tìm thấy toạ độ. Hãy nhập rõ hơn (vd: 'Quận 3, TP.HCM') hoặc chọn trên bản đồ.");
    }


    if (!_isNearHcm(from) || !_isNearHcm(to)) {
      throw Exception("Điểm đi/đến đang nằm ngoài TP.HCM. Hãy nhập kèm 'TP.HCM' hoặc chọn trên bản đồ.");
    }

    final all = <RouteOption>[];

    all.addAll(_suggestDirect(from, to, relaxed: false));
    if (maxTransfers >= 1) {
      all.addAll(_suggestTransfer2Buses(from, to, relaxed: false));
    }


    final busCount = all.where((o) => o.steps.any((s) => s.type == StepType.bus)).length;
    if (busCount == 0) {
      all.addAll(_suggestDirect(from, to, relaxed: true));
      if (maxTransfers >= 1) {
        all.addAll(_suggestTransfer2Buses(from, to, relaxed: true));
      }
    }


    if (all.isEmpty) return [_buildWalkOnly(from, to)];


    all.add(_buildWalkOnly(from, to));


    final Map<String, RouteOption> unique = {};
    for (final r in all) {
      final sig = _signatureUser(r);
      final old = unique[sig];
      if (old == null || r.totalMinutes < old.totalMinutes) {
        unique[sig] = r;
      }
    }

    final deduped = unique.values.toList();


    deduped.sort((a, b) {
      final ak = _kindRank(a);
      final bk = _kindRank(b);
      if (ak != bk) return ak.compareTo(bk);

      final t = a.totalMinutes.compareTo(b.totalMinutes);
      if (t != 0) return t;

      return a.walkMeters.compareTo(b.walkMeters);
    });

    return deduped.take(10).toList();
  }


  Future<LatLng?> geocodeHcm(String query) async {
    final q = _normalizeHcmQuery(query);
    if (q.isEmpty) return null;

    final uri = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
          "?q=${Uri.encodeQueryComponent(q)}"
          "&format=json&limit=1"
          "&countrycodes=vn"
          "&bounded=1"
          "&viewbox=$_west,$_north,$_east,$_south",
    );

    try {
      final res = await http.get(uri, headers: {
        "User-Agent": "hethonggoiyxebus/1.0 (education project)",
        "Accept-Language": "vi",
      });
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as List;
      if (data.isEmpty) return null;

      final item = data.first as Map<String, dynamic>;
      final p = LatLng(double.parse(item["lat"]), double.parse(item["lon"]));


      if (!_isNearHcm(p)) return null;

      return p;
    } catch (_) {
      return null;
    }
  }

  String _normalizeHcmQuery(String s) {
    final t = s.trim();
    if (t.isEmpty) return "";

    final lower = t.toLowerCase();


    final m = RegExp(r'^(q|quận)\s*([0-9]{1,2})$').firstMatch(lower);
    if (m != null) {
      return "Quận ${m.group(2)}, TP.HCM";
    }


    final hasHcm = lower.contains("tp.hcm") ||
        lower.contains("tphcm") ||
        lower.contains("hồ chí minh") ||
        lower.contains("ho chi minh") ||
        lower.contains("hcm");


    return hasHcm ? t : "$t, TP.HCM";
  }

  bool _isNearHcm(LatLng p) {

    return _distanceMeters(p, hcmCenter) <= 80000;
  }


  int _kindRank(RouteOption o) {
    final busCount = o.steps.where((s) => s.type == StepType.bus).length;
    if (busCount == 0) return 9;
    if (busCount == 1) return 0;
    if (busCount == 2) return 1;
    return 2;
  }

  String _signatureUser(RouteOption o) {
    final buses = o.steps
        .where((s) => s.type == StepType.bus)
        .map((s) => s.busCode ?? "")
        .where((s) => s.isNotEmpty)
        .toList();
    if (buses.isEmpty) return "WALK";
    if (buses.length == 1) return "D:${buses[0]}";
    return "T:${buses[0]}->${buses[1]}:${o.transferPoint?.toString() ?? ""}";
  }


  List<RouteOption> _suggestDirect(LatLng from, LatLng to, {bool relaxed = false}) {
    final out = <RouteOption>[];
    final seen = <String>{};

    for (final line in _lines) {
      final board = _nearestStopOnLine(line, from, relaxed: relaxed);
      final alight = _nearestStopOnLine(line, to, relaxed: relaxed);
      if (board == null || alight == null) continue;

      final bi = line.stopIds.indexOf(board.id);
      final ai = line.stopIds.indexOf(alight.id);
      if (bi < 0 || ai < 0 || bi >= ai) continue;

      final sig = "D|${line.code}|${board.id}|${alight.id}";
      if (!seen.add(sig)) continue;

      final busSeg = _slicePolylineByStops(line, board.id, alight.id);
      final busMeters = _polylineLength(busSeg);

      final walk1m = _distanceMeters(from, board.point);
      final walk2m = _distanceMeters(alight.point, to);

      final walk1min = _walkMinutes(walk1m);
      final walk2min = _walkMinutes(walk2m);

      final stopCount = (ai - bi + 1);
      final dwellMin = (stopCount * _stopDwellSec) / 60.0;

      final busMin = _busMinutes(busMeters) + _busWaitMin + dwellMin;

      final totalM = walk1m + busMeters + walk2m;
      final totalMin = walk1min + busMin + walk2min;

      out.add(
        RouteOption(
          id: "direct-${line.code}-${board.id}-${alight.id}",
          title: "Xe ${line.code} • đi thẳng",
          totalMeters: totalM,
          totalMinutes: totalMin,
          totalPriceVnd: 7000,
          walkMeters: walk1m + walk2m,
          steps: [
            RouteStep(type: StepType.walk, title: "Đi bộ đến trạm: ${board.name}", distanceMeters: walk1m, durationMinutes: walk1min),
            RouteStep(type: StepType.bus, title: "Đi tuyến ${line.code} (${board.name} → ${alight.name})", distanceMeters: busMeters, durationMinutes: busMin, busCode: line.code),
            RouteStep(type: StepType.walk, title: "Đi bộ đến đích", distanceMeters: walk2m, durationMinutes: walk2min),
          ],
          segments: [
            RoutePolylineSegment(points: [from, board.point], color: const Color(0xFF9E9E9E), label: "WALK", isBus: false),
            RoutePolylineSegment(points: busSeg, color: const Color(0xFF1976D2), label: "BUS ${line.code}", isBus: true),
            RoutePolylineSegment(points: [alight.point, to], color: const Color(0xFF9E9E9E), label: "WALK", isBus: false),
          ],
          highlights: [from, board.point, alight.point, to],
        ),
      );
    }


    out.removeWhere((o) {
      if (o.totalMeters < 2000) return false;
      return o.totalMinutes > _walkMinutes(o.totalMeters) * 1.35;
    });

    out.sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
    return out.take(8).toList();
  }


  List<RouteOption> _suggestTransfer2Buses(LatLng from, LatLng to, {bool relaxed = false}) {
    final out = <RouteOption>[];
    final seen = <String>{};

    final startLines = _lines.where((l) => _nearestStopOnLine(l, from, relaxed: relaxed) != null).toList();
    final endLines = _lines.where((l) => _nearestStopOnLine(l, to, relaxed: relaxed) != null).toList();

    for (final a in startLines) {
      final board = _nearestStopOnLine(a, from, relaxed: relaxed);
      if (board == null) continue;

      for (final b in endLines) {
        if (a.code == b.code) continue;

        final alight = _nearestStopOnLine(b, to, relaxed: relaxed);
        if (alight == null) continue;

        final common = _findCommonStops(a, b);
        if (common.isEmpty) continue;

        final transferId = common.first;
        final tStop = _stopsById[transferId]!;
        final bi = a.stopIds.indexOf(board.id);
        final tiA = a.stopIds.indexOf(transferId);
        final tiB = b.stopIds.indexOf(transferId);
        final ai = b.stopIds.indexOf(alight.id);
        if (bi < 0 || tiA < 0 || tiB < 0 || ai < 0) continue;
        if (bi >= tiA) continue;
        if (tiB >= ai) continue;

        final sig = "T|${a.code}|${b.code}|${board.id}|$transferId|${alight.id}";
        if (!seen.add(sig)) continue;

        final busSeg1 = _slicePolylineByStops(a, board.id, transferId);
        final busSeg2 = _slicePolylineByStops(b, transferId, alight.id);

        final bus1m = _polylineLength(busSeg1);
        final bus2m = _polylineLength(busSeg2);

        final walk1m = _distanceMeters(from, board.point);
        final walk2m = _distanceMeters(alight.point, to);

        final walk1min = _walkMinutes(walk1m);
        final walk2min = _walkMinutes(walk2m);

        final busMin =
            _busMinutes(bus1m) + _busMinutes(bus2m) + (_busWaitMin * 2) + 4.0; // + thời gian đổi tuyến

        final totalM = walk1m + bus1m + bus2m + walk2m;
        final totalMin = walk1min + busMin + walk2min;

        out.add(
          RouteOption(
            id: "transfer-${a.code}-${b.code}-${board.id}-$transferId-${alight.id}",
            title: "Xe ${a.code} → ${b.code} • đổi tại ${tStop.name}",
            totalMeters: totalM,
            totalMinutes: totalMin,
            totalPriceVnd: 16000,
            walkMeters: walk1m + walk2m,
            steps: [
              RouteStep(type: StepType.walk, title: "Đi bộ đến trạm: ${board.name}", distanceMeters: walk1m, durationMinutes: walk1min),
              RouteStep(type: StepType.bus, title: "Đi tuyến ${a.code} (${board.name} → ${tStop.name})", distanceMeters: bus1m, durationMinutes: _busMinutes(bus1m) + _busWaitMin, busCode: a.code),
              RouteStep(type: StepType.transfer, title: "Đổi tuyến tại ${tStop.name}", distanceMeters: 0, durationMinutes: 4.0),
              RouteStep(type: StepType.bus, title: "Đi tuyến ${b.code} (${tStop.name} → ${alight.name})", distanceMeters: bus2m, durationMinutes: _busMinutes(bus2m) + _busWaitMin, busCode: b.code),
              RouteStep(type: StepType.walk, title: "Đi bộ đến đích", distanceMeters: walk2m, durationMinutes: walk2min),
            ],
            segments: [
              RoutePolylineSegment(points: [from, board.point], color: const Color(0xFF9E9E9E), label: "WALK", isBus: false),
              RoutePolylineSegment(points: busSeg1, color: const Color(0xFF1976D2), label: "BUS ${a.code}", isBus: true),
              RoutePolylineSegment(points: busSeg2, color: const Color(0xFFD32F2F), label: "BUS ${b.code}", isBus: true),
              RoutePolylineSegment(points: [alight.point, to], color: const Color(0xFF9E9E9E), label: "WALK", isBus: false),
            ],
            highlights: [from, board.point, tStop.point, alight.point, to],
            transferPoint: tStop.point,
          ),
        );
      }
    }

    out.removeWhere((o) {
      if (o.totalMeters < 3000) return false;
      return o.totalMinutes > _walkMinutes(o.totalMeters) * 1.45;
    });

    out.sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
    return out.take(8).toList();
  }


  BusStop? _nearestStopOnLine(BusLine line, LatLng p, {bool relaxed = false}) {
    const maxCatchMeters = 6000.0;
    BusStop? best;
    double bestD = double.infinity;

    for (final id in line.stopIds) {
      final s = _stopsById[id];
      if (s == null) continue;
      final d = _distanceMeters(p, s.point);
      if (d < bestD) {
        bestD = d;
        best = s;
      }
    }
    if (best == null) return null;
    if (relaxed) return best;
    if (bestD > maxCatchMeters) return null;
    return best;
  }

  List<String> _findCommonStops(BusLine a, BusLine b) {
    final setB = b.stopIds.toSet();
    final common = a.stopIds.where(setB.contains).toList();
    final preferred = common.where((id) => id.startsWith("X_")).toList();
    return preferred.isNotEmpty ? preferred : common;
  }

  List<LatLng> _slicePolylineByStops(BusLine line, String fromStopId, String toStopId) {
    final iFrom = line.stopIds.indexOf(fromStopId);
    final iTo = line.stopIds.indexOf(toStopId);
    if (iFrom < 0 || iTo < 0) return [line.polyline.first, line.polyline.last];

    final pFrom = line.stopPolylineIndex[iFrom];
    final pTo = line.stopPolylineIndex[iTo];
    final a = min(pFrom, pTo);
    final b = max(pFrom, pTo);
    return line.polyline.sublist(a, b + 1);
  }

  RouteOption _buildWalkOnly(LatLng from, LatLng to) {
    final meters = _distanceMeters(from, to);
    final minutes = _walkMinutes(meters);
    return RouteOption(
      id: "walk",
      title: "Đi bộ",
      totalMeters: meters,
      totalMinutes: minutes,
      totalPriceVnd: 0,
      walkMeters: meters,
      steps: [
        RouteStep(type: StepType.walk, title: "Đi bộ đến đích", distanceMeters: meters, durationMinutes: minutes),
      ],
      segments: [
        RoutePolylineSegment(points: [from, to], color: const Color(0xFF9E9E9E), label: "WALK", isBus: false),
      ],
      highlights: [from, to],
    );
  }

  double _walkMinutes(double meters) => ((meters / 1000.0) / _walkSpeedKmh) * 60.0;
  double _busMinutes(double meters) => ((meters / 1000.0) / _busSpeedKmh) * 60.0;

  double _polylineLength(List<LatLng> pts) {
    double sum = 0;
    for (int i = 0; i < pts.length - 1; i++) {
      sum += _distanceMeters(pts[i], pts[i + 1]);
    }
    return sum;
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLng = _deg2rad(b.longitude - a.longitude);
    final lat1 = _deg2rad(a.latitude);
    final lat2 = _deg2rad(b.latitude);

    final h = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * R * asin(min(1.0, sqrt(h)));
  }

  double _deg2rad(double d) => d * pi / 180.0;
}
