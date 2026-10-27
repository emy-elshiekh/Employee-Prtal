class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String type;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status;
  final DateTime createdAt;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: '${json['id']}',
      type: '${json['type'] ?? json['leave_type'] ?? ''}',
      fromDate: DateTime.parse('${json['from_date'] ?? json['fromDate']}'),
      toDate: DateTime.parse('${json['to_date'] ?? json['toDate']}'),
      reason: '${json['reason'] ?? ''}',
      status: '${json['status'] ?? 'Pending'}',
      createdAt: DateTime.tryParse('${json['created_at'] ?? json['createdAt'] ?? ''}') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'from_date': fromDate.toIso8601String().split('T').first,
        'to_date': toDate.toIso8601String().split('T').first,
        'reason': reason,
      };
}

class LeaveBalance {
  const LeaveBalance({
    required this.annualRemaining,
    required this.annualTotal,
    required this.sickRemaining,
  });

  final double annualRemaining;
  final double annualTotal;
  final double sickRemaining;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      annualRemaining: (json['annual_remaining'] as num?)?.toDouble() ?? 0,
      annualTotal: (json['annual_total'] as num?)?.toDouble() ?? 0,
      sickRemaining: (json['sick_remaining'] as num?)?.toDouble() ?? 0,
    );
  }
}
