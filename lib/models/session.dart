class CameraSession {
  final int? id;
  final String role;
  final String address;
  final int port;
  final DateTime startedAt;
  final DateTime? endedAt;

  const CameraSession({
    this.id,
    required this.role,
    required this.address,
    required this.port,
    required this.startedAt,
    this.endedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'role': role,
      'address': address,
      'port': port,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }

  factory CameraSession.fromMap(Map<String, Object?> map) {
    return CameraSession(
      id: map['id'] as int?,
      role: map['role'] as String,
      address: map['address'] as String,
      port: map['port'] as int,
      startedAt: DateTime.parse(
        map['started_at'] as String,
      ),
      endedAt: map['ended_at'] == null
          ? null
          : DateTime.parse(
              map['ended_at'] as String,
            ),
    );
  }
}
