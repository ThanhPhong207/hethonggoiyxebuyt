import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class AdminBusDataPage extends StatefulWidget {
  const AdminBusDataPage({super.key});

  @override
  State<AdminBusDataPage> createState() => _AdminBusDataPageState();
}

class _AdminBusDataPageState extends State<AdminBusDataPage> {
  final SupabaseService _service = SupabaseService();
  bool _loading = false;
  List<Map<String, dynamic>> _routes = [];

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getBusRoutes();
      if (mounted) {
        setState(() {
          _routes = data;
          // Sort by ID usually, or route_code
          _routes.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteRoute(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa tuyến này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await _service.deleteBusRoute(id);
      await _fetchRoutes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa tuyến thành công!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showEditor({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    final codeCtrl = TextEditingController(text: item?['route_code'] ?? '');
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    final priceCtrl = TextEditingController(text: item != null ? item['ticket_price'].toString() : '7000');
    final timeCtrl = TextEditingController(text: item?['operation_time'] ?? '05:00 - 21:00');
    final freqCtrl = TextEditingController(text: item?['frequency'] ?? '10-15 phút');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? "Sửa tuyến xe" : "Thêm tuyến xe mới"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Mã số tuyến (vd: 01)')),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên tuyến (vd: BX Gia Lâm - Yên Nghĩa)')),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Giá vé'), keyboardType: TextInputType.number),
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Thời gian hđ (vd: 05:00 - 21:00)')),
              TextField(controller: freqCtrl, decoration: const InputDecoration(labelText: 'Tần suất (vd: 10-15 phút)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final code = codeCtrl.text.trim();
              final name = nameCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text) ?? 7000;
              final time = timeCtrl.text.trim();
              final freq = freqCtrl.text.trim();

              if (code.isEmpty || name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Mã và Tên tuyến')));
                return;
              }

              Navigator.pop(ctx);
              setState(() => _loading = true);

              try {
                final data = {
                  'route_code': code,
                  'name': name,
                  'ticket_price': price,
                  'operation_time': time,
                  'frequency': freq,
                };

                if (isEdit) {
                  await _service.updateBusRoute(item['id'], data);
                } else {
                  await _service.insertBusRoute(data);
                }
                await _fetchRoutes();
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Cập nhật thành công!' : 'Thêm mới thành công!')));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
            child: Text(isEdit ? "Lưu" : "Thêm mới"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Tuyến xe (Admin)"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(),
        child: const Icon(Icons.add),
      ),
      body: _loading && _routes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _routes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus_outlined, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text("Chưa có dữ liệu tuyến nào", style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _showEditor, child: const Text("Thêm ngay"))
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _routes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final r = _routes[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade50,
                          child: Text(
                            r['route_code']?.toString() ?? '?',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                        ),
                        title: Text(r['name'] ?? 'Không tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${r['operation_time']} • ${r['ticket_price']}đ"),
                        trailing: PopupMenuButton(
                          onSelected: (v) {
                            if (v == 'edit') {
                              _showEditor(item: r);
                            } else if (v == 'delete') {
                              _deleteRoute(r['id']);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Sửa")])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("Xóa", style: TextStyle(color: Colors.red))])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
