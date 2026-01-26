import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../data/models/channel_model.dart';
import '../widgets/channel_card.dart';
import 'player_screen.dart';

class CountryDetailScreen extends StatelessWidget {
  final String countryName;
  final List<UnifiedChannel> channels;

  const CountryDetailScreen({
    Key? key,
    required this.countryName,
    required this.channels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        leading: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            customBorder: CircleBorder(),
            child: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              countryName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '${channels.length} Channels Available',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.fromLTRB(12, 16, 12, 24),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
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
