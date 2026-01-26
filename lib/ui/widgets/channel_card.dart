import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../data/models/channel_model.dart';

class ChannelCard extends StatelessWidget {
  final UnifiedChannel channel;
  final VoidCallback onTap;
  final bool isFavorite;

  const ChannelCard({
    Key? key,
    required this.channel,
    required this.onTap,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {},
      child: Builder(builder: (context) {
        final isFocused = Focus.of(context).hasPrimaryFocus;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isFocused
                  ? AppTheme.primaryColor.withOpacity(0.15)
                  : AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFocused
                    ? AppTheme.accentColor
                    : Colors.white.withOpacity(0.1),
                width: isFocused ? 2 : 1,
              ),
              boxShadow: isFocused ? AppShadows.glowShadow : AppShadows.noShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: channel.logoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: channel.logoUrl!,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    AppTheme.accentColor,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                decoration: BoxDecoration(
                                  gradient: AppGradients.purpleToBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.tv,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 40,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: AppGradients.purpleToBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.tv,
                                size: 40,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                    ),
                  ),
                ),

                // Footer with channel info
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              channel.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (isFavorite)
                            Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.star,
                                size: 14,
                                color: AppTheme.warningColor,
                              ),
                            ),
                        ],
                      ),
                      if (channel.streams.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.signal_cellular_alt,
                              size: 12,
                              color: AppTheme.accentColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${channel.streams.length} stream${channel.streams.length > 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textHint,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
