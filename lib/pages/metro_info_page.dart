import 'package:flutter/material.dart';

class MetroInfoPage extends StatelessWidget {
  const MetroInfoPage({super.key});

  // Fix lỗi: Dùng static const hoặc final ... = const [...] để hợp lệ với const constructor
  static const List<String> stations = [
    "Bến Thành",
    "Nhà hát TP",
    "Ba Son",
    "Tân Cảng",
    "Thảo Điền",
    "An Phú",
    "Rạch Chiếc",
    "Phước Long",
    "Bình Thái",
    "Suối Tiên",
    "Bến xe Miền Đông Mới",
  ];

  // Màu gradient chủ đạo (theo style Login mới)
  static const Color _startColor = Color(0xFF00BFA5); // Teal Accent
  static const Color _endColor = Color(0xFF00C853);   // Green Accent

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Metro Tuyến số 1",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_startColor, _endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header mô phỏng bản đồ
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_startColor.withOpacity(0.1), _endColor.withOpacity(0.05)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                image: const DecorationImage(
                  image: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Ho_Chi_Minh_City_Metro_system_map.png/640px-Ho_Chi_Minh_City_Metro_system_map.png"),
                  fit: BoxFit.cover,
                  opacity: 0.8,
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "Bản đồ Quy hoạch Metro",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.format_list_bulleted_rounded, color: _startColor),
                const SizedBox(width: 8),
                Text(
                  "Danh sách trạm",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),

          // Timeline trạm
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final isLast = index == stations.length - 1;
                final isFirst = index == 0;
                
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cột Timeline
                      SizedBox(
                        width: 40,
                        child: Column(
                          children: [
                            // Đường nối trên (nếu không phải là đầu tiên)
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: 3,
                                color: isFirst ? Colors.transparent : _startColor.withOpacity(0.3),
                              ),
                            ),
                            // Dấu chấm tròn
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: _startColor, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: _startColor.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                            ),
                            // Đường nối dưới (nếu không phải là cuối cùng)
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: 3,
                                color: isLast ? Colors.transparent : _startColor.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Nội dung trạm
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade100,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.subway_rounded, 
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    stations[index],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF37474F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
