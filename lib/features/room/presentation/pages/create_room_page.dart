import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/room_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'prebuilt_audio_room_page.dart';

/// Create Room Dialog
/// Allows users to create new voice chat rooms
class CreateRoomDialog extends StatefulWidget {
  final RoomBloc roomBloc;
  final AuthBloc authBloc;

  const CreateRoomDialog({
    super.key,
    required this.roomBloc,
    required this.authBloc,
  });

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();

  /// Show create room dialog
  static Future<void> show(BuildContext context) {
    final roomBloc = context.read<RoomBloc>();
    final authBloc = context.read<AuthBloc>();

    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: roomBloc,
        child: BlocProvider.value(
          value: authBloc,
          child: CreateRoomDialog(
            roomBloc: roomBloc,
            authBloc: authBloc,
          ),
        ),
      ),
    );
  }
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedCategory = 'music';
  String _selectedRoomType = 'public';
  int _maxSpeakers = 10;

  // Available categories from blueprint.md
  final List<Map<String, dynamic>> _categories = [
    {'value': 'music', 'label': 'Music', 'icon': Icons.music_note},
    {'value': 'gaming', 'label': 'Gaming', 'icon': Icons.sports_esports},
    {'value': 'business', 'label': 'Business', 'icon': Icons.business},
    {'value': 'education', 'label': 'Education', 'icon': Icons.school},
    {'value': 'entertainment', 'label': 'Entertainment', 'icon': Icons.movie},
    {'value': 'sports', 'label': 'Sports', 'icon': Icons.sports_soccer},
    {'value': 'technology', 'label': 'Technology', 'icon': Icons.computer},
    {'value': 'lifestyle', 'label': 'Lifestyle', 'icon': Icons.style},
    {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
  ];

  // Room types from blueprint.md
  final List<Map<String, dynamic>> _roomTypes = [
    {
      'value': 'public',
      'label': 'Public',
      'description': 'Anyone can join',
      'icon': Icons.public
    },
    {
      'value': 'private',
      'label': 'Private',
      'description': 'Invite only',
      'icon': Icons.lock
    },
    {
      'value': 'friends_only',
      'label': 'Friends Only',
      'description': 'Only your friends can join',
      'icon': Icons.people
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _handleCreateRoom() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create a room')),
      );
      return;
    }

    // Parse tags from comma-separated string
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    context.read<RoomBloc>().add(
          CreateRoomRequested(
            title: _titleController.text.trim(),
            ownerId: authState.user.uid,
            category: _selectedCategory,
            tags: tags,
            roomType: _selectedRoomType,
            maxSpeakers: _maxSpeakers,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomBloc, RoomState>(
      listener: (context, state) {
        if (state is RoomCreated) {
          Navigator.of(context).pop(); // Close dialog

          // Navigate to the room as host (creator)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PrebuiltAudioRoomPage(
                room: state.room,
                isHost: true, // Creator is the host
              ),
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Room "${state.room.title}" created successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is RoomError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Create New Room',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Room Title *',
                            hintText: 'Enter an engaging room title',
                            prefixIcon: const Icon(Icons.title),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLength: 100,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a room title';
                            }
                            if (value.trim().length < 3) {
                              return 'Title must be at least 3 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Category selection
                        Text(
                          'Category *',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((category) {
                            final isSelected =
                                _selectedCategory == category['value'];
                            return FilterChip(
                              selected: isSelected,
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category['icon'] as IconData,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(category['label'] as String),
                                ],
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory =
                                      category['value'] as String;
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Room type selection
                        Text(
                          'Room Type *',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: _roomTypes.map((roomType) {
                            final isSelected =
                                _selectedRoomType == roomType['value'];
                            return RadioListTile<String>(
                              value: roomType['value'] as String,
                              groupValue: _selectedRoomType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRoomType = value!;
                                });
                              },
                              title: Row(
                                children: [
                                  Icon(roomType['icon'] as IconData),
                                  const SizedBox(width: 8),
                                  Text(roomType['label'] as String),
                                ],
                              ),
                              subtitle: Text(roomType['description'] as String),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Max speakers slider
                        Text(
                          'Max Speakers: $_maxSpeakers',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Slider(
                          value: _maxSpeakers.toDouble(),
                          min: 2,
                          max: 20,
                          divisions: 18,
                          label: _maxSpeakers.toString(),
                          onChanged: (value) {
                            setState(() {
                              _maxSpeakers = value.toInt();
                            });
                          },
                        ),
                        Text(
                          'Limit how many people can speak at once',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),

                        const SizedBox(height: 24),

                        // Tags field
                        TextFormField(
                          controller: _tagsController,
                          decoration: InputDecoration(
                            labelText: 'Tags (optional)',
                            hintText: 'music, jazz, live session',
                            helperText: 'Separate tags with commas',
                            prefixIcon: const Icon(Icons.tag),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLength: 200,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: BlocBuilder<RoomBloc, RoomState>(
                  builder: (context, state) {
                    final isCreating = state is RoomCreating;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isCreating
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: isCreating ? null : _handleCreateRoom,
                          icon: isCreating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add),
                          label:
                              Text(isCreating ? 'Creating...' : 'Create Room'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
