import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/swipe/data/response_repository.dart';
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

  // ローカル永続化の初期化
  final prefs = await SharedPreferences.getInstance();

  // AdMobの初期化
  await AdService.instance.initialize();

  // RevenueCatの初期化
  await _configureRevenueCat();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const VibeQuestApp(),
    ),
  );
}

/// RevenueCatの設定と初期化
Future<void> _configureRevenueCat() async {
  // デバッグログを有効化
  await Purchases.setLogLevel(LogLevel.debug);

  // プラットフォーム別のAPIキーを取得
  late final String apiKey;
  if (Platform.isIOS) {
    apiKey = dotenv.env['REVENUECAT_API_KEY_IOS'] ?? '';
  } else if (Platform.isAndroid) {
    apiKey = dotenv.env['REVENUECAT_API_KEY_ANDROID'] ?? '';
  } else {
    return; // サポートされていないプラットフォーム
  }

  if (apiKey.isEmpty) {
    debugPrint('RevenueCat APIキーが設定されていません');
    return;
  }

  try {
    final configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);
    debugPrint('RevenueCat初期化成功');
  } catch (e) {
    debugPrint('RevenueCat初期化エラー: $e');
  }
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
    // 課金状態の確認
    Future.microtask(() {
      ref.read(purchaseServiceProvider.notifier).checkPurchaseStatus();
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
