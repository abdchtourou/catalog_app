import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/currency_repository.dart';

class UpdateCurrencyRateUseCase {
  final CurrencyRepository repository;

  UpdateCurrencyRateUseCase(this.repository);

  Future<Either<Failure, void>> call(double rate) async {
    return await repository.updateCurrencyRate(rate);
  }
}
