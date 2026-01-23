import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/room.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Room Page - Active Voice Chat Room
/// Phase 2, Step 10-12: Audio streaming with Zego SDK
/// Currently a placeholder - Zego integration coming next
class RoomPage extends StatefulWidget {
  final Room room;

  const RoomPage({
    super.key,
    required this.room,
  });

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  bool _isMuted = false;
  bool _isSpeaker = false;

  @override
  void initState() {
    super.initState();
    // Check if current user is the owner or a speaker
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _isSpeaker = authState.user.uid == widget.room.ownerId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.room.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Live indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showRoomMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Room Info Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
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
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(widget.room.category),
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.room.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.room.isPublic
                                ? Icons.public
                                : widget.room.isPrivate
                                    ? Icons.lock
                                    : Icons.group,
                            size: 14,
                            color: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.room.roomType,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.room.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.room.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Coming Soon Notice
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Icon with animated background
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.1),
                          colorScheme.secondary.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.construction_rounded,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Audio Streaming Coming Soon!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We\'re building the audio streaming feature',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Feature cards
                  _buildFeatureCard(
                    context,
                    icon: Icons.mic_rounded,
                    title: 'Zego SDK Integration',
                    description: 'High-quality real-time audio',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    icon: Icons.people_rounded,
                    title: 'Speaker/Audience Roles',
                    description: 'Manage who can speak in the room',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    icon: Icons.tune_rounded,
                    title: 'Audio Controls & Effects',
                    description: 'Mute, volume, and audio quality settings',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 32),

                  // Status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 48,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Room Created Successfully!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You are in the room as ${_isSpeaker ? "Owner/Speaker" : "Audience"}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.green.shade900,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Control Panel
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  _buildControlButton(
                    context: context,
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    onPressed: () {
                      setState(() => _isMuted = !_isMuted);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Audio controls will be available with Zego SDK',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    color: _isMuted ? Colors.red : null,
                  ),

                  // Leave button
                  _buildControlButton(
                    context: context,
                    icon: Icons.call_end_rounded,
                    label: 'Leave',
                    onPressed: () => _leaveRoom(context),
                    color: Colors.red,
                    isDestructive: true,
                  ),

                  // Settings button
                  _buildControlButton(
                    context: context,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Audio settings coming soon'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonColor =
        color ?? (isDestructive ? Colors.red : colorScheme.primaryContainer);
    final iconColor = isDestructive || color != null
        ? Colors.white
        : colorScheme.onPrimaryContainer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: buttonColor,
          elevation: 4,
          shadowColor: buttonColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 28,
                color: iconColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color.withOpacity(0.9),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return Icons.music_note_rounded;
      case 'gaming':
        return Icons.sports_esports_rounded;
      case 'business':
        return Icons.business_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'technology':
        return Icons.computer_rounded;
      case 'lifestyle':
        return Icons.style_rounded;
      default:
        return Icons.mic_rounded;
    }
  }

  void _showRoomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Room Info'),
              onTap: () {
                Navigator.pop(context);
                _showRoomInfo(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: Text('Participants (${widget.room.totalListeners})'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Participants list coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Room'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Share functionality coming soon')),
                );
              },
            ),
            if (_isSpeaker)
              ListTile(
                leading: const Icon(Icons.stop, color: Colors.red),
                title: const Text(
                  'End Room',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _endRoom(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRoomInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Room Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Title', widget.room.title),
            _infoRow('Category', widget.room.category),
            _infoRow('Type', widget.room.roomType),
            _infoRow('Max Speakers', '${widget.room.maxSpeakers}'),
            _infoRow('Listeners', '${widget.room.totalListeners}'),
            if (widget.room.tags.isNotEmpty)
              _infoRow('Tags', widget.room.tags.join(', ')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _leaveRoom(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Room'),
        content: const Text('Are you sure you want to leave this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Leave room
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Left the room')),
              );
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _endRoom(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Room'),
        content: const Text(
          'Are you sure you want to end this room? All participants will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Leave room
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Room ended'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Room'),
          ),
        ],
      ),
    );
  }
}
