import 'package:flutter/material.dart';
import '../../data/models/channel_model.dart';
import '../widgets/channel_card.dart';
import 'player_screen.dart';

class CountryDetailScreen extends StatelessWidget {
  final String countryName;
  final List<UnifiedChannel> channels;

  const CountryDetailScreen({
    Key? key,
    required this.countryName,
    required this.channels
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F1014), // Deep dark background
      appBar: AppBar(
        backgroundColor: Color(0xFF0F1014),
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text(
          countryName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // Slightly wider cards
          childAspectRatio: 1.1,   // Better ratio for logos
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
          // Ensure your ChannelCard widget (not provided in snippet)
          // also uses rounded corners and dark backgrounds!
          return ChannelCard(
            channel: channel,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PlayerScreen(channel: channel)),
            ),
          );
        },
      ),
    );
  }
}