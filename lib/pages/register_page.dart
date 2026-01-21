import 'package:flutter/material.dart';

import 'login_page.dart';

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
      // Demo: bạn thay bằng API tạo tài khoản thật sau
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo tài khoản thành công (demo)!')),
      );

      // quay về login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF0F172A), Color(0xFF111827)]
                    : const [Color(0xFFEEF2FF), Color(0xFFE0F2FE)],
              ),
            ),
          ),

          // Soft blobs
          Positioned(
            top: -120,
            left: -80,
            child: _BlurBlob(
              size: 260,
              color: isDark ? Colors.white10 : Colors.indigo.withOpacity(.12),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -90,
            child: _BlurBlob(
              size: 300,
              color: isDark ? Colors.white10 : Colors.lightBlue.withOpacity(.12),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0B1220) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          color: Colors.black.withOpacity(isDark ? .25 : .08),
                        )
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 6),

                          // Header
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                                  ),
                                ),
                                child: const Icon(Icons.person_add_alt_1, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tạo tài khoản',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Đăng ký để lưu lịch sử & tuyến yêu thích',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(.7),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Name
                          TextFormField(
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Họ và tên',
                              hintText: 'vd: Lê Văn A',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) {
                              final s = (v ?? '').trim();
                              if (s.isEmpty) return 'Vui lòng nhập họ tên';
                              if (s.length < 2) return 'Họ tên quá ngắn';
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'vd: abc@gmail.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) {
                              final s = (v ?? '').trim();
                              if (s.isEmpty) return 'Vui lòng nhập email';
                              if (!s.contains('@')) return 'Email không hợp lệ';
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Password
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure1,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              hintText: 'Tối thiểu 6 ký tự',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscure1 = !_obscure1),
                                icon: Icon(_obscure1 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                tooltip: _obscure1 ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) {
                              final s = (v ?? '');
                              if (s.isEmpty) return 'Vui lòng nhập mật khẩu';
                              if (s.length < 6) return 'Ít nhất 6 ký tự';
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Confirm
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscure2,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _register(),
                            decoration: InputDecoration(
                              labelText: 'Nhập lại mật khẩu',
                              hintText: 'Nhập lại để xác nhận',
                              prefixIcon: const Icon(Icons.lock_reset_outlined),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscure2 = !_obscure2),
                                icon: Icon(_obscure2 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                tooltip: _obscure2 ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) {
                              final s = (v ?? '');
                              if (s.isEmpty) return 'Vui lòng nhập lại mật khẩu';
                              if (s != _passCtrl.text) return 'Mật khẩu không khớp';
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : const Text(
                                'Tạo tài khoản',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đã có tài khoản?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(.75),
                                ),
                              ),
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                ),
                                child: const Text('Đăng nhập'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
