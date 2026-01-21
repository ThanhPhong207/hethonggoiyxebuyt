import 'package:flutter/material.dart';

class WaterbusInfoPage extends StatelessWidget {
  const WaterbusInfoPage({super.key});

  static const Color _primary = Color(0xFFFF9800); // Orange

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFFFF3E0);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF37474F);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    // Fake Data
    final stations = [
      {
        "name": "Bến Bạch Đằng",
        "address": "10B Tôn Đức Thắng, Q.1",
        "next": "15:30",
        "status": "Hoạt động",
      },
      {
        "name": "Bến Bình An",
        "address": "Đường số 21, P. Bình An, Q.2",
        "next": "15:45",
        "status": "Hoạt động",
      },
      {
        "name": "Bến Thanh Đa",
        "address": "Lô A, Cư xá Thanh Đa, Q. Bình Thạnh",
        "next": "16:00",
        "status": "Hoạt động",
      },
      {
        "name": "Bến Hiệp Bình Chánh",
        "address": "Đường số 10, Hiệp Bình Chánh, Thủ Đức",
        "next": "16:15",
        "status": "Hoạt động",
      },
      {
        "name": "Bến Linh Đông",
        "address": "363 Nguyễn Văn Bá, Linh Đông, Thủ Đức",
        "next": "16:30",
        "status": "Tạm dừng",
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Waterbus Sài Gòn",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        leading: BackButton(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.map_outlined, color: textColor),
            onPressed: () {}, // Future Map View
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
                    colors: [Colors.orange.shade400, Colors.orange.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.directions_boat_filled_rounded, color: Colors.white, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tuyến buýt đường sông số 1",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Lộ trình: Bạch Đằng ↔ Linh Đông",
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = stations[index];
                  final isInactive = item['status'] == "Tạm dừng";

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
                          // Station Index / Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isInactive 
                                  ? Colors.grey.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.anchor_rounded,
                              color: isInactive ? Colors.grey : _primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info
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
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.schedule_rounded, 
                                      size: 14, 
                                      color: isInactive ? Colors.grey : Colors.green
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isInactive ? "Tạm ngưng" : "Tiếp theo: ${item['next']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isInactive ? Colors.grey : Colors.green,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          // Action Arrow
                          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
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
}
