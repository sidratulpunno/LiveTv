import 'package:flutter/material.dart';
import 'package:iptv_app/ui/screens/country_detail_screen.dart';
import 'package:iptv_app/ui/screens/player_screen.dart';
import '../../data/models/channel_model.dart';
import '../../logic/providers.dart';
import 'package:iptv_app/ui/screens/player_screen.dart';
import 'package:iptv_app/ui/screens/country_detail_screen.dart';

class IPTVSearchDelegate extends SearchDelegate {
  final List<UnifiedChannel> allChannels;
  final List<CountryFolder> allCountries;

  IPTVSearchDelegate(this.allChannels, this.allCountries);

  @override
  ThemeData appBarTheme(BuildContext context) {
    // Match your app dark theme
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Color(0xFF121212),
      appBarTheme: AppBarTheme(backgroundColor: Color(0xFF1E1E1E)),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return BackButton();
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.toLowerCase();

    // 1. Filter Countries
    final countryMatches = allCountries.where((c) =>
        c.name.toLowerCase().contains(q)
    ).toList();

    // 2. Filter Channels
    final channelMatches = allChannels.where((c) =>
    c.name.toLowerCase().contains(q) ||
        (c.category.toLowerCase().contains(q))
    ).toList();

    return ListView(
      children: [
        // Section: Countries
        if (countryMatches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("Countries", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ...countryMatches.map((country) => ListTile(
            leading: Text(country.flag, style: TextStyle(fontSize: 24)),
            title: Text(country.name),
            subtitle: Text("${country.channelCount} channels"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CountryDetailScreen(countryName: country.name, channels: country.channels)
              ));
            },
          )),
        ],

        // Section: Channels
        if (channelMatches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("Channels", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ...channelMatches.map((channel) => ListTile(
            leading: Icon(Icons.tv, color: Colors.white70),
            title: Text(channel.name),
            subtitle: Text(channel.category),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PlayerScreen(channel: channel)
              ));
            },
          )),
        ]
      ],
    );
  }
}