enum RequestStatus {
  pending('Pending'),
  accepted('Accepted'),
  rejected('Rejected');

  const RequestStatus(this.label);
  final String label;

  static RequestStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      default:
        return RequestStatus.pending;
    }
  }
}

class HiringRequest {
  const HiringRequest({
    required this.id,
    required this.senderUserId,
    required this.farmerId,
    required this.farmerName,
    required this.landLocation,
    required this.workType,
    required this.duration,
    required this.message,
    this.status = RequestStatus.pending,
    required this.createdAt,
  });

  final String id;
  final String senderUserId;
  final String farmerId;
  final String farmerName;
  final String landLocation;
  final String workType;
  final String duration;
  final String message;
  final RequestStatus status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderUserId': senderUserId,
    'farmerId': farmerId,
    'farmerName': farmerName,
    'landLocation': landLocation,
    'workType': workType,
    'duration': duration,
    'message': message,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HiringRequest.fromJson(Map<String, dynamic> json) => HiringRequest(
    id: json['id'] as String? ?? '',
    senderUserId: json['senderUserId'] as String? ?? '',
    farmerId: json['farmerId'] as String? ?? '',
    farmerName: json['farmerName'] as String? ?? '',
    landLocation: json['landLocation'] as String? ?? '',
    workType: json['workType'] as String? ?? '',
    duration: json['duration'] as String? ?? '',
    message: json['message'] as String? ?? '',
    status: RequestStatus.fromString(json['status'] as String? ?? 'pending'),
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
