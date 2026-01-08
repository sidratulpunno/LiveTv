import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
    // Focus widget allows navigation via D-Pad on Android TV
    return Focus(
      onFocusChange: (hasFocus) {},
      child: Builder(builder: (context) {
        final isFocused = Focus.of(context).hasPrimaryFocus;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isFocused ? Colors.blue.withOpacity(0.2) : Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: isFocused ? Border.all(color: Colors.blueAccent, width: 2) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: channel.logoUrl != null
                        ? CachedNetworkImage(
                      imageUrl: channel.logoUrl!,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => Icon(Icons.tv, color: Colors.white54),
                    )
                        : Icon(Icons.tv, size: 40, color: Colors.white54),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Colors.black54,
                  child: Column(
                    children: [
                      Text(
                        channel.name,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      if (isFavorite) Icon(Icons.star, size: 12, color: Colors.amber),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}