import 'stream_model.dart';

class UnifiedChannel {
  final String id;
  final String name;
  final String flag;
  final String country;
  final String category;
  final bool isNsfw;
  final String? logoUrl;
  final List<StreamModel> streams;

  UnifiedChannel({
    required this.id,
    required this.name,
    required this.flag,
    required this.country,
    required this.category,
    required this.isNsfw,
    this.logoUrl,
    required this.streams,
  });
}