import 'package:dio/dio.dart';

import '../../../../shared/constants/endpoints.dart';
import '../domain/entity/country_model.dart';

// ignore: one_member_abstracts
abstract class IHomeProvider {
  Future<List<CountriesItem>> getCountries();

  Future<Country> getCountry(String path);
}

class HomeProvider implements IHomeProvider {
  HomeProvider({Dio? client})
      : _dio = client ??
            Dio(
              BaseOptions(baseUrl: API_URL),
            );

  final Dio _dio;

  @override
  Future<List<CountriesItem>> getCountries() async {
    final response = await _dio.get<List<dynamic>>('/countries');
    return (response.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(CountriesItem.fromJson)
        .toList();
  }

  @override
  Future<Country> getCountry(String path) async {
    final response = await _dio.get<Map<String, dynamic>>('/country/$path');
    return Country.fromJson(response.data!);
  }
}
