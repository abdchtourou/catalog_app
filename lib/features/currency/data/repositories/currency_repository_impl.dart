import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/currency.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_remote_data_source.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CurrencyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Currency>> getCurrency() async {
    try {
      if (await networkInfo.isConnected) {
        final currency = await remoteDataSource.getCurrency();
        return Right(currency);
      } else {
        return Left(OfflineFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateCurrencyRate(double rate) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateCurrencyRate(rate);
        return const Right(null);
      } else {
        return Left(OfflineFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
