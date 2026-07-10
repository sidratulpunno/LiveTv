import '../data/models/channel_model.dart';
import '../data/models/stream_model.dart';

List<UnifiedChannel> parseM3u(String content) {
  final channels = <UnifiedChannel>[];
  final lines = content.split('\n');

  String? currentName;
  String? currentLogo;
  String? currentGroup;
  int index = 0;

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed == '#EXTM3U') continue;

    if (trimmed.startsWith('#EXTINF:')) {
      final logoMatch = RegExp(r'tvg-logo="([^"]*)"').firstMatch(trimmed);
      currentLogo = logoMatch?.group(1);

      final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(trimmed);
      currentGroup = groupMatch?.group(1) ?? 'Uncategorized';

      final commaIndex = trimmed.lastIndexOf(',');
      currentName = commaIndex >= 0
          ? trimmed.substring(commaIndex + 1).trim()
          : 'Unknown ${index++}';
      continue;
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      if (currentName != null) {
        channels.add(UnifiedChannel(
          id: 'livetv_$index',
          name: currentName,
          flag: '📺',
          country: currentGroup!,
          category: currentGroup,
          isNsfw: false,
          logoUrl: currentLogo,
          streams: [
            StreamModel(
              channelId: 'livetv_$index',
              url: trimmed,
            ),
          ],
        ));
        index++;
        currentName = null;
        currentLogo = null;
        currentGroup = null;
      }
    }
  }

  return channels;
}
