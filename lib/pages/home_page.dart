import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'search_route_page.dart';
import 'nearby_stations_page.dart';
import 'bus_lookup_page.dart';
import 'account_page.dart';
import 'history_page.dart';
import 'bus_info_page.dart';
import 'metro_info_page.dart';
import 'waterbus_info_page.dart';
import 'bike_info_page.dart';
import 'notifications_page.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeDashboard(),
    const NotificationsPage(), 
    const HistoryPage(),
    const FavoritesPage(),
    const AccountPage(),
  ];

  static const Color _primary = Color(0xFF00BFA5); // Teal Accent

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final navColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final navShadow = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor, 
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navColor,
          boxShadow: [
            BoxShadow(
              color: navShadow,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: _primary,
          unselectedItemColor: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          backgroundColor: Colors.transparent, // Use container color
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Thông báo'),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Lịch sử'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Yêu thích'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Tài khoản'),
          ],
        ),
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  static const Color _primary = Color(0xFF00BFA5);
  static const Color _secondary = Color(0xFF1DE9B6);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // UI Overlay Style
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Header is gradient dark
      )
    );

    // Colors
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF37474F);
    final subTextColor = isDark ? Colors.grey.shade400 : const Color(0xFF455A64);
    final cardShadow = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05);
    final promoBg = isDark ? Colors.indigo.withOpacity(0.2) : Colors.indigo.shade50;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Gradient
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Người dùng BusGo',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Search Bar
                GestureDetector(
                  onTap: () {
                     // Navigate to search
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: _primary),
                        const SizedBox(width: 12),
                        Text(
                          'Bạn muốn đi đâu hôm nay?',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade400, 
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Promo Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: promoBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          'Đăng ký thẻ Multipass',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.indigoAccent : const Color(0xFF3F51B5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Đi lại không giới hạn chỉ với 50k/tháng',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.indigo.shade200 : Colors.indigo.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.card_membership_rounded, color: isDark ? Colors.indigoAccent : const Color(0xFF3F51B5)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Transport Modes Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  'Phương tiện',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                Text('Xem tất cả', style: TextStyle(color: _primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _transportItem(context, 'Xe buýt', Icons.directions_bus_rounded, const Color(0xFF4CAF50), BusInfoPage(), subTextColor, isDark),
                _transportItem(context, 'Metro', Icons.subway_rounded, const Color(0xFF00BCD4), const MetroInfoPage(), subTextColor, isDark),
                _transportItem(context, 'Waterbus', Icons.directions_boat_rounded, const Color(0xFFFF9800), const WaterbusInfoPage(), subTextColor, isDark),
                _transportItem(context, 'Xe đạp', Icons.pedal_bike_rounded, const Color(0xFFF44336), const BikeInfoPage(), subTextColor, isDark),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Smart Features
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tiện ích',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _featureCard(context, 'Tìm đường', Icons.alt_route_rounded, Colors.blue.shade50, Colors.blue, const SearchRoutePage(), cardColor, cardShadow, textColor, isDark),
                _featureCard(context, 'Trạm gần đây', Icons.near_me_rounded, Colors.orange.shade50, Colors.orange, const NearbyStationsPage(), cardColor, cardShadow, textColor, isDark),
                _featureCard(context, 'Tra cứu', Icons.search_rounded, Colors.purple.shade50, Colors.purple, const BusLookupPage(), cardColor, cardShadow, textColor, isDark),
                _featureCard(context, 'Tin tức', Icons.newspaper_rounded, Colors.green.shade50, Colors.green, const BusLookupPage(), cardColor, cardShadow, textColor, isDark), // Placeholder
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _transportItem(BuildContext context, String label, IconData icon, Color color, Widget page, Color textColor, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(BuildContext context, String title, IconData icon, Color bgColor, Color iconColor, Widget page, Color cardColor, Color shadowColor, Color textColor, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? iconColor.withOpacity(0.2) : bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
