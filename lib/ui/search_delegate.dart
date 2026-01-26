import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../data/models/channel_model.dart';
import '../logic/providers.dart';
import './screens/country_detail_screen.dart';
import './screens/player_screen.dart';

class IPTVSearchDelegate extends SearchDelegate {
  final List<UnifiedChannel> allChannels;
  final List<CountryFolder> allCountries;

  IPTVSearchDelegate(this.allChannels, this.allCountries);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return AppTheme.darkTheme().copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTheme.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        Container(
          margin: EdgeInsets.only(right: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => query = '',
              customBorder: CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.clear, color: AppTheme.textSecondary),
              ),
            ),
          ),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => close(context, null),
        customBorder: CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.arrow_back_ios,
              color: AppTheme.textPrimary, size: 20),
        ),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.toLowerCase();

    // 1. Filter Countries
    final countryMatches = allCountries
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();

    // 2. Filter Channels
    final channelMatches = allChannels
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.category.toLowerCase().contains(q)))
        .toList();

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppTheme.textHint),
            SizedBox(height: 16),
            Text(
              'Search channels & countries',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppTheme.textHint),
            ),
          ],
        ),
      );
    }

    if (countryMatches.isEmpty && channelMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textHint),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppTheme.textHint),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8),
      children: [
        // Section: Countries
        if (countryMatches.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              'Countries',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.accentColor,
                  ),
            ),
          ),
          ...countryMatches.map((country) {
            return _CountrySearchTile(country: country);
          }).toList(),
          SizedBox(height: 8),
        ],

        // Section: Channels
        if (channelMatches.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              'Channels',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.accentColor,
                  ),
            ),
          ),
          ...channelMatches.map((channel) {
            return _ChannelSearchTile(channel: channel);
          }).toList(),
        ]
      ],
    );
  }
}

class _CountrySearchTile extends StatelessWidget {
  final CountryFolder country;

  const _CountrySearchTile({
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CountryDetailScreen(
                countryName: country.name,
                channels: country.channels,
              ),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppGradients.purpleToBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(country.flag, style: TextStyle(fontSize: 24)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.play_circle_outline,
                            color: AppTheme.accentColor, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '${country.channelCount} channels',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: AppTheme.textHint, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelSearchTile extends StatelessWidget {
  final UnifiedChannel channel;

  const _ChannelSearchTile({
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerScreen(channel: channel),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppGradients.purpleToPink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.tv, color: Colors.white, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            channel.category,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.accentColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: AppTheme.textHint, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

