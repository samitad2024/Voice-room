import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/config/app_colors.dart';
import '../../widgets/onboarding_hero_art.dart';
import '../../widgets/onboarding_indicator.dart';
import '../../widgets/pill_buttons.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _pageCount = 3;

  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (value) => setState(() => _index = value),
                children: const [
                  _OnboardingScreen(
                    hero: TrackingHeroBadge(),
                    title: 'Tracking\nand Suggestions',
                  ),
                  _OnboardingScreen(
                    hero: AvocadoHeroIcon(),
                    title: 'Empowered\ncommunity',
                  ),
                  _OnboardingScreen(
                    hero: JournalingHeroIcon(),
                    title: 'Personal\nJournaling',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnboardingIndicator(count: _pageCount, index: _index),
                  const SizedBox(height: 14),
                  PrimaryPillButton(
                    label: 'Continue with email',
                    onPressed: () => context.go('/auth'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SocialPillButton(
                          label: 'Apple',
                          leading: const Icon(Icons.apple, size: 18),
                          onPressed: () => context.go('/auth'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SocialPillButton(
                          label: 'Google',
                          leading: const _GoogleGMark(),
                          onPressed: () => context.go('/auth'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: null,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.footerLink,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Privacy Policy'),
                      ),
                      const SizedBox(width: 18),
                      TextButton(
                        onPressed: null,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.footerLink,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Terms of Service'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingScreen extends StatelessWidget {
  const _OnboardingScreen({required this.hero, required this.title});

  final Widget hero;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Align(alignment: Alignment.topCenter, child: hero),
          const SizedBox(height: 26),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.brandWordmark,
              fontSize: 30,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleGMark extends StatelessWidget {
  const _GoogleGMark();

  @override
  Widget build(BuildContext context) {
    // Minimal mark (single letter) until an exact Google asset is provided.
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    );
  }
}
