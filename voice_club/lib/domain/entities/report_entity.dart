import 'package:equatable/equatable.dart';

enum ReportType { spam, harassment, inappropriate, other }

enum ReportStatus { pending, reviewed, resolved, dismissed }

class ReportEntity extends Equatable {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String reportedUserName;
  final String? roomId;
  final ReportType type;
  final String description;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminNotes;

  const ReportEntity({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedUserName,
    this.roomId,
    required this.type,
    required this.description,
    this.status = ReportStatus.pending,
    required this.createdAt,
    this.resolvedAt,
    this.adminNotes,
  });

  @override
  List<Object?> get props => [
    id,
    reporterId,
    reporterName,
    reportedUserId,
    reportedUserName,
    roomId,
    type,
    description,
    status,
    createdAt,
    resolvedAt,
    adminNotes,
  ];
}
