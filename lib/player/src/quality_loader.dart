import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

HLSQualityLoader? _loader;

HLSQualityLoader get hLSQualityLoader {
  _loader ??= HLSQualityLoader();
  return _loader!;
}

class HLSQualityLoader {
  final _dio = Dio();

  Future<List<String>> getQualities(String url) async {
    final response = await _dio.get(url,
        options: Options(
          receiveTimeout: const Duration(minutes: 1),
        ));
    if (response.statusCode != 200) {
      return [];
    }
    final String sData = response.data.toString();
    final List<String> list = [];
    if (sData.contains('#EXT-X-STREAM-INF:')) {
      for (final value in sData.split('#EXT-X-STREAM-INF:')) {
        List<String> informations = value.split(',');
        String trimmedUrl = informations.last.split('/n').last;
        if (trimmedUrl.contains('m3u8')) {
          if (trimmedUrl.contains('"')) {
            trimmedUrl = trimmedUrl.split('"').last.trim();
          }
          if (trimmedUrl.contains('\n')) {
            trimmedUrl = trimmedUrl.trim().split('\n').last.trim();
          }
          if (trimmedUrl.contains(' ')) {
            trimmedUrl = trimmedUrl.trim().split(' ').last.trim();
          }
          debugPrint(trimmedUrl);
          list.add(trimmedUrl);
        }
      }
    }
    return list;
  }
}
