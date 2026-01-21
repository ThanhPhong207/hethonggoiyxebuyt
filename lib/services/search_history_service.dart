import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryItem {
  final String fromText;
  final String toText;
  final DateTime time;

  SearchHistoryItem({
    required this.fromText,
    required this.toText,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    "fromText": fromText,
    "toText": toText,
    "time": time.toIso8601String(),
  };

  static SearchHistoryItem fromJson(Map<String, dynamic> j) => SearchHistoryItem(
    fromText: (j["fromText"] ?? "") as String,
    toText: (j["toText"] ?? "") as String,
    time: DateTime.tryParse((j["time"] ?? "") as String) ?? DateTime.now(),
  );
}

class SearchHistoryService {
  static const _key = "route_search_history_v1";
  static const int _maxItems = 30;

  Future<List<SearchHistoryItem>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final arr = jsonDecode(raw) as List;
      return arr.map((e) => SearchHistoryItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(SearchHistoryItem item) async {
    final list = await load();


    if (list.isNotEmpty) {
      final top = list.first;
      if (top.fromText == item.fromText && top.toText == item.toText) return;
    }

    list.insert(0, item);
    if (list.length > _maxItems) {
      list.removeRange(_maxItems, list.length);
    }

    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}
