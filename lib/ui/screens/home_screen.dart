import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers.dart';
import '../search_delegate.dart';
import 'country_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries = ref.watch(countriesProvider);
    final allChannelsAsync = ref.watch(channelListProvider);

    return Scaffold(
      backgroundColor: Color(0xFF0F1014), // Deep dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Discover',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search, color: Colors.white),
            ),
            onPressed: () {
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
          ),
          SizedBox(width: 16),
        ],
      ),
      body: allChannelsAsync.isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: countries.length,
        separatorBuilder: (ctx, i) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final folder = countries[index];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CountryDetailScreen(
                      countryName: folder.name,
                      channels: folder.channels,
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Color(0xFF1D1F24), // Card color
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    // Flag Circle
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        folder.flag,
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                    SizedBox(width: 16),

                    // Text Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            folder.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${folder.channelCount} Channels',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white24, size: 18),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}