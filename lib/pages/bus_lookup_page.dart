import 'package:flutter/material.dart';

class BusLookupPage extends StatelessWidget {
  const BusLookupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final buses = ["Tuyến 20A", "Tuyến 57", "Tuyến 32"];

    return Scaffold(
      appBar: AppBar(title: const Text("Tra cứu tuyến xe")),
      body: ListView.builder(
        itemCount: buses.length,
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.directions_bus),
          title: Text(buses[i]),
        ),
      ),
    );
  }
}