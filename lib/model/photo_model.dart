class PhotoModel {
  final String id;
  final dynamic user; // String (userId) hoặc Map<String, dynamic>
  final String imageUrl;
  final DateTime timestamp;
  final String? caption;

  PhotoModel({
    required this.id,
    required this.user,
    required this.imageUrl,
    required this.timestamp,
    this.caption,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['_id'] ?? '',
      user: json['userId'] is String
          ? json['userId']
          : Map<String, dynamic>.from(json['userId'] ?? {}),
      imageUrl: json['imageUrl'] ?? '',
      timestamp: DateTime.parse(
          json['timestamp'] ?? DateTime.now().toIso8601String()),
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': user,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'caption': caption,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PhotoModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
