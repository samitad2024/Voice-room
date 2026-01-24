import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/usecases/approve_speaker_request.dart';
import '../../domain/usecases/reject_speaker_request.dart';

/// Widget to display and manage pending speaker requests
/// Shown only to room owners and admins
class SpeakerRequestsWidget extends StatelessWidget {
  final String roomId;
  final List<Map<String, dynamic>> requests;
  final VoidCallback onRequestProcessed;

  const SpeakerRequestsWidget({
    super.key,
    required this.roomId,
    required this.requests,
    required this.onRequestProcessed,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.mic_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Speaker Requests',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${requests.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Requests list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requests.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final request = requests[index];
              return _RequestTile(
                request: request,
                roomId: roomId,
                onProcessed: onRequestProcessed,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatefulWidget {
  final Map<String, dynamic> request;
  final String roomId;
  final VoidCallback onProcessed;

  const _RequestTile({
    required this.request,
    required this.roomId,
    required this.onProcessed,
  });

  @override
  State<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<_RequestTile> {
  bool _isProcessing = false;

  Future<void> _handleApprove() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final approveUseCase = di.sl<ApproveSpeakerRequest>();
      final result = await approveUseCase(
        ApproveSpeakerRequestParams(
          requestId: widget.request['id'],
          roomId: widget.roomId,
          userId: widget.request['user_id'],
        ),
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to approve: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_getUserName()} is now a speaker!',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            widget.onProcessed();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleReject() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final rejectUseCase = di.sl<RejectSpeakerRequest>();
      final result = await rejectUseCase(
        RejectSpeakerRequestParams(
          requestId: widget.request['id'],
        ),
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to reject: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Request from ${_getUserName()} declined'),
                duration: const Duration(seconds: 2),
              ),
            );
            widget.onProcessed();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _getUserName() {
    final users = widget.request['users'];
    if (users != null && users is Map) {
      return users['name'] ?? 'User';
    }
    return 'User';
  }

  String? _getUserPhotoUrl() {
    final users = widget.request['users'];
    if (users != null && users is Map) {
      return users['photo_url'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userName = _getUserName();
    final photoUrl = _getUserPhotoUrl();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            backgroundColor: colorScheme.primaryContainer,
            child: photoUrl == null
                ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'wants to speak',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          if (_isProcessing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decline button
                IconButton(
                  onPressed: _handleReject,
                  icon: const Icon(Icons.close),
                  color: colorScheme.error,
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                  ),
                ),
                const SizedBox(width: 8),
                // Approve button
                IconButton(
                  onPressed: _handleApprove,
                  icon: const Icon(Icons.check),
                  color: Colors.white,
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
