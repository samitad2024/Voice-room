import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(WalletInitial()) {
    on<LoadWalletEvent>(_onLoadWallet);
    on<PurchaseCoinsEvent>(_onPurchaseCoins);
    on<UnlockVIPEvent>(_onUnlockVIP);
  }

  Future<void> _onLoadWallet(
    LoadWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final userResult = await walletRepository.getCurrentUser();

    await userResult.fold(
      (failure) async => emit(const WalletError('Failed to load wallet')),
      (user) async {
        final transactionsResult = await walletRepository.getTransactions(
          user.id,
        );

        transactionsResult.fold(
          (failure) => emit(const WalletError('Failed to load transactions')),
          (transactions) =>
              emit(WalletLoaded(user: user, transactions: transactions)),
        );
      },
    );
  }

  Future<void> _onPurchaseCoins(
    PurchaseCoinsEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final purchaseResult = await walletRepository.purchaseCoins(event.amount);

    await purchaseResult.fold(
      (failure) async => emit(const WalletError('Failed to purchase coins')),
      (_) async {
        final userResult = await walletRepository.getCurrentUser();

        await userResult.fold(
          (failure) async =>
              emit(const WalletError('Failed to load updated wallet')),
          (user) async {
            emit(CoinsPurchased(user: user, amount: event.amount));

            // Load wallet again to show updated data
            final transactionsResult = await walletRepository.getTransactions(
              user.id,
            );

            transactionsResult.fold(
              (failure) =>
                  emit(const WalletError('Failed to load transactions')),
              (transactions) =>
                  emit(WalletLoaded(user: user, transactions: transactions)),
            );
          },
        );
      },
    );
  }

  Future<void> _onUnlockVIP(
    UnlockVIPEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final unlockResult = await walletRepository.unlockVIP(event.days);

    await unlockResult.fold(
      (failure) async => emit(const WalletError('Failed to unlock VIP')),
      (_) async {
        final userResult = await walletRepository.getCurrentUser();

        await userResult.fold(
          (failure) async =>
              emit(const WalletError('Failed to load updated wallet')),
          (user) async {
            emit(VIPUnlocked(user));

            // Load wallet again to show updated data
            final transactionsResult = await walletRepository.getTransactions(
              user.id,
            );

            transactionsResult.fold(
              (failure) =>
                  emit(const WalletError('Failed to load transactions')),
              (transactions) =>
                  emit(WalletLoaded(user: user, transactions: transactions)),
            );
          },
        );
      },
    );
  }
}
