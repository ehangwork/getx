import '../domain/adapters/repository_adapter.dart';
import '../domain/entity/country_model.dart';
import 'home_api_provider.dart';

class HomeRepository implements IHomeRepository {
  HomeRepository({required this.provider});
  final IHomeProvider provider;

  @override
  Future<List<CountriesItem>> getCountries() => provider.getCountries();

  @override
  Future<Country> getCountry(String path) => provider.getCountry(path);
}
