import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const Color _primary = Color(0xFF00BFA5); // Teal Accent

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final headerColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF37474F);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final contentColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04);

    // Fake data
    final notifications = [
      {
        "title": "Chào mừng bạn đến với BusGo!",
        "time": "Vừa xong",
        "content": "Cảm ơn bạn đã cài đặt ứng dụng. Hãy khám phá các tính năng tìm đường và tra cứu xe buýt ngay nhé.",
        "icon": Icons.celebration_rounded,
        "color": Colors.orange,
      },
      {
        "title": "Cập nhật lộ trình xe buýt 150",
        "time": "2 giờ trước",
        "content": "Tuyến xe 150 (Chợ Lớn - Ngã 3 Tân Vạn) đã thay đổi lộ trình một đoạn ngắn tại đường ABC.",
        "icon": Icons.alt_route_rounded,
        "color": Colors.blue,
      },
      {
        "title": "Khuyến mãi vé tháng",
        "time": "1 ngày trước",
        "content": "Giảm giá 50% khi đăng ký vé tháng Metro tuyến số 1 trong tháng này. Nhanh tay lên!",
        "icon": Icons.discount_rounded,
        "color": Colors.redAccent,
      },
      {
        "title": "Bảo trì hệ thống",
        "time": "3 ngày trước",
        "content": "Hệ thống máy chủ sẽ bảo trì vào lúc 0h-2h sáng mai để nâng cấp hiệu năng.",
        "icon": Icons.build_rounded,
        "color": Colors.grey,
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Thông báo",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: headerColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = notifications[index];
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
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['title'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  item['time'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['content'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: contentColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
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
