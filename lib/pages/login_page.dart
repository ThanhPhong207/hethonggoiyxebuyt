import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../notifiers/user_profile_notifier.dart';
import '../services/supabase_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final _formKey = GlobalKey<FormState>();
  final _phoneOrEmailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  bool _usePhone = true; // Toggle giữa SĐT và Email

  // Animation for the toggle
  late double _toggleAlign;

  @override
  void initState() {
    super.initState();
    _toggleAlign = -1.0;
  }

  @override
  void dispose() {
    _phoneOrEmailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final input = _phoneOrEmailCtrl.text.trim();
      final email = _usePhone ? '$input@phone.local' : input;
      final password = _passCtrl.text;

      // --- SUPABASE LOGIN ---
      final res = await SupabaseService().signInWithEmail(email, password);
      final user = res.user;

      if (user == null) throw 'Đăng nhập không thành công';

      // Update Local State
      if (mounted) {
        await context.read<UserProfileNotifier>().setLoggedIn(
          email: user.email ?? email,
          name: user.userMetadata?['full_name'] ?? _guessNameFromInput(input),
          phone: _usePhone ? input : '',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _loading = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return;

      await context.read<UserProfileNotifier>().setLoggedIn(
        email: account.email.trim(),
        name: (account.displayName ?? 'Người dùng').trim(),
        phone: '',
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-in lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng đang phát triển ✨')),
    );
  }

  String _guessNameFromInput(String input) {
    if (_usePhone) return 'Người dùng';
    final local = input.split('@').first;
    return local.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), ' ').trim().isEmpty
        ? 'Người dùng'
        : local.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), ' ').trim();
  }

  // Modern Color Palette
  static const Color _bgStart = Color(0xFFE0F7FA); // Light Cyan
  static const Color _bgEnd = Color(0xFFF1F8E9);   // Light Green
  static const Color _primary = Color(0xFF00BFA5); // Teal Accent
  static const Color _secondary = Color(0xFF1DE9B6); 
  static const Color _textDark = Color(0xFF37474F);

  void _toggleLoginMethod(bool usePhone) {
    setState(() {
      _usePhone = usePhone;
      _toggleAlign = usePhone ? -1.0 : 1.0;
      _phoneOrEmailCtrl.clear();
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define colors based on theme
    final gradientColors = isDark 
        ? const [Color(0xFF111827), Color(0xFF0F172A)] 
        : const [_bgStart, _bgEnd];
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : _textDark;
    final subTextColor = isDark ? Colors.grey.shade400 : _textDark.withOpacity(0.6);
    final inputFillColor = isDark ? const Color(0xFF374151) : Colors.grey.shade50;
    final inputBorderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
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
              // Header Space
              SizedBox(height: size.height * 0.1),
              
              // Logo & Title
              Hero(
                tag: 'app_logo',
                child: Container(
                  width: 80,
                  height: 80,
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
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Xin chào!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Cùng BusGo vi vu khắp phố phường',
                style: TextStyle(
                  fontSize: 16,
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              // Login Card
              Container(
                width: double.infinity,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Toggle Switch
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              alignment: Alignment(_toggleAlign, 0),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: Container(
                                width: (size.width - 48 - 64) / 2, // Approximate width
                                height: 44,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF4B5563) : Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _toggleLoginMethod(true),
                                    child: Center(
                                      child: Text(
                                        'Điện thoại',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: _usePhone ? _primary : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _toggleLoginMethod(false),
                                    child: Center(
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: !_usePhone ? _primary : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Input Field
                      TextFormField(
                        controller: _phoneOrEmailCtrl,
                        keyboardType: _usePhone ? TextInputType.phone : TextInputType.emailAddress,
                        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
                        decoration: InputDecoration(
                          hintText: _usePhone ? '0912 xxx xxx' : 'name@example.com',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(
                            _usePhone ? Icons.phone_android_rounded : Icons.alternate_email_rounded,
                            color: _primary,
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: inputBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: _primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) {
                            return _usePhone ? 'Nhập số điện thoại nha' : 'Nhập email nha';
                          }
                          if (_usePhone) {
                            if (!RegExp(r'^[0-9]{9,11}$').hasMatch(s.replaceAll(' ', ''))) {
                              return 'SĐT chưa đúng định dạng';
                            }
                          } else {
                            if (!s.contains('@')) return 'Email chưa đúng nè';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.lock_rounded, color: _primary),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: inputBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: _primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        validator: (v) => (v?.length ?? 0) < 6 ? 'Mật khẩu ngắn quá (tối thiểu 6)' : null,
                      ),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              color: isDark ? Colors.blue.shade300 : _textDark.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Main Button
                      Container(
                        height: 56,
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
                          onPressed: _loading ? null : _login,
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
                                  'Đăng nhập ngay',
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

              const SizedBox(height: 40),

              // Social Login
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300, indent: 40, endIndent: 10)),
                  Text(
                    'hoặc tiếp tục với',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300, indent: 10, endIndent: 40)),
                ],
              ),
              const SizedBox(height: 24),

              InkWell(
                onTap: _loading ? null : _loginGoogle,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, 
                          ),
                        ),
                      )
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    'Chưa có tài khoản?',
                    style: TextStyle(color: subTextColor, fontWeight: FontWeight.w500),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: const Text(
                      'Tạo tài khoản mới',
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
}
