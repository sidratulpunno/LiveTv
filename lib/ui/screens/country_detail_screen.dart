import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            customBorder: const CircleBorder(),
            child: const Icon(Icons.arrow_back_ios,
                color: AppTheme.textPrimary),
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
            onTap: () => _openPlayer(context, channel),
          )
              .animate()
              .fadeIn(
                  duration: 400.ms,
                  curve: Curves.easeOut,
                  delay: (index * 50).ms)
              .slideY(begin: 0.15, end: 0);
        },
      ),
    );
  }

  void _openPlayer(BuildContext context, UnifiedChannel channel) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PlayerScreen(channel: channel),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }
}
