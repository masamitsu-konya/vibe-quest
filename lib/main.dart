import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/swipe/presentation/swipe_screen.dart';
import 'features/monetization/services/ad_service.dart';
import 'features/monetization/services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // AdMobの初期化
  await AdService.instance.initialize();

  runApp(
    const ProviderScope(
      child: VibeQuestApp(),
    ),
  );
}

class VibeQuestApp extends ConsumerStatefulWidget {
  const VibeQuestApp({super.key});

  @override
  ConsumerState<VibeQuestApp> createState() => _VibeQuestAppState();
}

class _VibeQuestAppState extends ConsumerState<VibeQuestApp> {
  @override
  void initState() {
    super.initState();
    // RevenueCatの初期化
    Future.microtask(() {
      ref.read(purchaseServiceProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Quest',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SwipeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
