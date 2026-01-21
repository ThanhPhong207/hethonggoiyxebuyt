import 'dart:math';
import 'package:latlong2/latlong.dart';

class BusStop {
  final String id;
  final String name;
  final LatLng point;

  const BusStop(this.id, this.name, this.point);
}

class BusLine {
  final String code;
  final String name;

  final List<LatLng> polyline;
  final List<String> stopIds;
  final List<int> stopPolylineIndex;

  const BusLine({
    required this.code,
    required this.name,
    required this.polyline,
    required this.stopIds,
    required this.stopPolylineIndex,
  });
}

class HcmBusDemoData {
  // =========================
  // HUB theo quận/huyện (demo)
  // =========================
  static final Map<String, BusStop> stopsById = {
    // === Interchange / Trung chuyển dùng chung (quan trọng để cắt nhau) ===
    "X_CEN": const BusStop("X_CEN", "Bến Thành (Trung tâm)", LatLng(10.7720, 106.6983)),
    "X_HX": const BusStop("X_HX", "Ngã tư Hàng Xanh", LatLng(10.8033, 106.7107)),
    "X_PN": const BusStop("X_PN", "Phú Nhuận", LatLng(10.7994, 106.6796)),
    "X_TSN": const BusStop("X_TSN", "Sân bay Tân Sơn Nhất", LatLng(10.8188, 106.6573)),
    "X_Q5": const BusStop("X_Q5", "Quận 5 (Chợ Lớn)", LatLng(10.7540, 106.6600)),
    "X_Q7": const BusStop("X_Q7", "Quận 7 (PMH)", LatLng(10.7296, 106.7210)),
    "X_TD": const BusStop("X_TD", "Thủ Đức", LatLng(10.8490, 106.7530)),
    "X_GV": const BusStop("X_GV", "Gò Vấp", LatLng(10.8387, 106.6656)),
    "X_BT": const BusStop("X_BT", "Bình Thạnh", LatLng(10.8010, 106.7090)),
    "X_BTAN": const BusStop("X_BTAN", "Bình Tân", LatLng(10.7654, 106.6096)),
    "X_TPHU": const BusStop("X_TPHU", "Tân Phú", LatLng(10.7900, 106.6280)),
    "X_TBINH": const BusStop("X_TBINH", "Tân Bình", LatLng(10.8016, 106.6527)),

    // === HUB theo quận (demo tọa độ gần trung tâm quận) ===
    "H_Q1": const BusStop("H_Q1", "Hub Quận 1", LatLng(10.7750, 106.7000)),
    "H_Q2": const BusStop("H_Q2", "Hub Quận 2 (Thảo Điền)", LatLng(10.8039, 106.7315)),
    "H_Q3": const BusStop("H_Q3", "Hub Quận 3", LatLng(10.7840, 106.6840)),
    "H_Q4": const BusStop("H_Q4", "Hub Quận 4", LatLng(10.7570, 106.7050)),
    "H_Q5": const BusStop("H_Q5", "Hub Quận 5", LatLng(10.7540, 106.6600)),
    "H_Q6": const BusStop("H_Q6", "Hub Quận 6", LatLng(10.7480, 106.6350)),
    "H_Q7": const BusStop("H_Q7", "Hub Quận 7", LatLng(10.7296, 106.7210)),
    "H_Q8": const BusStop("H_Q8", "Hub Quận 8", LatLng(10.7410, 106.6650)),
    "H_Q9": const BusStop("H_Q9", "Hub Quận 9", LatLng(10.8280, 106.8280)),
    "H_Q10": const BusStop("H_Q10", "Hub Quận 10", LatLng(10.7730, 106.6670)),
    "H_Q11": const BusStop("H_Q11", "Hub Quận 11", LatLng(10.7630, 106.6430)),
    "H_Q12": const BusStop("H_Q12", "Hub Quận 12", LatLng(10.8670, 106.6500)),

    "H_BT": const BusStop("H_BT", "Hub Bình Thạnh", LatLng(10.8010, 106.7090)),
    "H_GV": const BusStop("H_GV", "Hub Gò Vấp", LatLng(10.8387, 106.6656)),
    "H_PN": const BusStop("H_PN", "Hub Phú Nhuận", LatLng(10.7994, 106.6796)),
    "H_TB": const BusStop("H_TB", "Hub Tân Bình", LatLng(10.8016, 106.6527)),
    "H_TP": const BusStop("H_TP", "Hub Tân Phú", LatLng(10.7900, 106.6280)),
    "H_BTAN": const BusStop("H_BTAN", "Hub Bình Tân", LatLng(10.7654, 106.6096)),
    "H_TD": const BusStop("H_TD", "Hub Thủ Đức", LatLng(10.8490, 106.7530)),

    // === HUB huyện ngoại thành (demo) ===
    "H_BC": const BusStop("H_BC", "Hub Bình Chánh", LatLng(10.7447, 106.6048)),
    "H_HM": const BusStop("H_HM", "Hub Hóc Môn", LatLng(10.8840, 106.5930)),
    "H_CC": const BusStop("H_CC", "Hub Củ Chi", LatLng(11.0060, 106.5130)),
    "H_NB": const BusStop("H_NB", "Hub Nhà Bè", LatLng(10.6760, 106.7290)),
    "H_CG": const BusStop("H_CG", "Hub Cần Giờ", LatLng(10.4110, 106.9540)),
  };

  // danh sách hub để chọn điểm đầu/cuối tuyến
  static final List<BusStop> hubs = [
    // core
    stopsById["H_Q1"]!,
    stopsById["H_Q3"]!,
    stopsById["H_Q5"]!,
    stopsById["H_Q10"]!,
    stopsById["H_BT"]!,
    stopsById["H_PN"]!,
    stopsById["H_TB"]!,
    // east
    stopsById["H_Q2"]!,
    stopsById["H_Q9"]!,
    stopsById["H_TD"]!,
    // south/west
    stopsById["H_Q7"]!,
    stopsById["H_Q8"]!,
    stopsById["H_BTAN"]!,
    stopsById["H_TP"]!,
    stopsById["H_Q6"]!,
    // north
    stopsById["H_Q12"]!,
    stopsById["H_GV"]!,
    // outer
    stopsById["H_BC"]!,
    stopsById["H_HM"]!,
    stopsById["H_CC"]!,
    stopsById["H_NB"]!,
    stopsById["H_CG"]!,
  ];

  // trạm trung chuyển để tuyến giao nhau
  static final List<BusStop> interchanges = [
    stopsById["X_CEN"]!,
    stopsById["X_HX"]!,
    stopsById["X_PN"]!,
    stopsById["X_TSN"]!,
    stopsById["X_Q5"]!,
    stopsById["X_Q7"]!,
    stopsById["X_TD"]!,
    stopsById["X_GV"]!,
    stopsById["X_BT"]!,
    stopsById["X_BTAN"]!,
    stopsById["X_TPHU"]!,
    stopsById["X_TBINH"]!,
  ];

  /// Tạo 80 tuyến demo
  static List<BusLine> buildLines() {
    final rng = Random(8029);
    final lines = <BusLine>[];

    for (int i = 1; i <= 80; i++) {
      final code = i.toString().padLeft(2, "0");

      // chọn start/end hub khác nhau
      BusStop start = hubs[rng.nextInt(hubs.length)];
      BusStop end = hubs[rng.nextInt(hubs.length)];
      int guard = 0;
      while (end.id == start.id && guard++ < 20) {
        end = hubs[rng.nextInt(hubs.length)];
      }

      // bắt buộc đi qua 2 interchange (để tạo nhiều điểm giao)
      final x1 = interchanges[i % interchanges.length];
      final x2 = interchanges[(i * 3) % interchanges.length];

      // tạo polyline 3 đoạn: start -> x1 -> x2 -> end
      final p1 = _makeCurvyPath(start.point, x1.point, seed: i * 31 + 1, steps: 18);
      final p2 = _makeCurvyPath(x1.point, x2.point, seed: i * 31 + 7, steps: 18);
      final p3 = _makeCurvyPath(x2.point, end.point, seed: i * 31 + 13, steps: 18);

      final polyline = <LatLng>[
        ...p1,
        ...p2.skip(1),
        ...p3.skip(1),
      ];

      // stop theo polyline (đảm bảo có start/x1/x2/end + nhiều stop trung gian)
      final stopIds = <String>[];
      final stopPolylineIndex = <int>[];

      // start
      stopIds.add(start.id);
      stopPolylineIndex.add(0);
      stopsById.putIfAbsent(start.id, () => start);

      // mid stops trên p1
      _addMidStops(
        code: code,
        prefix: "A",
        polyline: polyline,
        startIndex: 0,
        endIndex: p1.length - 1,
        count: 3 + (i % 4), // 3-6
        stopIds: stopIds,
        stopPolylineIndex: stopPolylineIndex,
      );

      // x1
      final x1Idx = p1.length - 1;
      stopsById.putIfAbsent(x1.id, () => x1);
      stopIds.add(x1.id);
      stopPolylineIndex.add(x1Idx);

      // mid stops trên p2
      final p2Start = x1Idx;
      final p2End = x1Idx + (p2.length - 1);
      _addMidStops(
        code: code,
        prefix: "B",
        polyline: polyline,
        startIndex: p2Start,
        endIndex: p2End,
        count: 2 + ((i + 1) % 4), // 2-5
        stopIds: stopIds,
        stopPolylineIndex: stopPolylineIndex,
      );

      // x2
      final x2Idx = p2End;
      stopsById.putIfAbsent(x2.id, () => x2);
      stopIds.add(x2.id);
      stopPolylineIndex.add(x2Idx);

      // mid stops trên p3
      final p3Start = x2Idx;
      final p3End = polyline.length - 1;
      _addMidStops(
        code: code,
        prefix: "C",
        polyline: polyline,
        startIndex: p3Start,
        endIndex: p3End,
        count: 3 + ((i + 2) % 4), // 3-6
        stopIds: stopIds,
        stopPolylineIndex: stopPolylineIndex,
      );

      // end
      stopIds.add(end.id);
      stopPolylineIndex.add(polyline.length - 1);
      stopsById.putIfAbsent(end.id, () => end);

      lines.add(
        BusLine(
          code: code,
          name: "Tuyến $code (Demo TP.HCM)",
          polyline: polyline,
          stopIds: stopIds,
          stopPolylineIndex: stopPolylineIndex,
        ),
      );
    }

    return lines;
  }

  static void _addMidStops({
    required String code,
    required String prefix,
    required List<LatLng> polyline,
    required int startIndex,
    required int endIndex,
    required int count,
    required List<String> stopIds,
    required List<int> stopPolylineIndex,
  }) {
    if (endIndex <= startIndex + 2) return;
    for (int s = 1; s <= count; s++) {
      final idx = (startIndex + (s * (endIndex - startIndex) / (count + 1))).round();
      final id = "R$code-$prefix$s";
      stopsById.putIfAbsent(id, () => BusStop(id, "Trạm $code-$prefix$s", polyline[idx]));
      stopIds.add(id);
      stopPolylineIndex.add(idx);
    }
  }

  static List<LatLng> _makeCurvyPath(
      LatLng start,
      LatLng end, {
        required int seed,
        int steps = 18,
      }) {
    final rng = Random(seed);

    final mx = (start.latitude + end.latitude) / 2;
    final my = (start.longitude + end.longitude) / 2;

    final dx = end.latitude - start.latitude;
    final dy = end.longitude - start.longitude;


    final px = -dy;
    final py = dx;


    final base = 0.004 + rng.nextDouble() * 0.014;
    final sign = rng.nextBool() ? 1.0 : -1.0;

    final ctrl = LatLng(
      mx + sign * px * base,
      my + sign * py * base,
    );

    final out = <LatLng>[];
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final lat = (1 - t) * (1 - t) * start.latitude +
          2 * (1 - t) * t * ctrl.latitude +
          t * t * end.latitude;
      final lng = (1 - t) * (1 - t) * start.longitude +
          2 * (1 - t) * t * ctrl.longitude +
          t * t * end.longitude;
      out.add(LatLng(lat, lng));
    }
    return out;
  }
}
