import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Env.appName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Auth gate placeholder (MVP scaffold).'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/cycle'),
            child: const Text('Go to Cycle Tracker'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => context.go('/feed'),
            child: const Text('Go to Social Feed'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => context.go('/chat'),
            child: const Text('Go to Chat'),
          ),
        ],
      ),
    );
  }
}
