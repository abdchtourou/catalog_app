import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/currency.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, Currency>> getCurrency();
  Future<Either<Failure, void>> updateCurrencyRate(double rate);
}
