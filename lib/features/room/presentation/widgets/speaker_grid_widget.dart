import 'package:flutter/material.dart';
import '../../domain/entities/live_room_participant.dart';

/// Speaker Grid Widget
/// Displays speakers in a grid layout (max 9 visible at once)
/// Shows speaking animation, muted status, and network quality
class SpeakerGridWidget extends StatelessWidget {
  final List<LiveRoomParticipant> speakers;
  final String? currentUserId;
  final Function(LiveRoomParticipant) onSpeakerTap;

  const SpeakerGridWidget({
    super.key,
    required this.speakers,
    this.currentUserId,
    required this.onSpeakerTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Max 9 speakers visible in grid
    final visibleSpeakers = speakers.take(9).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: visibleSpeakers.length,
        itemBuilder: (context, index) {
          final speaker = visibleSpeakers[index];
          final isCurrentUser = speaker.userId == currentUserId;
          // Speaking indicator - check if user is speaking based on isMuted status
          // When not muted and is a speaker, show speaking indicator (simplified for now)
          final isSpeaking = !speaker.isMuted && speaker.canSpeak;

          return InkWell(
            onTap: () => onSpeakerTap(speaker),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar with speaking indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Speaking animation ring - shows when user is not muted
                    if (isSpeaking)
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                    // Avatar
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrentUser
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),

                    // Muted indicator
                    if (speaker.isMuted)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.mic_off,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    // Network quality indicator
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _NetworkQualityBadge(
                        quality: speaker.networkQuality,
                      ),
                    ),

                    // Owner/Admin badge
                    if (speaker.role == 'owner' || speaker.role == 'admin')
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: speaker.role == 'owner'
                                ? Colors.amber
                                : Colors.purple,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            speaker.role == 'owner' ? Icons.star : Icons.shield,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Name (TODO: Get from user table)
                Text(
                  speaker.userId.length > 8
                      ? '${speaker.userId.substring(0, 8)}...'
                      : speaker.userId,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight:
                            isCurrentUser ? FontWeight.bold : FontWeight.normal,
                        color: colorScheme.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),

                // Role indicator
                if (speaker.role != 'speaker')
                  Text(
                    speaker.role == 'owner' ? 'Host' : 'Admin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: speaker.role == 'owner'
                              ? Colors.amber
                              : Colors.purple,
                          fontSize: 10,
                        ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NetworkQualityBadge extends StatelessWidget {
  final String quality;

  const _NetworkQualityBadge({required this.quality});

  Color _getQualityColor() {
    switch (quality) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getQualityIcon() {
    switch (quality) {
      case 'excellent':
        return Icons.signal_cellular_alt;
      case 'good':
        return Icons.signal_cellular_alt_2_bar;
      case 'poor':
        return Icons.signal_cellular_alt_1_bar;
      default:
        return Icons.signal_cellular_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _getQualityColor(),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getQualityIcon(),
        size: 10,
        color: Colors.white,
      ),
    );
  }
}
