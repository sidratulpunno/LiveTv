import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/repository.dart';
import '../data/models/channel_model.dart';

// 1. Dependency Injection
final dioProvider = Provider((ref) => Dio());
final boxProvider = Provider((ref) => Hive.box('iptv_cache'));

final repositoryProvider = Provider((ref) {
  return IptvRepository(ref.read(dioProvider), ref.read(boxProvider));
});

// 2. User Settings State
class UserSettings {
  final bool showNsfw;
  final Set<String> favorites;

  UserSettings({this.showNsfw = false, this.favorites = const {}});

  UserSettings copyWith({bool? showNsfw, Set<String>? favorites}) {
    return UserSettings(
      showNsfw: showNsfw ?? this.showNsfw,
      favorites: favorites ?? this.favorites,
    );
  }
}

class UserSettingsNotifier extends StateNotifier<UserSettings> {
  UserSettingsNotifier() : super(UserSettings());

  void toggleNsfw() => state = state.copyWith(showNsfw: !state.showNsfw);

  void toggleFavorite(String id) {
    final newFavs = Set<String>.from(state.favorites);
    if (newFavs.contains(id)) {
      newFavs.remove(id);
    } else {
      newFavs.add(id);
    }
    state = state.copyWith(favorites: newFavs);
  }
}

// ... existing providers ...

// A class to hold country folder data
class CountryFolder {
  final String name;
  final String flag;
  final int channelCount;
  final List<UnifiedChannel> channels;

  CountryFolder(this.name, this.flag, this.channels)
      : channelCount = channels.length;
}

// Provider: Groups channels by Country
final countriesProvider = Provider<List<CountryFolder>>((ref) {
  final channelsAsync = ref.watch(channelListProvider);

  // Return empty if loading/error
  if (!channelsAsync.hasValue) return [];

  final channels = channelsAsync.value!;
  final Map<String, List<UnifiedChannel>> grouped = {};

  // Grouping Logic
  for (var channel in channels) {
    grouped.putIfAbsent(channel.country, () => []).add(channel);
  }

  // Convert to List<CountryFolder> and Sort
  final folders = grouped.entries.map((entry) {
    final firstChannel = entry.value.first; // Get flag from first channel
    return CountryFolder(
        entry.key,
        firstChannel.flag,
        entry.value
    );
  }).toList();

  // Sort alphabetically
  folders.sort((a, b) => a.name.compareTo(b.name));
  return folders;
});

final settingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  return UserSettingsNotifier();
});

// 3. Channel Data Provider
final channelListProvider = FutureProvider<List<UnifiedChannel>>((ref) async {
  final repo = ref.read(repositoryProvider);
  final channels = await repo.getChannels();
  final settings = ref.watch(settingsProvider);

  return channels.where((c) {
    if (c.isNsfw && !settings.showNsfw) return false;
    return true;
  }).toList();
});