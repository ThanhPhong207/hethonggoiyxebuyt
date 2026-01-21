import 'package:flutter/material.dart';
import '../services/search_history_service.dart';

class HistoryPage extends StatefulWidget {
  final void Function(String fromText, String toText)? onPick;
  const HistoryPage({super.key, this.onPick});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _svc = SearchHistoryService();
  List<SearchHistoryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _svc.load();
    if (!mounted) return;
    setState(() => _items = list);
  }

  String _fmt(DateTime t) {
    String two(int x) => x.toString().padLeft(2, "0");
    return "${two(t.hour)}:${two(t.minute)} • ${two(t.day)}/${two(t.month)}/${t.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử tìm kiếm"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await _svc.clear();
              await _load();
            },
          )
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: Text("Chưa có lịch sử."))
          : ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final it = _items[i];
          return ListTile(
            title: Text("${it.fromText}  →  ${it.toText}"),
            subtitle: Text(_fmt(it.time)),
            onTap: widget.onPick == null
                ? null
                : () {
              widget.onPick!(it.fromText, it.toText);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
