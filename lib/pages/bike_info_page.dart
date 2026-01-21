import 'package:flutter/material.dart';

class BikeInfoPage extends StatelessWidget {
  const BikeInfoPage({super.key});

  static const Color _primary = Color(0xFFF44336); // Red

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFFFEBEE);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF37474F);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    // Fake Data
    final stations = [
      {
        "name": "Trạm Lê Lợi",
        "address": "65 Lê Lợi, Bến Nghé, Quận 1",
        "available": 12,
        "slots": 20,
        "distance": "500m"
      },
      {
        "name": "Trạm Hàm Nghi",
        "address": "Góc Hàm Nghi - Pasteur, Quận 1",
        "available": 5,
        "slots": 15,
        "distance": "1.2km"
      },
      {
        "name": "Trạm Nguyễn Huệ",
        "address": "Phố đi bộ Nguyễn Huệ, Quận 1",
        "available": 0,
        "slots": 18,
        "distance": "2.5km"
      },
      {
        "name": "Trạm Công viên 23/9",
        "address": "Khu B, Công viên 23/9, Quận 1",
        "available": 15,
        "slots": 25,
        "distance": "3.1km"
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Xe đạp công cộng",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        leading: BackButton(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner_rounded, color: textColor),
            onPressed: () {}, // Scan QR
          )
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pedal_bike_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Thuê xe dễ dàng",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "5.000đ / 30 phút",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 36,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.qr_code, size: 16),
                              label: const Text("Quét mã mở khóa"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red.shade700,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverToBoxAdapter(
              child: Text(
                "Trạm xe gần đây",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = stations[index];
                  final available = item['available'] as int;
                  final isFull = available == 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        children: [
                          // Index
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['address'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subTextColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildBadge(
                                      icon: Icons.directions_bike_rounded,
                                      text: "$available xe",
                                      color: isFull ? Colors.grey : Colors.green,
                                      bgColor: isFull ? Colors.grey.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildBadge(
                                      icon: Icons.local_parking_rounded,
                                      text: "${item['slots']} chỗ",
                                      color: Colors.blue,
                                      bgColor: Colors.blue.withOpacity(0.1),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          // Distance
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.withOpacity(0.1) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.near_me_rounded, size: 14, color: subTextColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      item['distance'] as String,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              IconButton(
                                icon: Icon(Icons.directions_outlined, color: _primary),
                                onPressed: () {},
                                style: IconButton.styleFrom(
                                  backgroundColor: _primary.withOpacity(0.1),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
                childCount: stations.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String text, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
