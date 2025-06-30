import 'package:equatable/equatable.dart';
import '../../domain/entities/currency.dart';

abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object?> get props => [];
}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrencyLoaded extends CurrencyState {
  final Currency currency;

  const CurrencyLoaded(this.currency);

  @override
  List<Object?> get props => [currency];
}

class CurrencyError extends CurrencyState {
  final String message;

  const CurrencyError(this.message);

  @override
  List<Object?> get props => [message];
}

class CurrencyUpdating extends CurrencyState {}

class CurrencyUpdated extends CurrencyState {
  final Currency currency;

  const CurrencyUpdated(this.currency);

  @override
  List<Object?> get props => [currency];
}
