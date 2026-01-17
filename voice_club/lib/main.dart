import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/bloc/auth_event.dart';
import 'presentation/auth/pages/splash_page.dart';
import 'presentation/home/bloc/home_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    DevicePreview(
      enabled: kIsWeb, // Only enable on web
      defaultDevice: Devices.android.samsungGalaxyS20,
      builder: (context) => const VoiceClubApp(),
    ),
  );
}

class VoiceClubApp extends StatelessWidget {
  const VoiceClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(create: (_) => sl<HomeBloc>()),
      ],
      child: MaterialApp(
        title: 'VoiceClub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Device Preview Configuration
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        home: const SplashPage(),
      ),
    );
  }
}
