# IPTV Player

A cross-platform IPTV player built with Flutter. Supports live TV streaming from local M3U playlists and the [iptv-org](https://github.com/iptv-org/iptv) API with offline caching.

## Features

- **Dual source loading** — channels load from `LiveTV.txt` first, fall back to the iptv-org API if the file is unavailable
- **Live TV categories** — browse channels grouped by categories (BANGLA, English News, Islamic, Kids, Documentary, Indian-Bangla, MUSIC, Hindi, etc.)
- **IPTV-org integration** — thousands of free channels from around the world, organized by country
- **Video player** — built on `video_player` + `Chewie` with source switching, mute toggle, and fullscreen
- **Channel navigation** — previous/next buttons for quick browsing within a category
- **Search** — quick search across channel names, countries, and categories
- **Offline cache** — channel data is cached locally with Hive for offline access
- **Dark theme** — modern dark UI with animations and glass-morphism effects
- **Cross-platform** — Android, iOS, Web, Windows, macOS, Linux

## Screenshots

*(add screenshots here)*

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.0
- Dart SDK ^3.10.0

### Installation

```bash
git clone https://github.com/your-username/iptv_app.git
cd iptv_app
flutter pub get
flutter run
```

### Customizing Channels

Replace `lib/LiveTV.txt` with your own M3U playlist. The file uses standard M3U format:

```
#EXTM3U
#EXTINF:-1 tvg-logo="https://example.com/logo.png" group-title="CATEGORY",Channel Name
https://stream.example.com/playlist.m3u8
```

The `group-title` attribute determines the folder/category on the home screen.

## Architecture

```
lib/
├── core/
│   ├── api_constants.dart       # iptv-org API endpoints
│   ├── app_theme.dart           # Dark theme & styling
│   ├── isolate_parser.dart      # Background JSON parsing
│   └── m3u_parser.dart          # M3U playlist parser
├── data/
│   ├── models/
│   │   ├── channel_model.dart   # UnifiedChannel model
│   │   └── stream_model.dart    # StreamModel with URL, quality, headers
│   └── repository.dart          # Data source (M3U → API fallback)
├── logic/
│   └── providers.dart           # Riverpod state management
├── ui/
│   ├── screens/
│   │   ├── home_screen.dart     # Category/country folders
│   │   ├── country_detail_screen.dart  # Channel grid
│   │   └── player_screen.dart   # Video player with controls
│   ├── widgets/
│   │   └── channel_card.dart    # Channel tile with logo
│   ├── search_delegate.dart     # Search interface
│   └── utils/
│       └── fullscreen_helper.dart  # Fullscreen support
└── LiveTV.txt                   # Default M3U playlist
```

### State Management

The app uses **Riverpod** for dependency injection and state management:

- `channelListProvider` — async provider that fetches and caches channels
- `countriesProvider` — derived provider that groups channels into folders
- `settingsProvider` — manages user preferences (NSFW filter, favorites)

### Data Flow

```
LiveTV.txt (M3U) ──→ parseM3u()
     │ fail                    │
     ▼                         ▼
iptv-org API ──→ Hive cache ──→ UnifiedChannel[]
                                    │
                                    ▼
                          grouped by country/category
                                    │
                                    ▼
                          CountryFolder[] ──→ UI
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `dio` | HTTP client |
| `hive` / `hive_flutter` | Local caching |
| `video_player` | Video playback |
| `chewie` | Player controls UI |
| `cached_network_image` | Image caching |
| `google_fonts` | Typography |
| `flutter_animate` | Animations |
| `shimmer` | Loading placeholders |
| `audio_session` | Audio focus handling |

## License

This project is for educational purposes. Channel URLs are sourced from public M3U playlists and the iptv-org open database. Respect content providers' terms of service.
