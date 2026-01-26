import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_theme.dart';
import '../../logic/providers.dart';
import '../search_delegate.dart';
import 'country_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries = ref.watch(countriesProvider);
    final allChannelsAsync = ref.watch(channelListProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover',
              style: Theme.of(context).textTheme.displayMedium,
            )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideX(begin: -0.2),
            SizedBox(height: 4),
            Text(
              'Browse all channels',
              style: Theme.of(context).textTheme.bodyMedium,
            )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut, delay: 100.ms)
                .slideX(begin: -0.2),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: AppGradients.purpleToBlue,
              shape: BoxShape.circle,
              boxShadow: AppShadows.glowShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (allChannelsAsync.hasValue) {
                    showSearch(
                      context: context,
                      delegate: IPTVSearchDelegate(
                        allChannelsAsync.value!,
                        countries,
                      ),
                    );
                  }
                },
                customBorder: CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.search, color: Colors.white, size: 22),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOut, delay: 200.ms)
              .scale(),
        ],
      ),
      body: allChannelsAsync.isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: () async {
                await ref.refresh(channelListProvider.future);
              },
              backgroundColor: AppTheme.darkSurface,
              color: AppTheme.accentColor,
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: countries.length,
                separatorBuilder: (ctx, i) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final folder = countries[index];

                  return _CountryCard(folder: folder, index: index);
                },
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (ctx, i) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 12,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CountryCard extends StatefulWidget {
  final dynamic folder;
  final int index;

  const _CountryCard({required this.folder, required this.index});

  @override
  State<_CountryCard> createState() => _CountryCardState();
}

class _CountryCardState extends State<_CountryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CountryDetailScreen(
                countryName: widget.folder.name,
                channels: widget.folder.channels,
              ),
            ),
          );
        },
        onHover: (hovering) {
          if (hovering) {
            _hoverController.forward();
          } else {
            _hoverController.reverse();
          }
        },
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + (_hoverController.value * 0.02),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1 +
                        (_hoverController.value * 0.15)),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(
                          _hoverController.value * 0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4 + (_hoverController.value * 4)),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Flag Circle with gradient background
                    Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppGradients.purpleToBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.folder.flag,
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                    SizedBox(width: 16),

                    // Text Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.folder.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.play_circle_outline,
                                  color: AppTheme.accentColor, size: 16),
                              SizedBox(width: 6),
                              Text(
                                '${widget.folder.channelCount} Channels',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon with animation
                    Transform.rotate(
                      angle: _hoverController.value * 0.3,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(0.5 +
                            (_hoverController.value * 0.5)),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut, delay: (widget.index * 100).ms)
        .slideY(begin: 0.2, end: 0);
  }
}
