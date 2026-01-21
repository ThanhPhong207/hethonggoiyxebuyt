import 'package:flutter/material.dart';

class WaterbusInfoPage extends StatelessWidget {
  const WaterbusInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Waterbus"),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Text("Thông tin Waterbus (đang cập nhật)"),
      ),
    );
  }
}
