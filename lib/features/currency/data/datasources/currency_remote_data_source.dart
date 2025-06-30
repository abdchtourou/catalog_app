import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/utils/logger.dart';
import '../models/currency_model.dart';

abstract class CurrencyRemoteDataSource {
  Future<CurrencyModel> getCurrency();
  Future<void> updateCurrencyRate(double rate);
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final ApiService apiService;

  CurrencyRemoteDataSourceImpl(this.apiService);

  @override
  Future<CurrencyModel> getCurrency() async {
    try {
      AppLogger.info('🔍 Fetching currency data');

      final response = await apiService.get(
        ApiConstants.getCurrenciesEndpoint(),
      );

      AppLogger.info('✅ Get currency response status: ${response.statusCode}');
      AppLogger.info('📦 Get currency response data: ${response.data}');

      return CurrencyModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('❌ Error getting currency data', e);
      throw ServerException();
    }
  }

  @override
  Future<void> updateCurrencyRate(double rate) async {
    try {
      AppLogger.info('🔄 Updating currency rate to: $rate');

      final response = await apiService.put(
        ApiConstants.updateCurrencyRateEndpoint(rate: rate),
      );

      AppLogger.info(
        '✅ Update currency rate response status: ${response.statusCode}',
      );
      AppLogger.info('📦 Update currency rate response data: ${response.data}');
    } catch (e) {
      AppLogger.error('❌ Error updating currency rate', e);
      throw ServerException();
    }
  }
}
