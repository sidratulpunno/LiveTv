class StreamModel {
  final String? channelId;
  final String url;
  final String? userAgent;
  final String? referrer;
  final String? quality;

  StreamModel({
    this.channelId,
    required this.url,
    this.userAgent,
    this.referrer,
    this.quality,
  });

  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(
      channelId: json['channel'],
      url: json['url'],
      userAgent: json['user_agent'],
      referrer: json['referrer'],
      quality: json['quality'],
    );
  }
}