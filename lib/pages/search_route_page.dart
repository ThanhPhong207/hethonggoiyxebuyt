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

  // Colors
  static const Color _primary = Color(0xFF00BFA5);
  static const Color _secondary = Color(0xFF1DE9B6);

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
      return _pill("Đi bộ", Colors.grey.shade600, icon: Icons.directions_walk_rounded);
    }
    List<Widget> children = [];
    if (codes.isNotEmpty) {
       children.add(_pill(codes[0], const Color(0xFF2E7D32)));
    }
    if (codes.length > 1) {
       children.add(const SizedBox(width: 6));
       children.add(const Icon(Icons.arrow_right_alt_rounded, size: 16, color: Colors.grey));
       children.add(const SizedBox(width: 6));
       children.add(_pill(codes[1], const Color(0xFF1565C0)));
    }
    if (codes.length > 2) {
       children.add(const SizedBox(width: 6));
       children.add(_pill("+${codes.length - 2}", Colors.grey.shade700));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _pill(String text, Color bg, {IconData icon = Icons.directions_bus_filled_rounded}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.1),
        border: Border.all(color: bg.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: bg),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: bg, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF37474F);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final inputFillColor = isDark ? const Color(0xFF374151) : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Tìm tuyến xe buýt",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        leading: BackButton(color: textColor),
        actions: [
          IconButton(
            onPressed: _openHistory,
            icon: Icon(Icons.history_rounded, color: textColor),
            tooltip: "Lịch sử tìm kiếm",
          ),
        ],
      ),
      body: Column(
        children: [
          // Input Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icons column
                    Column(
                      children: [
                        const Icon(Icons.my_location_rounded, color: _primary, size: 22),
                        Container(
                          height: 30,
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(1),
                          ),
                          child: const Flex(
                            direction: Axis.vertical,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               SizedBox(height: 2),
                               // Dotted effect simulation could go here
                            ],
                          ),
                        ),
                        const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 22),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Inputs Column
                    Expanded(
                      child: Column(
                        children: [
                          // From Input
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: inputFillColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _useCurrentLocation
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            _fromLabel,
                                            style: TextStyle(color: _primary, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      : TextField(
                                          controller: _fromCtrl,
                                          style: TextStyle(color: textColor),
                                          decoration: InputDecoration(
                                            hintText: "Đi từ...",
                                            hintStyle: TextStyle(color: subTextColor),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                          ),
                                        ),
                                ),
                                if (_useCurrentLocation)
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        _useCurrentLocation = false;
                                        _fromCtrl.clear();
                                      });
                                    },
                                  )
                                else 
                                  IconButton(
                                    icon: const Icon(Icons.my_location_rounded, size: 18, color: _primary),
                                    onPressed: _initLocation,
                                    tooltip: "Vị trí hiện tại",
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // To Input
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: inputFillColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _toCtrl,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: "Đến...",
                                hintStyle: TextStyle(color: subTextColor),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.map_rounded, color: Colors.grey),
                                  onPressed: _pickToOnMap,
                                  tooltip: "Chọn trên bản đồ",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Swap Button
                    IconButton(
                      onPressed: _swapFromTo,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF374151) : Colors.grey.shade200,
                        shape: const CircleBorder(),
                      ),
                      icon: Icon(Icons.swap_vert_rounded, color: _primary),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                
                // Options Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12),
                         decoration: BoxDecoration(
                           color: inputFillColor,
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: DropdownButtonHideUnderline(
                           child: DropdownButton<int>(
                             value: _maxBuses,
                             isExpanded: true,
                             dropdownColor: cardColor,
                             icon: Icon(Icons.keyboard_arrow_down_rounded, color: subTextColor),
                             style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                             items: const [1, 2, 3, 4]
                                 .map((v) => DropdownMenuItem(
                                       value: v,
                                       child: Text("Tối đa $v chuyến", style: TextStyle(fontSize: 13)),
                                     ))
                                 .toList(),
                             onChanged: (v) => setState(() => _maxBuses = v ?? 2),
                           ),
                         ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_primary, _secondary]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _search,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _loading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.search_rounded, color: Colors.white),
                          label: Text(
                            _loading ? "Đang tìm..." : "Tìm tuyến",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _options.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _options.length,
                    itemBuilder: (context, i) {
                      final o = _options[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => RouteMapPage(option: o)),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          o.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: textColor
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        "${o.totalPriceVnd}đ",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: _primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _routeBadges(o),
                                  const SizedBox(height: 16),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _infoItem(Icons.directions_walk_rounded, _fmtDistance(o.walkMeters), subTextColor),
                                      const SizedBox(width: 16),
                                      _infoItem(Icons.route_rounded, _fmtDistance(o.totalMeters), subTextColor),
                                      const SizedBox(width: 16),
                                      _infoItem(Icons.timer_rounded, "${o.totalMinutes.toStringAsFixed(0)} phút", subTextColor),
                                    ],
                                  )
                                ],
                              ),
                            ),
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

  Widget _infoItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_rounded, size: 80, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            "Nhập điểm đi/đến rồi bấm “Tìm tuyến”",
            style: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
