import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/entities/user.dart';

/// Profile page displaying user information and settings
/// Based on blueprint.md: Shows level frame, coins, gifts received, followers/following count
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Get current user from authenticated state
        final User? user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // TODO: Navigate to settings page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon')),
                  );
                },
              ),
            ],
          ),
          body: user == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Profile Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            backgroundImage: user.photoUrl != null
                                ? NetworkImage(user.photoUrl!)
                                : null,
                            child: user.photoUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt,
                                    size: 18, color: Colors.white),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  // TODO: Edit profile photo
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Edit photo coming soon')),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // User Name
                      Text(
                        user.name ?? 'User',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),

                      const SizedBox(height: 4),

                      // User Email/Phone
                      Text(
                        user.email ?? user.phone ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                      ),

                      const SizedBox(height: 8),

                      // Verified Badge (if applicable)
                      if (user.isVerified == true)
                        Chip(
                          avatar: const Icon(Icons.verified, size: 16),
                          label: const Text('Verified'),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),

                      const SizedBox(height: 24),

                      // Stats Row - Following blueprint.md requirements
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(
                            context,
                            icon: Icons.monetization_on,
                            label: 'Coins',
                            value: user.coins.toString(),
                            color: Colors.amber,
                          ),
                          _buildStatCard(
                            context,
                            icon: Icons.military_tech,
                            label: 'Level',
                            value: user.level.toString(),
                            color: Colors.purple,
                          ),
                          _buildStatCard(
                            context,
                            icon: Icons.people,
                            label: 'Followers',
                            value: user.followersCount.toString(),
                            color: Colors.blue,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Profile Actions - Following blueprint.md guidelines
                      _buildActionTile(
                        context,
                        icon: Icons.edit,
                        title: 'Edit Profile',
                        subtitle: 'Change name, bio, photo',
                        onTap: () {
                          // TODO: Navigate to edit profile page
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Edit profile coming soon')),
                          );
                        },
                      ),

                      _buildActionTile(
                        context,
                        icon: Icons.wallet,
                        title: 'My Wallet',
                        subtitle: 'Coins, transactions & top-up',
                        onTap: () {
                          // TODO: Navigate to wallet page
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Wallet coming soon')),
                          );
                        },
                      ),

                      _buildActionTile(
                        context,
                        icon: Icons.favorite,
                        title: 'Favorites',
                        subtitle: 'Saved rooms and users',
                        onTap: () {
                          // TODO: Navigate to favorites
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Favorites coming soon')),
                          );
                        },
                      ),

                      _buildActionTile(
                        context,
                        icon: Icons.history,
                        title: 'History',
                        subtitle: 'Rooms you\'ve joined',
                        onTap: () {
                          // TODO: Navigate to history
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('History coming soon')),
                          );
                        },
                      ),

                      _buildActionTile(
                        context,
                        icon: Icons.settings,
                        title: 'Settings',
                        subtitle: 'Privacy, notifications & more',
                        onTap: () {
                          // TODO: Navigate to settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Settings coming soon')),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // Logout Button
                      _buildActionTile(
                        context,
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        iconColor: Colors.red,
                        onTap: () => _handleLogout(context),
                      ),

                      const SizedBox(height: 24),

                      // Version Info
                      Text(
                        'Version 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.6),
                            ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
