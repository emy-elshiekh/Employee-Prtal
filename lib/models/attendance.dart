class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    this.checkIn,
    this.checkOut,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.status = 'not_checked_in',
  });

  final String id;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String status;

  bool get isCheckedIn => checkIn != null && checkOut == null;
  bool get isCheckedOut => checkIn != null && checkOut != null;

  String get displayStatus {
    if (isCheckedOut) return 'Checked out';
    if (isCheckedIn) return 'Checked in';
    return 'Not checked in';
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: '${json['id'] ?? ''}',
      checkIn: json['check_in'] != null ? DateTime.tryParse('${json['check_in']}') : null,
      checkOut: json['check_out'] != null ? DateTime.tryParse('${json['check_out']}') : null,
      checkInLatitude: (json['check_in_latitude'] as num?)?.toDouble(),
      checkInLongitude: (json['check_in_longitude'] as num?)?.toDouble(),
      checkOutLatitude: (json['check_out_latitude'] as num?)?.toDouble(),
      checkOutLongitude: (json['check_out_longitude'] as num?)?.toDouble(),
      status: '${json['status'] ?? 'not_checked_in'}',
    );
  }
}

class AttendancePayload {
  const AttendancePayload({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };
}
