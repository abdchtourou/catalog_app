import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/currency.dart';
import '../repositories/currency_repository.dart';

class GetCurrencyUseCase {
  final CurrencyRepository repository;

  GetCurrencyUseCase(this.repository);

  Future<Either<Failure, Currency>> call() async {
    return await repository.getCurrency();
  }
}
