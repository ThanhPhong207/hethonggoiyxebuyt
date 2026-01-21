import 'package:flutter/material.dart';

class MetroInfoPage extends StatelessWidget {
  final List<String> stations = [
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

  const MetroInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Metro Line 1"),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          // fake metro map
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "Bản đồ Metro (minh hoạ)",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Colors.cyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (index != stations.length - 1)
                          Container(
                            width: 3,
                            height: 40,
                            color: Colors.cyan,
                          )
                      ],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      stations[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
