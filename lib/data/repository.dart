import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import '../core/api_constants.dart';
import '../core/isolate_parser.dart';
import '../core/m3u_parser.dart';
import 'models/channel_model.dart';

class IptvRepository {
  final Dio _dio;
  final Box _cacheBox;

  IptvRepository(this._dio, this._cacheBox);

  Future<List<UnifiedChannel>> getChannels({bool forceRefresh = false}) async {
    try {
      final liveTvData = await rootBundle.loadString('lib/LiveTV.txt');
      final liveTvChannels = parseM3u(liveTvData);
      if (liveTvChannels.isNotEmpty) {
        return liveTvChannels;
      }
    } catch (_) {
    }

    return _getApiChannels(forceRefresh: forceRefresh);
  }

  Future<List<UnifiedChannel>> _getApiChannels({bool forceRefresh = false}) async {
    if (!forceRefresh && _cacheBox.containsKey('unified_channels')) {
      final cachedMap = Map<String, dynamic>.from(_cacheBox.get('unified_channels'));
      return await compute(parseAndMergeData, cachedMap);
    }

    try {
      final responses = await Future.wait([
        _dio.get(ApiConstants.channels),
        _dio.get(ApiConstants.streams),
        _dio.get(ApiConstants.logos),
        _dio.get(ApiConstants.blocklist),
        _dio.get(ApiConstants.countries),
      ]);

      final rawData = {
        'channels': responses[0].data,
        'streams': responses[1].data,
        'logos': responses[2].data,
        'blocklist': responses[3].data,
        'countries': responses[4].data,
      };

      await _cacheBox.put('unified_channels', rawData);

      return await compute(parseAndMergeData, rawData);
    } catch (e) {
      throw Exception('Failed to load channels: $e');
    }
  }
}