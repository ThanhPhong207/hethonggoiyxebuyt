import 'package:flutter/material.dart';

import 'login_page.dart';
import '../services/supabase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  // Modern Color Palette
  static const Color _bgStart = Color(0xFFE0F7FA); // Light Cyan
  static const Color _bgEnd = Color(0xFFF1F8E9);   // Light Green
  static const Color _primary = Color(0xFF00BFA5); // Teal Accent
  static const Color _secondary = Color(0xFF1DE9B6); 
  static const Color _textDark = Color(0xFF37474F);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text;
      final name = _nameCtrl.text.trim();

      // --- SUPABASE REGISTER ---
      await SupabaseService().signUpWithEmail(
        email, 
        password,
        data: {'full_name': name}
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo tài khoản thành công! Hãy đăng nhập.'),
          backgroundColor: _primary,
        ),
      );

      // quay về login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define colors
    final gradientColors = isDark 
        ? const [Color(0xFF111827), Color(0xFF0F172A)] 
        : const [_bgStart, _bgEnd];
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : _textDark;
    final subTextColor = isDark ? Colors.grey.shade400 : _textDark.withOpacity(0.6);
    final shadowColor = isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05);

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.08),

              // Header Branding
              Hero(
                tag: 'app_logo',
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primary, _secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_bus_filled_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tạo tài khoản mới',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              Text(
                'Tham gia cộng đồng BusGo ngay',
                style: TextStyle(
                  fontSize: 15,
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              // Register Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name
                      _buildTextField(
                        controller: _nameCtrl,
                        label: 'Họ và tên',
                        icon: Icons.person_outline_rounded,
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) return 'Vui lòng nhập họ tên';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return 'Vui lòng nhập email';
                          if (!s.contains('@')) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildTextField(
                        controller: _passCtrl,
                        label: 'Mật khẩu',
                        icon: Icons.lock_outline,
                        obscureText: _obscure1,
                        isPassword: true,
                        onTogglePassword: () => setState(() => _obscure1 = !_obscure1),
                        validator: (v) => (v?.length ?? 0) < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildTextField(
                        controller: _confirmCtrl,
                        label: 'Nhập lại mật khẩu',
                        icon: Icons.lock_reset,
                        obscureText: _obscure2,
                        isPassword: true,
                        onTogglePassword: () => setState(() => _obscure2 = !_obscure2),
                        validator: (v) {
                          if ((v ?? '').isEmpty) return 'Vui lòng nhập lại mật khẩu';
                          if (v != _passCtrl.text) return 'Mật khẩu không khớp';
                          return null;
                        },
                        isLast: true,
                        onSubmitted: (_) => _register(),
                      ),

                      const SizedBox(height: 30),

                      // Register Button
                      Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_primary, _secondary],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : const Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Back to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã có tài khoản? ',
                    style: TextStyle(color: subTextColor, fontWeight: FontWeight.w500),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    child: const Text(
                      'Đăng nhập ngay',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isLast = false,
    Function(String)? onSubmitted,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDark ? const Color(0xFF374151) : Colors.grey.shade50;
    final inputBorderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final textColor = isDark ? Colors.white : Colors.black87;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: onSubmitted,
      style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.teal.shade300),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                ),
              )
            : null,
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: validator,
    );
  }
}
