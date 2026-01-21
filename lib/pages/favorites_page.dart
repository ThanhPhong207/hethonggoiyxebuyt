import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  static const Color _primary = Color(0xFF00BFA5); // Teal Accent

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final headerColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF37474F);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);

    // Fake data
    final favorites = [
      {
        "type": "bus",
        "code": "150",
        "route": "Chợ Lớn - Ngã 3 Tân Vạn",
        "color": Colors.green,
      },
      {
        "type": "bus",
        "code": "56",
        "route": "Chợ Lớn - ĐH Giao Thông Vận Tải",
        "color": Colors.green,
      },
      {
        "type": "bus",
        "code": "08",
        "route": "Bến xe Quận 8 - ĐH Quốc Gia",
        "color": Colors.green,
      },
      {
        "type": "metro",
        "code": "L1",
        "route": "Tuyến metro Bến Thành - Suối Tiên",
        "color": Colors.cyan,
      },
      {
        "type": "location",
        "code": "HOME",
        "route": "Nhà riêng (Quận 9)",
        "color": Colors.orange,
      },
      {
        "type": "location",
        "code": "WORK",
        "route": "Văn phòng (Quận 1)",
        "color": Colors.purple,
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Yêu thích",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: headerColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = favorites[index];
          final type = item['type'] as String;
          final isBus = type == 'bus';
          final isMetro = type == 'metro';
          final isLocation = type == 'location';

          IconData icon;
          if (isBus) icon = Icons.directions_bus_filled_rounded;
          else if (isMetro) icon = Icons.subway_rounded;
          else icon = Icons.location_on_rounded;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      // Icon / Code
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: isLocation
                              ? Icon(icon, color: item['color'] as Color, size: 26)
                              : Text(
                                  item['code'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: item['color'] as Color,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLocation ? "Địa điểm" : (isBus ? "Xe buýt" : "Metro"),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: subTextColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['route'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action
                      IconButton(
                        onPressed: () {
                          // Remove favorite logic here (demo)
                        },
                        icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
