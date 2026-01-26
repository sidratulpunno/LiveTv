import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
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
            child: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
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
        gridDelegate: SliverGridDelegateWithResponsiveMaxCrossAxisExtent(
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
          )
              .animate()
              .fadeIn(duration: 500.ms, curve: Curves.easeOut, delay: (index * 50).ms)
              .scale(begin: Offset(0.8, 0.8));
        },
      ),
    );
  }
}

class SliverGridDelegateWithResponsiveMaxCrossAxisExtent
    extends SliverGridDelegate {
  const SliverGridDelegateWithResponsiveMaxCrossAxisExtent({
    required this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  });

  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    int crossAxisCount =
        (constraints.crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing))
            .ceil();
    if (crossAxisCount < 1) crossAxisCount = 1;

    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - (crossAxisSpacing * (crossAxisCount - 1));
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent =
        childCrossAxisExtent / childAspectRatio;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.axisDirection),
    );
  }

  @override
  bool shouldRelayout(
      SliverGridDelegateWithResponsiveMaxCrossAxisExtent oldDelegate) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio;
  }
}
