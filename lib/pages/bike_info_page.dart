import 'package:flutter/material.dart';

class BikeInfoPage extends StatelessWidget {
  const BikeInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin Xe đạp"),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text(
          "Nội dung thông tin về Xe đạp...",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
