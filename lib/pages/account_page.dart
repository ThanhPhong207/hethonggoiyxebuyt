import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifiers/theme_notifier.dart';
import '../notifiers/user_profile_notifier.dart';
import 'login_page.dart';
import 'admin/admin_bus_data_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  static const Color _primary = Color(0xFF00BFA5); // Teal Accent
  static const Color _secondary = Color(0xFF1DE9B6);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final profile = context.watch<UserProfileNotifier>();
    
    // Determine current brightness based on the notifier
    final isDark = themeNotifier.isDark;

    // Define Colors based on Theme
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF37474F);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final iconBgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.teal.shade50;
    final iconColor = isDark ? _secondary : Colors.teal.shade400;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 100,
            floating: false,
            pinned: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: const SafeArea(
                child: Center(
                  child: Text(
                    "Tài khoản",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Card
                  _buildProfileCard(context, profile, cardColor, textColor, subTextColor),
                  
                  const SizedBox(height: 24),
                  
                  // Settings Group
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Cài đặt chung",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: Icons.admin_panel_settings_rounded,
                          title: "Quản lý dữ liệu xe (Admin)",
                          textColor: textColor,
                          iconColor: Colors.orange,
                          iconBgColor: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBusDataPage())),
                        ),
                         Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100, indent: 60, endIndent: 20),
                        _buildSettingItem(
                          icon: Icons.edit_note_rounded,
                          title: "Chỉnh sửa thông tin",
                          textColor: textColor,
                          iconColor: iconColor,
                          iconBgColor: iconBgColor,
                          onTap: () => _showEditDialog(context, isDark),
                        ),
                        Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100, indent: 60, endIndent: 20),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.indigo.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.dark_mode_rounded, 
                              color: isDark ? Colors.indigoAccent : Colors.indigo.shade400, 
                              size: 20
                            ),
                          ),
                          title: Text(
                            "Giao diện tối",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor),
                          ),
                          value: themeNotifier.isDark,
                          activeColor: _primary,
                          onChanged: (_) => themeNotifier.toggleTheme(),
                        ),
                        Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100, indent: 60, endIndent: 20),
                        _buildSettingItem(
                          icon: Icons.language_rounded,
                          title: "Ngôn ngữ",
                          trailing: "Tiếng Việt",
                          textColor: textColor,
                          iconColor: iconColor,
                          iconBgColor: iconBgColor,
                          onTap: () {}, // Future feature
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Support Group
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Hỗ trợ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: Icons.help_outline_rounded,
                          title: "Trung tâm trợ giúp",
                          textColor: textColor,
                          iconColor: iconColor,
                          iconBgColor: iconBgColor,
                          onTap: () {},
                        ),
                        Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100, indent: 60, endIndent: 20),
                        _buildSettingItem(
                          icon: Icons.info_outline_rounded,
                          title: "Về ứng dụng BusGo",
                          textColor: textColor,
                          iconColor: iconColor,
                          iconBgColor: iconBgColor,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await context.read<UserProfileNotifier>().logout();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded),
                          SizedBox(width: 8),
                          Text("Đăng xuất", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Phiên bản 1.0.0",
                    style: TextStyle(color: subTextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserProfileNotifier profile, Color bgColor, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_primary.withOpacity(0.2), _secondary.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.person, color: _primary, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.isEmpty ? "Người dùng" : profile.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email.isEmpty ? "Chưa cập nhật email" : profile.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                 Text(
                  profile.phone.isEmpty ? "Chưa cập nhật SĐT" : profile.phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? trailing,
    required Color textColor,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (trailing == null)
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, bool isDark) {
    final profile = context.read<UserProfileNotifier>();

    final nameCtrl = TextEditingController(text: profile.name);
    final emailCtrl = TextEditingController(text: profile.email);
    final phoneCtrl = TextEditingController(text: profile.phone);

    final formKey = GlobalKey<FormState>();
    final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Chỉnh sửa thông tin", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogInput(nameCtrl, "Họ và tên", Icons.badge_outlined, isDark),
                  const SizedBox(height: 16),
                  _buildDialogInput(emailCtrl, "Gmail", Icons.email_outlined, isDark, isEmail: true),
                  const SizedBox(height: 16),
                  _buildDialogInput(phoneCtrl, "Số điện thoại", Icons.phone_outlined, isDark, isPhone: true),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy", style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await profile.updateProfile(
                  name: nameCtrl.text,
                  email: emailCtrl.text,
                  phone: phoneCtrl.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã cập nhật thông tin")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Lưu thay đổi"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogInput(TextEditingController controller, String label, IconData icon, bool isDark, {bool isEmail = false, bool isPhone = false}) {
     final inputColor = isDark ? const Color(0xFF374151) : Colors.grey.shade50;
     final textColor = isDark ? Colors.white : Colors.black87;
     
     return TextFormField(
        controller: controller,
        style: TextStyle(color: textColor),
        keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500),
          filled: true,
          fillColor: inputColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
        validator: isEmail ? (v) {
           final s = (v ?? '').trim();
           if (s.isEmpty) return "Vui lòng nhập email";
           if (!s.contains('@')) return "Email không hợp lệ";
           return null;
        } : (label == "Họ và tên" ? (v) => (v ?? '').trim().isEmpty ? "Vui lòng nhập họ tên" : null : null),
     );
  }
}
