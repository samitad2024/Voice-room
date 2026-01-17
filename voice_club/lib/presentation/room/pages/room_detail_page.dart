import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/room_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../bloc/room_bloc.dart';
import '../bloc/room_event.dart';
import '../bloc/room_state.dart';

class RoomDetailPage extends StatelessWidget {
  final RoomEntity room;

  const RoomDetailPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RoomBloc>()..add(JoinRoomEvent(room.id)),
      child: _RoomDetailContent(room: room),
    );
  }
}

class _RoomDetailContent extends StatelessWidget {
  final RoomEntity room;

  const _RoomDetailContent({required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share link copied!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showRoomOptions(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RoomError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (state is RoomJoined) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Info Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      state.room.category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (state.room.isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'LIVE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.room.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (state.room.description != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  state.room.description!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${state.room.participantCount} participants',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Speakers Section
                        _buildSectionHeader(
                          context,
                          AppStrings.speakers,
                          Icons.mic,
                        ),
                        const SizedBox(height: 12),
                        ..._buildUserList(context, [
                          state.room.host,
                          ...state.room.speakers,
                        ], isSpeaker: true),

                        const SizedBox(height: 24),

                        // Listeners Section
                        if (state.room.listeners.isNotEmpty) ...[
                          _buildSectionHeader(
                            context,
                            '${AppStrings.listeners} (${state.room.listeners.length})',
                            Icons.person,
                          ),
                          const SizedBox(height: 12),
                          ..._buildUserList(context, state.room.listeners),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Control Panel
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute/Unmute Button
                        _buildControlButton(
                          context,
                          icon: state.isMuted ? Icons.mic_off : Icons.mic,
                          label: state.isMuted ? 'Unmute' : 'Mute',
                          color: state.isMuted
                              ? AppColors.textSecondary
                              : AppColors.primary,
                          onTap: () {
                            context.read<RoomBloc>().add(
                              const ToggleMuteEvent(),
                            );
                          },
                        ),

                        // Raise Hand Button
                        _buildControlButton(
                          context,
                          icon: Icons.back_hand,
                          label: state.isHandRaised
                              ? 'Lower Hand'
                              : 'Raise Hand',
                          color: state.isHandRaised
                              ? AppColors.warning
                              : AppColors.textSecondary,
                          onTap: () {
                            context.read<RoomBloc>().add(
                              const RaiseHandEvent(),
                            );
                          },
                        ),

                        // Leave Button
                        _buildControlButton(
                          context,
                          icon: Icons.exit_to_app,
                          label: 'Leave',
                          color: AppColors.error,
                          onTap: () {
                            _showLeaveDialog(context, state.room.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  List<Widget> _buildUserList(
    BuildContext context,
    List<UserEntity> users, {
    bool isSpeaker = false,
  }) {
    return users.map((user) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSpeaker
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.fullName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 18),
                        )
                      : null,
                ),
                if (isSpeaker)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.roomSpeaking,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSpeaker)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Speaker',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(BuildContext context, String roomId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Room?'),
        content: const Text('Are you sure you want to leave this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<RoomBloc>().add(LeaveRoomEvent(roomId));
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showRoomOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text('Share Room'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share link copied!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Invite Friends'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Room'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
