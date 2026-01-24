import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifiers/theme_notifier.dart';
import 'notifiers/user_profile_notifier.dart';
import 'pages/login_page.dart';

import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Hãy cập nhật URL và Anon Key trong lib/services/supabase_service.dart
  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(
          create: (_) => UserProfileNotifier()..load(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.currentTheme,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const LoginPage(),
    );
  }
}
