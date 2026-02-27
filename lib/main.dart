import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:priesters_blueprint_app/core/presentation/main_navigation_screen.dart';

import 'core/theme/graphics_controller.dart';
import 'package:priesters_blueprint_app/core/presentation/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final sharedPrefs = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: 'https://hvcosatizcoqzuwlzflq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2Y29zYXRpemNvcXp1d2x6ZmxxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTg1NTA5MywiZXhwIjoyMDg3NDMxMDkzfQ.ZyRtIX-mgFZtgx37LmLA7ewG-tVda1cdhAmDO1AbNMw',
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const PriestersBlueprintApp(),
    ),
  );
}

class PriestersBlueprintApp extends ConsumerWidget {
  const PriestersBlueprintApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphicsState = ref.watch(graphicsControllerProvider);

    return MaterialApp(
      title: 'Priester\'s Layout & Compliance',
      debugShowCheckedModeBanner: false,
      themeMode: graphicsState.themeMode,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: Brightness.dark,
        ),
      ),
      home: const BlueprintDashboardScreen(),
    );
  }
}