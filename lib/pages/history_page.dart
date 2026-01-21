import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final void Function(String fromText, String toText)? onPick;
  const HistoryPage({super.key, this.onPick});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _primary = Color(0xFF00BFA5); // Teal Accent

  // Fake Search Data
  List<Map<String, dynamic>> _searchHistory = [
    {
      "from": "Chợ Bến Thành",
      "to": "Đại học Quốc gia TP.HCM",
      "time": "10:30 • Hôm nay"
    },
    {
      "from": "Sân bay Tân Sơn Nhất",
      "to": "Landmark 81",
      "time": "18:15 • Hôm qua"
    },
    {
      "from": "Bến xe Miền Đông Mới",
      "to": "Khu công nghệ cao",
      "time": "08:00 • 20/05/2024"
    },
    {
      "from": "Nhà hát Thành phố",
      "to": "Bảo tàng Mỹ thuật",
      "time": "14:45 • 19/05/2024"
    },
    {
      "from": "Phố đi bộ Nguyễn Huệ",
      "to": "Thảo Cầm Viên",
      "time": "09:20 • 18/05/2024"
    },
  ];

  // Fake Booking/Trip Data
  final List<Map<String, dynamic>> _tripHistory = [
    {
      "code": "BUS-150-883",
      "route": "Tuyến 150: Chợ Lớn - Tân Vạn",
      "date": "10:30 • Hôm nay",
      "price": "7.000đ",
      "status": "Hoàn thành",
      "statusColor": Colors.green,
    },
    {
      "code": "METRO-L1-002",
      "route": "Metro: Bến Thành - Suối Tiên",
      "date": "07:15 • Hôm qua",
      "price": "12.000đ",
      "status": "Hoàn thành",
      "statusColor": Colors.green,
    },
    {
      "code": "WBUS-SG-01",
      "route": "Waterbus: Bạch Đằng - Linh Đông",
      "date": "16:00 • 15/05/2024",
      "price": "15.000đ",
      "status": "Đã hủy",
      "statusColor": Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã xóa lịch sử tìm kiếm")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final headerColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final unselectedLabelColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Lịch sử hoạt động",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: headerColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide back button if in tab
        leading: widget.onPick != null
            ? IconButton(
                icon: Icon(Icons.close, color: textColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primary,
          unselectedLabelColor: unselectedLabelColor,
          indicatorColor: _primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: "Tìm kiếm"),
            Tab(text: "Vé đã đặt"),
          ],
        ),
        actions: [
          if (_tabController.index == 0 && _searchHistory.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: isDark ? Colors.grey.shade400 : Colors.black54),
              onPressed: _clearSearchHistory,
              tooltip: "Xóa lịch sử",
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchList(),
          _buildTripList(),
        ],
      ),
    );
  }

  Widget _buildSearchList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);
    final textColor = isDark ? Colors.white : Colors.black87; 
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    
    if (_searchHistory.isEmpty) {
      return _buildEmptyState("Chưa có lịch sử tìm kiếm", Icons.history_rounded);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchHistory.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = _searchHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.manage_search_rounded, color: Colors.blue),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    "${item['from']}",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 16, color: subTextColor),
                ),
                Expanded(
                  child: Text(
                    "${item['to']}",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                item['time'],
                style: TextStyle(color: subTextColor, fontSize: 12),
              ),
            ),
            onTap: () {
              if (widget.onPick != null) {
                widget.onPick!(item['from'], item['to']);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildTripList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);
    final textColor = isDark ? Colors.white : const Color(0xFF37474F);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tripHistory.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = _tripHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['code'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey.shade200 : Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (item['statusColor'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item['statusColor'] as Color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.teal.shade900.withOpacity(0.3) : Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_bus_filled_rounded, color: _primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['route'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['date'],
                          style: TextStyle(
                            fontSize: 13,
                            color: subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tổng tiền", style: TextStyle(color: subTextColor)),
                  Text(
                    item['price'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    // Note: This method also needs to adapt if it used context for colors, 
    // but here it uses local vars or hardcoded greys that look okayish on dark, 
    // but better to make them adaptive.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final textColor = isDark ? Colors.grey.shade500 : Colors.grey.shade500;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: iconColor),
          const SizedBox(height: 16),
          Text(
            msg,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
