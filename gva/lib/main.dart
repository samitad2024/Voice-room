import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'core/config/app_router.dart';
import 'core/config/app_theme.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const GuavaApp(),
    ),
  );
}

class GuavaApp extends StatelessWidget {
  const GuavaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Guava',
      theme: AppTheme.light(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: AppRouter.createRouter(),
    );
  }
}
