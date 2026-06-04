import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../data/models/channel_model.dart';

class ChannelCard extends StatefulWidget {
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
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 250),
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
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _hoverController.forward();
        } else {
          _hoverController.reverse();
        }
      },
      child: Builder(builder: (context) {
        final isFocused = Focus.of(context).hasPrimaryFocus;

        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _hoverController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (_hoverController.value * 0.03),
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
                    boxShadow: isFocused
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor
                                  .withOpacity(_hoverController.value * 0.4),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                            child: widget.channel.logoUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: widget.channel.logoUrl!,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) =>
                                        Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child:
                                            CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation(
                                            AppTheme.accentColor,
                                          ),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        gradient:
                                            AppGradients.purpleToBlue,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.tv,
                                        color: Colors.white
                                            .withOpacity(0.7),
                                        size: 40,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient:
                                          AppGradients.purpleToBlue,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.tv,
                                      size: 40,
                                      color: Colors.white
                                          .withOpacity(0.7),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
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
                                    widget.channel.name,
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
                                if (widget.isFavorite)
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
                            if (widget.channel.streams.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.signal_cellular_alt,
                                    size: 12,
                                    color: AppTheme.accentColor,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${widget.channel.streams.length} stream${widget.channel.streams.length > 1 ? 's' : ''}',
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
            },
          ),
        );
      }),
    );
  }
}
