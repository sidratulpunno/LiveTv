import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('iptv_cache');

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter IPTV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF1E1E1E)),
      ),
      // --- CORRECTED SHORTCUTS HERE ---
      shortcuts: {
        // Maps the Android TV D-Pad Center button (Select) to ActivateIntent
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        // Maps standard Enter key (often used on remotes/keyboards)
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      home: HomeScreen(),
    );
  }
}