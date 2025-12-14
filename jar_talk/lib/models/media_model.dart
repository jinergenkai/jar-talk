class Media {
  final int id;
  final int slipId;
  final String mediaType;
  final String storageUrl;
  final String downloadUrl;

  Media({
    required this.id,
    required this.slipId,
    required this.mediaType,
    required this.storageUrl,
    required this.downloadUrl,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['media_id'] ?? 0,
      slipId: json['slip_id'] ?? 0,
      mediaType: json['media_type'] ?? 'unknown',
      storageUrl: json['storage_url'] ?? '',
      downloadUrl: json['download_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'slip_id': slipId,
    'media_type': mediaType,
    'storage_url': storageUrl,
  };
}
