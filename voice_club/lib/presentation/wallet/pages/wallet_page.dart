import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/transaction_entity.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const LoadWalletEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Wallet'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is CoinsPurchased) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✨ ${state.amount} coins added to your wallet!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is VIPUnlocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🌟 VIP unlocked successfully!'),
                backgroundColor: Colors.amber,
              ),
            );
          }
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletLoaded ||
              state is CoinsPurchased ||
              state is VIPUnlocked) {
            final user = state is WalletLoaded
                ? state.user
                : state is CoinsPurchased
                ? state.user
                : (state as VIPUnlocked).user;

            final transactions = state is WalletLoaded
                ? state.transactions
                : <TransactionEntity>[];

            return CustomScrollView(
              slivers: [
                // Coin Balance Card
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${user.coins}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Coins',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (user.hasActiveVIP)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.workspace_premium,
                                      size: 16,
                                      color: Colors.black87,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'VIP Member',
                                      style: TextStyle(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (user.hasActiveVIP) const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.stars,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.legendLevelName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.add_circle,
                            label: 'Buy Coins',
                            color: Colors.green,
                            onTap: () => _showCoinPurchaseDialog(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.workspace_premium,
                            label: 'Unlock VIP',
                            color: Colors.amber,
                            onTap: () => _showVIPUnlockDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.trending_up,
                            label: 'Earned',
                            value: '${user.totalCoinsEarned}',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.trending_down,
                            label: 'Spent',
                            value: '${user.totalCoinsSpent}',
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.card_giftcard,
                            label: 'Gifts',
                            value: '${user.totalGiftsReceived}',
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Transaction History Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Transaction List
                if (transactions.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final transaction = transactions[index];
                      return _TransactionItem(transaction: transaction);
                    }, childCount: transactions.length),
                  ),
              ],
            );
          }

          return const Center(child: Text('Failed to load wallet'));
        },
      ),
    );
  }

  void _showCoinPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buy Coins'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CoinPackage(
              coins: 100,
              price: '\$0.99',
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<WalletBloc>().add(const PurchaseCoinsEvent(100));
              },
            ),
            const SizedBox(height: 12),
            _CoinPackage(
              coins: 500,
              price: '\$4.99',
              badge: '🔥 Popular',
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<WalletBloc>().add(const PurchaseCoinsEvent(500));
              },
            ),
            const SizedBox(height: 12),
            _CoinPackage(
              coins: 1000,
              price: '\$8.99',
              badge: '💎 Best Value',
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<WalletBloc>().add(const PurchaseCoinsEvent(1000));
              },
            ),
            const SizedBox(height: 12),
            _CoinPackage(
              coins: 5000,
              price: '\$39.99',
              badge: '👑 VIP Pack',
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<WalletBloc>().add(const PurchaseCoinsEvent(5000));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showVIPUnlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('🌟 Unlock VIP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('VIP Benefits:'),
            const SizedBox(height: 8),
            const Text('• Exclusive VIP badge'),
            const Text('• Priority room access'),
            const Text('• Special gift effects'),
            const Text('• Ad-free experience'),
            const SizedBox(height: 16),
            _VIPPackage(
              days: 7,
              price: '700 Coins',
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<WalletBloc>().add(const UnlockVIPEvent(7));
              },
            ),
            const SizedBox(height: 12),
            _VIPPackage(
              days: 30,
              price: '3000 Coins',
              badge: '🔥 Popular',
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<WalletBloc>().add(const UnlockVIPEvent(30));
              },
            ),
            const SizedBox(height: 12),
            _VIPPackage(
              days: 90,
              price: '8000 Coins',
              badge: '💎 Best Value',
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<WalletBloc>().add(const UnlockVIPEvent(90));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionEntity transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final icon = _getTransactionIcon(transaction.type);
    final color = isCredit ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ??
                      _getTransactionDescription(transaction.type),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'MMM dd, yyyy • hh:mm a',
                  ).format(transaction.timestamp),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${transaction.amount}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.coinPurchase:
        return Icons.add_shopping_cart;
      case TransactionType.giftSent:
        return Icons.card_giftcard;
      case TransactionType.giftReceived:
        return Icons.redeem;
      case TransactionType.vipUnlock:
        return Icons.workspace_premium;
      case TransactionType.rewardEarned:
        return Icons.emoji_events;
      case TransactionType.refund:
        return Icons.refresh;
    }
  }

  String _getTransactionDescription(TransactionType type) {
    switch (type) {
      case TransactionType.coinPurchase:
        return 'Coins Purchased';
      case TransactionType.giftSent:
        return 'Gift Sent';
      case TransactionType.giftReceived:
        return 'Gift Received';
      case TransactionType.vipUnlock:
        return 'VIP Unlocked';
      case TransactionType.rewardEarned:
        return 'Reward Earned';
      case TransactionType.refund:
        return 'Refund';
    }
  }
}

class _CoinPackage extends StatelessWidget {
  final int coins;
  final String price;
  final String? badge;
  final VoidCallback onTap;

  const _CoinPackage({
    required this.coins,
    required this.price,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$coins Coins',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Text(badge!, style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class _VIPPackage extends StatelessWidget {
  final int days;
  final String price;
  final String? badge;
  final VoidCallback onTap;

  const _VIPPackage({
    required this.days,
    required this.price,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$days Days VIP',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Text(badge!, style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
