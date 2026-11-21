class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.avatarPath,
    this.isGuest = false,
  });

  final String name;
  final String email;
  final String phone;
  final String location;
  final String? avatarPath;
  final bool isGuest;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? avatarPath,
    bool? isGuest,
  }) => UserProfile(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    location: location ?? this.location,
    avatarPath: avatarPath ?? this.avatarPath,
    isGuest: isGuest ?? this.isGuest,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'location': location,
    'avatarPath': avatarPath,
    'isGuest': isGuest,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    location: json['location'] as String? ?? '',
    avatarPath: json['avatarPath'] as String?,
    isGuest: json['isGuest'] as bool? ?? false,
  );

  static const guest = UserProfile(
    name: 'Guest User',
    email: 'guest@baghbani.local',
    phone: 'Not provided',
    location: 'Pakistan',
    isGuest: true,
  );
}
