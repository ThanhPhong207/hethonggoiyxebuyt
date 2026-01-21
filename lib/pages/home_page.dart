import 'package:flutter/material.dart';
import 'search_route_page.dart';
import 'nearby_stations_page.dart';
import 'bus_lookup_page.dart';
import 'account_page.dart';
import 'history_page.dart';
import 'bus_info_page.dart';
import 'metro_info_page.dart';
import 'waterbus_info_page.dart';
import 'bike_info_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeDashboard(),
    const Center(child: Text('Thông báo')),
    const HistoryPage(),
    const Center(child: Text('Yêu thích')),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Yêu thích'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.greenAccent, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TRUNG TÂM QUẢN LÝ GIAO THÔNG THANH PHONG',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Đa phương tiện – Trọn vẹn hành trình',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Đăng Ký Thẻ Multipass',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Chỉ đường thông minh...',
                        prefixIcon: Icon(Icons.navigation, color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _transportBox(context, 'Buýt', Icons.directions_bus,
                          Colors.green.shade300, BusInfoPage()),
                      _transportBox(context, 'Metro', Icons.subway,
                          Colors.cyan.shade300, const MetroInfoPage()),
                      _transportBox(context, 'Waterbus', Icons.directions_boat,
                          Colors.orange.shade300, const WaterbusInfoPage()),
                      _transportBox(context, 'Xe đạp', Icons.directions_bike,
                          Colors.red.shade300, const BikeInfoPage()),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tính năng thông minh',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Xem tất cả', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _featureItem(context, Icons.alt_route, 'Tìm đường', const SearchRoutePage()),
                _featureItem(context, Icons.location_on, 'Trạm xung quanh', const NearbyStationsPage()),
                _featureItem(context, Icons.rate_review, 'Đánh giá', const BusLookupPage()),
                _featureItem(context, Icons.directions_boat, 'Mua vé Waterbus', const BusLookupPage()),
              ],
            )
          ],
        ),
      ),
    );
  }

  // =============================
  //  Hàm tạo nút Buýt / Metro / ...
  // =============================
  Widget _transportBox(BuildContext context, String label, IconData icon,
      Color color, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(
      BuildContext context, IconData icon, String label, Widget page) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.green, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
