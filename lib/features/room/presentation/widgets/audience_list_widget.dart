import 'package:flutter/material.dart';
import '../../domain/entities/live_room_participant.dart';

/// Audience List Widget
/// Scrollable list of audience members (listeners)
class AudienceListWidget extends StatelessWidget {
  final List<LiveRoomParticipant> audience;
  final String? currentUserId;
  final Function(LiveRoomParticipant) onAudienceTap;

  const AudienceListWidget({
    super.key,
    required this.audience,
    this.currentUserId,
    required this.onAudienceTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (audience.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'No audience yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: audience.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: colorScheme.outlineVariant,
      ),
      itemBuilder: (context, index) {
        final member = audience[index];
        final isCurrentUser = member.userId == currentUserId;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              // Online indicator
              if (member.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  member.userId.length > 12
                      ? '${member.userId.substring(0, 12)}...'
                      : member.userId, // TODO: Get real name
                  style: TextStyle(
                    fontWeight:
                        isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentUser
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCurrentUser)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'You',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            member.isOnline ? 'Listening' : 'Offline',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: member.isOnline
                      ? Colors.green
                      : colorScheme.onSurfaceVariant,
                ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          onTap: () => onAudienceTap(member),
        );
      },
    );
  }
}
