import 'package:flutter/foundation.dart';
import '../data/models/channel_model.dart';
import '../data/models/stream_model.dart';

// ... imports

List<UnifiedChannel> parseAndMergeData(Map<String, dynamic> rawData) {
  final channelsData = rawData['channels'] as List;
  final streamsData = rawData['streams'] as List;
  final logosData = rawData['logos'] as List;
  final blocklistData = rawData['blocklist'] as List;
  final countriesData = rawData['countries'] as List; // New Data

  // 1. Build Country Map (Code -> {Name, Flag})
  final countryMap = <String, Map<String, String>>{};
  for (var c in countriesData) {
    countryMap[c['code']] = {
      'name': c['name'] ?? 'Unknown',
      'flag': c['flag'] ?? '🌍',
    };
  }

  // ... (StreamMap and LogoMap logic remains the same) ...
  final streamMap = <String, List<StreamModel>>{};
  for (var s in streamsData) {
    final stream = StreamModel.fromJson(s);
    if (stream.channelId != null) {
      streamMap.putIfAbsent(stream.channelId!, () => []).add(stream);
    }
  }

  final logoMap = <String, String>{};
  for (var l in logosData) {
    if (l['channel'] != null) logoMap[l['channel']] = l['url'];
  }

  final blockedIds = blocklistData.map((b) => b['channel']).toSet();

  final List<UnifiedChannel> unified = [];

  for (var c in channelsData) {
    final id = c['id'];
    if (blockedIds.contains(id)) continue;
    if (c['closed'] != null) continue;
    if (!streamMap.containsKey(id)) continue;

    // Resolve Country Name and Flag
    final countryCode = c['country'] ?? 'XX';
    final countryInfo = countryMap[countryCode] ?? {'name': 'International', 'flag': '🌍'};

    unified.add(UnifiedChannel(
      id: id,
      name: c['name'] ?? 'Unknown',
      // Store the full name (e.g., "United States") instead of "US"
      country: countryInfo['name']!,
      // Add a new field for the flag if you want, or append it to country name
      // For simplicity, we can store the flag in the category or a new field
      // Let's assume you added `final String countryFlag;` to UnifiedChannel model
      category: c['categories'] != null && (c['categories'] as List).isNotEmpty
          ? c['categories'][0]
          : 'General',
      isNsfw: c['is_nsfw'] ?? false,
      logoUrl: logoMap[id],
      streams: streamMap[id]!,
      // Quick hack: pass flag via a new field or reuse existing.
      // ideally add `final String flag;` to UnifiedChannel.
      flag: countryInfo['flag']!,
    ));
  }
  return unified;
}