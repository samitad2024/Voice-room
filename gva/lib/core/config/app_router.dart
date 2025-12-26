import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_gate_page.dart';
import '../../features/auth/presentation/pages/onboarding/onboarding_page.dart';
import '../../features/auth/presentation/pages/splash/splash_sequence_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/cycle_tracker/presentation/pages/cycle_tracker_page.dart';
import '../../features/social_feed/presentation/pages/social_feed_page.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashSequencePage(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthGatePage(),
        ),
        GoRoute(
          path: '/cycle',
          builder: (context, state) => const CycleTrackerPage(),
        ),
        GoRoute(
          path: '/feed',
          builder: (context, state) => const SocialFeedPage(),
        ),
        GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
      ],
    );
  }
}
