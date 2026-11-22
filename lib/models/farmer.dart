class Farmer {
  const Farmer({
    required this.id,
    required this.userId,
    required this.name,
    required this.location,
    required this.experienceYears,
    required this.skills,
    required this.services,
    required this.availability,
    required this.rating,
    required this.description,
    this.profileImage,
    this.reviewsCount = 0,
    this.dailyRate = 'Rs. 2,000 / day',
    this.phone = '0300 0000000',
  });

  final String id;
  final String userId;
  final String name;
  final String location;
  final int experienceYears;
  final List<String> skills;
  final List<String> services;
  final bool availability;
  final double rating;
  final String description;
  final String? profileImage;
  final int reviewsCount;
  final String dailyRate;
  final String phone;

  Farmer copyWith({
    String? id,
    String? userId,
    String? name,
    String? location,
    int? experienceYears,
    List<String>? skills,
    List<String>? services,
    bool? availability,
    double? rating,
    String? description,
    String? profileImage,
    int? reviewsCount,
    String? dailyRate,
    String? phone,
  }) => Farmer(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    location: location ?? this.location,
    experienceYears: experienceYears ?? this.experienceYears,
    skills: skills ?? this.skills,
    services: services ?? this.services,
    availability: availability ?? this.availability,
    rating: rating ?? this.rating,
    description: description ?? this.description,
    profileImage: profileImage ?? this.profileImage,
    reviewsCount: reviewsCount ?? this.reviewsCount,
    dailyRate: dailyRate ?? this.dailyRate,
    phone: phone ?? this.phone,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'location': location,
    'experienceYears': experienceYears,
    'skills': skills,
    'services': services,
    'availability': availability,
    'rating': rating,
    'description': description,
    'profileImage': profileImage,
    'reviewsCount': reviewsCount,
    'dailyRate': dailyRate,
    'phone': phone,
  };

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
    id: json['id'] as String? ?? '',
    userId: json['userId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    location: json['location'] as String? ?? '',
    experienceYears: json['experienceYears'] as int? ?? 1,
    skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    services: (json['services'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    availability: json['availability'] as bool? ?? true,
    rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    description: json['description'] as String? ?? '',
    profileImage: json['profileImage'] as String?,
    reviewsCount: json['reviewsCount'] as int? ?? 0,
    dailyRate: json['dailyRate'] as String? ?? 'Rs. 2,000 / day',
    phone: json['phone'] as String? ?? '',
  );
}
