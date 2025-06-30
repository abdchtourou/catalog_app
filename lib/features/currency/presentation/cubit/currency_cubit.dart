import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/usecases/get_currency_use_case.dart';
import '../../domain/usecases/update_currency_rate_use_case.dart';
import 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  final GetCurrencyUseCase getCurrencyUseCase;
  final UpdateCurrencyRateUseCase updateCurrencyRateUseCase;

  CurrencyCubit({
    required this.getCurrencyUseCase,
    required this.updateCurrencyRateUseCase,
  }) : super(CurrencyInitial());

  Future<void> getCurrency() async {
    emit(CurrencyLoading());

    final result = await getCurrencyUseCase();

    result.fold(
      (failure) => emit(CurrencyError('Failed to load currency'.tr())),
      (currency) => emit(CurrencyLoaded(currency)),
    );
  }

  Future<void> updateCurrencyRate(double rate) async {
    if (state is CurrencyLoaded) {
      final currentCurrency = (state as CurrencyLoaded).currency;
      emit(CurrencyUpdating());

      final result = await updateCurrencyRateUseCase(rate);

      result.fold(
        (failure) {
          emit(CurrencyError('Failed to update currency rate'.tr()));
          // Restore previous state after error
          Future.delayed(const Duration(seconds: 2), () {
            emit(CurrencyLoaded(currentCurrency));
          });
        },
        (_) {
          // Fetch updated currency data
          getCurrency();
        },
      );
    }
  }
}
