import 'package:flutter/material.dart';
import '../../domain/entities/gift.dart';

/// Gift Tray Widget - Bottom sheet to select and send gifts
/// Shows available gifts with animations based on category
class GiftTrayWidget extends StatefulWidget {
  final List<Gift> gifts;
  final List<String>
      recipients; // List of user IDs who can receive (speakers/owner)
  final Map<String, String> recipientNames; // userId -> name mapping
  final int userCoins;
  final Function(String giftId, String recipientId) onSendGift;

  const GiftTrayWidget({
    super.key,
    required this.gifts,
    required this.recipients,
    required this.recipientNames,
    required this.userCoins,
    required this.onSendGift,
  });

  @override
  State<GiftTrayWidget> createState() => _GiftTrayWidgetState();
}

class _GiftTrayWidgetState extends State<GiftTrayWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedRecipientId;
  String? _selectedGiftId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Auto-select first recipient if only one
    if (widget.recipients.length == 1) {
      _selectedRecipientId = widget.recipients.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Gift> _getGiftsByCategory(String category) {
    return widget.gifts.where((g) => g.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Send a Gift',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.userCoins}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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

          // Recipient selector
          if (widget.recipients.length > 1)
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.recipients.length,
                itemBuilder: (context, index) {
                  final recipientId = widget.recipients[index];
                  final name = widget.recipientNames[recipientId] ?? 'User';
                  final isSelected = _selectedRecipientId == recipientId;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRecipientId = recipientId;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name.length > 10
                                ? '${name.substring(0, 10)}...'
                                : name,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Category tabs
          TabBar(
            controller: _tabController,
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(text: 'Basic'),
              Tab(text: 'Premium'),
              Tab(text: 'Exclusive'),
            ],
          ),

          // Gift grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGiftGrid(_getGiftsByCategory('basic')),
                _buildGiftGrid(_getGiftsByCategory('premium')),
                _buildGiftGrid(_getGiftsByCategory('exclusive')),
              ],
            ),
          ),

          // Send button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _selectedRecipientId != null && _selectedGiftId != null
                          ? () {
                              widget.onSendGift(
                                  _selectedGiftId!, _selectedRecipientId!);
                              Navigator.pop(context);
                            }
                          : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _selectedRecipientId == null
                        ? 'Select a recipient'
                        : _selectedGiftId == null
                            ? 'Select a gift'
                            : 'Send Gift',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftGrid(List<Gift> gifts) {
    if (gifts.isEmpty) {
      return Center(
        child: Text(
          'No gifts available in this category',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        final gift = gifts[index];
        final isSelected = _selectedGiftId == gift.id;
        final canAfford = widget.userCoins >= gift.coinCost;

        return GestureDetector(
          onTap: canAfford
              ? () {
                  setState(() {
                    _selectedGiftId = gift.id;
                  });
                }
              : null,
          child: Opacity(
            opacity: canAfford ? 1.0 : 0.5,
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gift image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(gift.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Gift name
                  Text(
                    gift.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Coin cost
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 12,
                        color: canAfford ? Colors.amber : Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${gift.coinCost}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: canAfford
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
