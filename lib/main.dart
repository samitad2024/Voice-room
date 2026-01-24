import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:device_preview/device_preview.dart';
import 'supabase_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint(
      '\n╔══════════════════════════════════════════════════════════════');
  debugPrint('║ 🚀 SOCIAL VOICE APP STARTING');
  debugPrint(
      '╚══════════════════════════════════════════════════════════════\n');

  // Initialize Supabase with session persistence
  debugPrint('⏳ Initializing Supabase...');
  debugPrint('   URL: ${SupabaseConfig.projectUrl}');
  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    anonKey: SupabaseConfig.anonKey,
    storageOptions: const StorageClientOptions(retryAttempts: 3),
  );
  debugPrint('✅ Supabase initialized!\n');

  // Listen for auth state changes
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final session = data.session;

    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🔔 AUTH STATE CHANGE: $event');
    debugPrint(
        '╠══════════════════════════════════════════════════════════════');
    if (session != null) {
      debugPrint(
          '║ 🔑 Access Token: ${session.accessToken.substring(0, 30)}...');
      debugPrint('║ 👤 User ID: ${session.user.id}');
      debugPrint('║ 📧 Email: ${session.user.email ?? "N/A"}');
      debugPrint('║ 📱 Phone: ${session.user.phone ?? "N/A"}');
      debugPrint(
          '║ ⏱️ Expires At: ${session.expiresAt != null ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000) : "N/A"}');
    } else {
      debugPrint('║ ℹ️ No active session');
    }
    debugPrint(
        '╚══════════════════════════════════════════════════════════════\n');
  });

  // Initialize dependencies
  debugPrint('⏳ Initializing dependencies...');
  await di.initializeDependencies();
  debugPrint('✅ Dependencies initialized!\n');

  debugPrint('╔══════════════════════════════════════════════════════════════');
  debugPrint('║ ✅ APP INITIALIZATION COMPLETE - Starting UI');
  debugPrint(
      '╚══════════════════════════════════════════════════════════════\n');

  runApp(DevicePreview(builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const HomePage();
            } else if (state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return const WelcomePage();
          },
        ),
      ),
    );
  }
}
