import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_suggestion.dart';
import '../services/route_service.dart';
import '../services/search_history_service.dart';
import 'history_page.dart';
import 'pick_location_map_page.dart';
import 'route_map_page.dart';

class SearchRoutePage extends StatefulWidget {
  const SearchRoutePage({super.key});

  @override
  State<SearchRoutePage> createState() => _SearchRoutePageState();
}

class _SearchRoutePageState extends State<SearchRoutePage> {
  final _toCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();

  final RouteService _service = RouteService();

  bool _loading = false;
  List<RouteOption> _options = [];


  bool _useCurrentLocation = true;
  Position? _currentPos;
  String _fromLabel = "[Vị trí hiện tại]";


  LatLng? _toPicked;
  String _toLabel = "";


  int _maxBuses = 2;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _toCtrl.dispose();
    _fromCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() {
          _useCurrentLocation = false;
          _fromLabel = "";
        });
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() {
          _useCurrentLocation = false;
          _fromLabel = "";
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPos = pos;
        _useCurrentLocation = true;
        _fromLabel = "[Vị trí hiện tại]";
      });
    } catch (_) {
      setState(() {
        _useCurrentLocation = false;
        _fromLabel = "";
      });
    }
  }

  int _maxTransfers() => (_maxBuses - 1).clamp(0, 3);

  String _fmtDistance(double meters) =>
      meters >= 1000 ? "${(meters / 1000).toStringAsFixed(1)} km" : "${meters.toStringAsFixed(0)} m";

  Future<void> _pickToOnMap() async {
    final init = _toPicked ??
        (_currentPos != null
            ? LatLng(_currentPos!.latitude, _currentPos!.longitude)
            : const LatLng(10.7720, 106.6983));

    final result = await Navigator.push<PickLocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => PickLocationMapPage(
          initialCenter: init,
          title: "Chọn điểm đến trên bản đồ",
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _toPicked = result.point;
      _toLabel = result.displayName;
      final short = result.displayName.split(',').first.trim();
      _toCtrl.text = short.isEmpty ? result.displayName : short;
    });
  }

  void _swapFromTo() {
    if (_useCurrentLocation) {
      setState(() {
        _useCurrentLocation = false;


        _fromCtrl.text = _toCtrl.text;
        _fromLabel = _fromCtrl.text;


        _toCtrl.text = "Vị trí hiện tại";
        _toPicked = _currentPos == null ? null : LatLng(_currentPos!.latitude, _currentPos!.longitude);
        _toLabel = "[Vị trí hiện tại]";
      });
    } else {
      final tmp = _fromCtrl.text;
      _fromCtrl.text = _toCtrl.text;
      _toCtrl.text = tmp;


      final tmpPicked = _toPicked;
      _toPicked = null;
      _toLabel = "";
      setState(() {});
    }
  }


  Future<void> _openHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoryPage(
          onPick: (from, to) {

            final f = from.trim();
            if (f.isEmpty ||
                f == "[Vị trí hiện tại]" ||
                f.toLowerCase() == "vị trí hiện tại" ||
                f.toLowerCase() == "vi tri hien tai") {
              setState(() {
                _useCurrentLocation = true;
                _fromLabel = "[Vị trí hiện tại]";
                _fromCtrl.clear();
              });

              if (_currentPos == null) {
                _initLocation();
              }
            } else {
              setState(() {
                _useCurrentLocation = false;
                _fromCtrl.text = f;
                _fromLabel = f;
              });
            }


            final t = to.trim();
            setState(() {
              _toCtrl.text = t;
              _toPicked = null;
              _toLabel = "";
            });
          },
        ),
      ),
    );
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _options = [];
    });

    try {

      LatLng? fromPoint;
      String? fromText;

      if (_useCurrentLocation) {
        if (_currentPos == null) {
          await _initLocation();
        }
        if (_currentPos == null) throw Exception("Không lấy được vị trí hiện tại.");
        fromPoint = LatLng(_currentPos!.latitude, _currentPos!.longitude);
      } else {
        fromText = _fromCtrl.text.trim();
        if (fromText.isEmpty) throw Exception("Vui lòng nhập điểm xuất phát.");
      }

      // TO
      final toText = _toCtrl.text.trim();
      if (toText.isEmpty && _toPicked == null) throw Exception("Vui lòng nhập hoặc chọn điểm đến.");

      final res = await _service.suggestRoutesSmart(
        fromText: fromText,
        fromPoint: fromPoint,
        toText: toText.isEmpty ? null : toText,
        toPoint: _toPicked,
        maxTransfers: _maxTransfers(),
      );


      if (res.isNotEmpty) {
        final fromHistoryText = _useCurrentLocation ? "[Vị trí hiện tại]" : (fromText ?? "");
        final toHistoryText = toText.isNotEmpty
            ? toText
            : (_toLabel.isNotEmpty ? _toLabel : "[Điểm đã chọn trên bản đồ]");

        await SearchHistoryService().add(
          SearchHistoryItem(
            fromText: fromHistoryText,
            toText: toHistoryText,
            time: DateTime.now(),
          ),
        );
      }

      if (!mounted) return;
      setState(() => _options = res);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _routeBadges(RouteOption o) {
    final codes = o.steps
        .where((s) => s.type == StepType.bus && (s.busCode ?? "").isNotEmpty)
        .map((s) => s.busCode!)
        .toList();

    if (codes.isEmpty) {
      return _pill("Walk", const Color(0xFF9E9E9E), icon: Icons.directions_walk);
    }
    if (codes.length == 1) {
      return _pill(codes.first, const Color(0xFF2E7D32));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pill(codes[0], const Color(0xFF1976D2)),
        const SizedBox(width: 6),
        _pill(codes[1], const Color(0xFFD32F2F)),
        if (codes.length > 2) ...[
          const SizedBox(width: 6),
          _pill("+${codes.length - 2}", const Color(0xFF616161), icon: Icons.more_horiz),
        ]
      ],
    );
  }

  Widget _pill(String text, Color bg, {IconData icon = Icons.directions_bus}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0E7A4F);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tìm tuyến xe buýt"),
        actions: [
          // ✅ Lịch sử
          IconButton(
            onPressed: _openHistory,
            icon: const Icon(Icons.history),
            tooltip: "Lịch sử tìm kiếm",
          ),
          // Refresh GPS
          IconButton(
            onPressed: _initLocation,
            icon: const Icon(Icons.refresh),
            tooltip: "Lấy lại vị trí",
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Form (không overflow)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // FROM row
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _useCurrentLocation
                          ? Text(
                        "Đi từ   $_fromLabel",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      )
                          : TextField(
                        controller: _fromCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Đi từ (nhập địa điểm)",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _useCurrentLocation = !_useCurrentLocation;
                          if (_useCurrentLocation) {
                            _fromCtrl.clear();
                            _fromLabel = "[Vị trí hiện tại]";
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _useCurrentLocation ? "Nhập tay" : "GPS",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.white.withOpacity(0.25), height: 16),
                // TO row
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _toCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Đến (nhập hoặc chọn trên map)",
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          suffix: InkWell(
                            onTap: _pickToOnMap,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(Icons.map_outlined, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Flexible(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _maxBuses,
                        isExpanded: true,
                        items: const [1, 2, 3, 4]
                            .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text("Đi tối đa $v chuyến"),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _maxBuses = v ?? 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _swapFromTo,
                  icon: const Icon(Icons.swap_vert),
                  tooltip: "Đổi chỗ Đi từ / Đến",
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 5,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _search,
                    icon: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.alt_route),
                    label: Text(_loading ? "Đang tìm..." : "Tìm tuyến"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),


          Expanded(
            child: _options.isEmpty
                ? const Center(child: Text("Nhập điểm đi/đến rồi bấm “Tìm tuyến”."))
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: _options.length,
              itemBuilder: (context, i) {
                final o = _options[i];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10,
                        offset: Offset(0, 3),
                        color: Color(0x22000000),
                      )
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RouteMapPage(option: o)),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _routeBadges(o),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                o.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 14,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.directions_walk, size: 16, color: Color(0xFF616161)),
                                      const SizedBox(width: 6),
                                      Text(
                                        _fmtDistance(o.walkMeters),
                                        style: const TextStyle(color: Color(0xFF616161)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.route, size: 16, color: Color(0xFF616161)),
                                      const SizedBox(width: 6),
                                      Text(
                                        _fmtDistance(o.totalMeters),
                                        style: const TextStyle(color: Color(0xFF616161)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 14,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.schedule, size: 16, color: Color(0xFF616161)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${o.totalMinutes.toStringAsFixed(0)} phút",
                                        style: const TextStyle(color: Color(0xFF616161)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.payments_outlined, size: 16, color: Color(0xFF616161)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${o.totalPriceVnd}đ",
                                        style: const TextStyle(color: Color(0xFF616161)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.map_outlined),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
