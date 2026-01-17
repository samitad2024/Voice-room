import 'package:intl/intl.dart';

class DateFormatter {
  static String formatRoomTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 0) {
          return 'Started ${-difference.inMinutes}m ago';
        }
        return 'Starts in ${difference.inMinutes}m';
      }
      return 'Today at ${DateFormat.jm().format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow at ${DateFormat.jm().format(dateTime)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE, MMM d').format(dateTime);
    }
    return DateFormat('MMM d, y').format(dateTime);
  }

  static String formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
