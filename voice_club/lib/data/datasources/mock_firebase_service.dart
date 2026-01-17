import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/gift_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/report_entity.dart';

class MockFirebaseService {
  static final MockFirebaseService _instance = MockFirebaseService._internal();
  factory MockFirebaseService() => _instance;
  MockFirebaseService._internal() {
    _initializeGifts();
  }

  final _uuid = const Uuid();
  UserModel? _currentUser;

  // In-memory storage for new features
  final List<GiftEntity> _gifts = [];
  final List<GiftTransactionEntity> _giftTransactions = [];
  final List<TransactionEntity> _transactions = [];
  final List<NotificationEntity> _notifications = [];
  final List<ReportEntity> _reports = [];

  void _initializeGifts() {
    _gifts.addAll([
      const GiftEntity(
        id: 'gift1',
        name: 'Rose',
        iconUrl: '🌹',
        coinsCost: 10,
        type: GiftType.rose,
      ),
      const GiftEntity(
        id: 'gift2',
        name: 'Heart',
        iconUrl: '❤️',
        coinsCost: 20,
        type: GiftType.heart,
      ),
      const GiftEntity(
        id: 'gift3',
        name: 'Star',
        iconUrl: '⭐',
        coinsCost: 50,
        type: GiftType.star,
      ),
      const GiftEntity(
        id: 'gift4',
        name: 'Diamond',
        iconUrl: '💎',
        coinsCost: 100,
        type: GiftType.diamond,
        isSpecial: true,
      ),
      const GiftEntity(
        id: 'gift5',
        name: 'Crown',
        iconUrl: '👑',
        coinsCost: 200,
        type: GiftType.crown,
        isSpecial: true,
      ),
      const GiftEntity(
        id: 'gift6',
        name: 'Rocket',
        iconUrl: '🚀',
        coinsCost: 500,
        type: GiftType.rocket,
        isSpecial: true,
      ),
    ]);
  }

  // Mock data - Enhanced users with new fields
  final List<UserModel> _users = [
    UserModel(
      id: '1',
      username: 'john_doe',
      fullName: 'John Doe',
      avatarUrl:
          'https://ui-avatars.com/api/?name=John+Doe&background=5B51D8&color=fff&size=200',
      bio: 'Tech enthusiast & startup founder 🚀',
      followersCount: 1234,
      followingCount: 567,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      isVerified: true,
      coins: 5000,
      totalCoinsEarned: 12000,
      totalCoinsSpent: 7000,
      isVIP: true,
      vipExpiryDate: DateTime.now().add(const Duration(days: 30)),
      legendLevel: LegendLevel.level3,
      totalGiftsReceived: 245,
      totalGiftsSent: 180,
      roomsHosted: 45,
      roomsJoined: 230,
      totalListeningHours: 520,
    ),
    UserModel(
      id: '2',
      username: 'sarah_smith',
      fullName: 'Sarah Smith',
      avatarUrl:
          'https://ui-avatars.com/api/?name=Sarah+Smith&background=FF69B4&color=fff&size=200',
      bio: 'Product designer & UX advocate ✨',
      followersCount: 2345,
      followingCount: 432,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      isVerified: true,
      coins: 8500,
      totalCoinsEarned: 15000,
      totalCoinsSpent: 6500,
      isVIP: true,
      vipExpiryDate: DateTime.now().add(const Duration(days: 60)),
      legendLevel: LegendLevel.level5,
      totalGiftsReceived: 456,
      totalGiftsSent: 320,
      roomsHosted: 67,
      roomsJoined: 345,
      totalListeningHours: 780,
    ),
    UserModel(
      id: '3',
      username: 'mike_wilson',
      fullName: 'Mike Wilson',
      avatarUrl:
          'https://ui-avatars.com/api/?name=Mike+Wilson&background=00C853&color=fff&size=200',
      bio: 'Developer & open source contributor 💻',
      followersCount: 890,
      followingCount: 321,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      isVerified: false,
      coins: 1200,
      totalCoinsEarned: 3500,
      totalCoinsSpent: 2300,
      isVIP: false,
      legendLevel: LegendLevel.level1,
      totalGiftsReceived: 89,
      totalGiftsSent: 65,
      roomsHosted: 23,
      roomsJoined: 156,
      totalListeningHours: 234,
    ),
    UserModel(
      id: '4',
      username: 'emily_brown',
      fullName: 'Emily Brown',
      avatarUrl:
          'https://ui-avatars.com/api/?name=Emily+Brown&background=FF9500&color=fff&size=200',
      bio: 'Marketing strategist & content creator 📱',
      followersCount: 3456,
      followingCount: 789,
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
      isVerified: true,
      coins: 6300,
      totalCoinsEarned: 11000,
      totalCoinsSpent: 4700,
      isVIP: true,
      vipExpiryDate: DateTime.now().add(const Duration(days: 45)),
      legendLevel: LegendLevel.level4,
      totalGiftsReceived: 334,
      totalGiftsSent: 245,
      roomsHosted: 56,
      roomsJoined: 289,
      totalListeningHours: 645,
    ),
    UserModel(
      id: '5',
      username: 'david_jones',
      fullName: 'David Jones',
      avatarUrl:
          'https://ui-avatars.com/api/?name=David+Jones&background=007AFF&color=fff&size=200',
      bio: 'Entrepreneur & investor 💼',
      followersCount: 5678,
      followingCount: 234,
      createdAt: DateTime.now().subtract(const Duration(days: 450)),
      isVerified: true,
      coins: 15000,
      totalCoinsEarned: 25000,
      totalCoinsSpent: 10000,
      isVIP: true,
      vipExpiryDate: DateTime.now().add(const Duration(days: 90)),
      legendLevel: LegendLevel.level5,
      totalGiftsReceived: 678,
      totalGiftsSent: 456,
      roomsHosted: 89,
      roomsJoined: 456,
      totalListeningHours: 1023,
    ),
  ];

  late final List<RoomModel> _rooms = [
    RoomModel(
      id: '1',
      title: 'The Future of AI in 2026',
      description:
          'Join us for an exciting discussion about artificial intelligence trends',
      category: 'Technology',
      status: RoomStatus.active,
      host: _users[0],
      participants: [
        RoomParticipant(
          user: _users[0],
          role: RoomRole.owner,
          isMuted: false,
          joinedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        RoomParticipant(
          user: _users[2],
          role: RoomRole.speaker,
          isMuted: false,
          joinedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        RoomParticipant(
          user: _users[3],
          role: RoomRole.listener,
          joinedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        RoomParticipant(
          user: _users[4],
          role: RoomRole.listener,
          joinedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ],
      participantCount: 234,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      tags: const ['AI', 'Technology', 'Innovation'],
    ),
    RoomModel(
      id: '2',
      title: 'Startup Funding Strategies',
      description: 'Learn from successful founders about raising capital',
      category: 'Business',
      status: RoomStatus.active,
      host: _users[4],
      participants: [
        RoomParticipant(
          user: _users[4],
          role: RoomRole.owner,
          isMuted: false,
          joinedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        RoomParticipant(
          user: _users[1],
          role: RoomRole.speaker,
          isMuted: false,
          joinedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        RoomParticipant(
          user: _users[2],
          role: RoomRole.listener,
          joinedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ],
      participantCount: 156,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      tags: const ['Startup', 'Funding', 'Business'],
    ),
  ];

  // Auth methods
  Future<UserModel> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = _users.firstWhere(
      (u) => u.username == username,
      orElse: () => _users[0],
    );

    _currentUser = user;
    return user;
  }

  Future<UserModel> signup({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final newUser = UserModel(
      id: _uuid.v4(),
      username: username,
      fullName: fullName,
      avatarUrl:
          'https://ui-avatars.com/api/?name=${fullName.replaceAll(' ', '+')}&background=random&size=200',
      bio: '',
      followersCount: 0,
      followingCount: 0,
      createdAt: DateTime.now(),
      isVerified: false,
      coins: 100, // Welcome bonus
    );

    _users.add(newUser);
    _currentUser = newUser;
    return newUser;
  }

  UserModel? getCurrentUser() {
    return _currentUser;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  // Room methods
  Future<List<RoomModel>> getActiveRooms() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _rooms.where((r) => r.status == RoomStatus.active).toList();
  }

  Future<List<RoomModel>> getScheduledRooms() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _rooms.where((r) => r.status == RoomStatus.scheduled).toList();
  }

  Future<List<RoomModel>> getTrendingRooms() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final trending = _rooms
        .where((r) => r.status == RoomStatus.active)
        .toList();
    trending.sort((a, b) => b.participantCount.compareTo(a.participantCount));
    return trending.take(3).toList();
  }

  Future<RoomModel> getRoomById(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _rooms.firstWhere((r) => r.id == roomId);
  }

  Future<RoomModel> joinRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _rooms.firstWhere((r) => r.id == roomId);
  }

  Future<void> leaveRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<RoomModel>> searchRooms(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _rooms
        .where(
          (r) =>
              r.title.toLowerCase().contains(query.toLowerCase()) ||
              r.description?.toLowerCase().contains(query.toLowerCase()) ==
                  true,
        )
        .toList();
  }

  Future<List<RoomModel>> getRoomsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _rooms
        .where((r) => r.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Future<RoomModel> createRoom({
    required String title,
    required String category,
    String? description,
    List<String>? tags,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (_currentUser == null) {
      throw Exception('User not logged in');
    }

    final newRoom = RoomModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      status: RoomStatus.active,
      host: _currentUser!,
      participants: [
        RoomParticipant(
          user: _currentUser!,
          role: RoomRole.owner,
          isMuted: false,
          joinedAt: DateTime.now(),
        ),
      ],
      participantCount: 1,
      createdAt: DateTime.now(),
      tags: tags ?? [],
    );

    _rooms.add(newRoom);
    return newRoom;
  }

  // Gifts methods
  Future<List<GiftEntity>> getAvailableGifts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_gifts);
  }

  Future<GiftTransactionEntity> sendGift({
    required String receiverId,
    required String giftId,
    String? roomId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final gift = _gifts.firstWhere((g) => g.id == giftId);
    final receiver = _users.firstWhere((u) => u.id == receiverId);

    // Deduct coins from sender
    if (_currentUser != null && _currentUser!.coins >= gift.coinsCost) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        username: _currentUser!.username,
        fullName: _currentUser!.fullName,
        avatarUrl: _currentUser!.avatarUrl,
        bio: _currentUser!.bio,
        followersCount: _currentUser!.followersCount,
        followingCount: _currentUser!.followingCount,
        createdAt: _currentUser!.createdAt,
        isVerified: _currentUser!.isVerified,
        coins: _currentUser!.coins - gift.coinsCost,
        totalCoinsSpent: _currentUser!.totalCoinsSpent + gift.coinsCost,
        totalGiftsSent: _currentUser!.totalGiftsSent + 1,
        isVIP: _currentUser!.isVIP,
        vipExpiryDate: _currentUser!.vipExpiryDate,
        legendLevel: _currentUser!.legendLevel,
        totalCoinsEarned: _currentUser!.totalCoinsEarned,
        totalGiftsReceived: _currentUser!.totalGiftsReceived,
        roomsHosted: _currentUser!.roomsHosted,
        roomsJoined: _currentUser!.roomsJoined,
        totalListeningHours: _currentUser!.totalListeningHours,
      );
    }

    final transaction = GiftTransactionEntity(
      id: _uuid.v4(),
      senderId: _currentUser!.id,
      senderName: _currentUser!.fullName,
      receiverId: receiverId,
      receiverName: receiver.fullName,
      gift: gift,
      timestamp: DateTime.now(),
      roomId: roomId,
    );

    _giftTransactions.add(transaction);

    // Create notification for receiver
    _notifications.add(
      NotificationEntity(
        id: _uuid.v4(),
        userId: receiverId,
        type: NotificationType.giftReceived,
        title: 'Gift Received!',
        message: '${_currentUser!.fullName} sent you a ${gift.name}',
        timestamp: DateTime.now(),
        imageUrl: gift.iconUrl,
      ),
    );

    return transaction;
  }

  Future<List<GiftTransactionEntity>> getGiftHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _giftTransactions
        .where((t) => t.senderId == userId || t.receiverId == userId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Wallet methods
  Future<void> purchaseCoins(int amount) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        username: _currentUser!.username,
        fullName: _currentUser!.fullName,
        avatarUrl: _currentUser!.avatarUrl,
        bio: _currentUser!.bio,
        followersCount: _currentUser!.followersCount,
        followingCount: _currentUser!.followingCount,
        createdAt: _currentUser!.createdAt,
        isVerified: _currentUser!.isVerified,
        coins: _currentUser!.coins + amount,
        totalCoinsEarned: _currentUser!.totalCoinsEarned + amount,
        totalCoinsSpent: _currentUser!.totalCoinsSpent,
        isVIP: _currentUser!.isVIP,
        vipExpiryDate: _currentUser!.vipExpiryDate,
        legendLevel: _currentUser!.legendLevel,
        totalGiftsReceived: _currentUser!.totalGiftsReceived,
        totalGiftsSent: _currentUser!.totalGiftsSent,
        roomsHosted: _currentUser!.roomsHosted,
        roomsJoined: _currentUser!.roomsJoined,
        totalListeningHours: _currentUser!.totalListeningHours,
      );

      _transactions.add(
        TransactionEntity(
          id: _uuid.v4(),
          userId: _currentUser!.id,
          type: TransactionType.coinPurchase,
          amount: amount,
          balanceAfter: _currentUser!.coins,
          timestamp: DateTime.now(),
          description: 'Purchased $amount coins',
        ),
      );
    }
  }

  Future<List<TransactionEntity>> getTransactions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _transactions.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // VIP methods
  Future<void> unlockVIP(int days) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (_currentUser != null) {
      final cost = days * 100; // 100 coins per day
      if (_currentUser!.coins >= cost) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          username: _currentUser!.username,
          fullName: _currentUser!.fullName,
          avatarUrl: _currentUser!.avatarUrl,
          bio: _currentUser!.bio,
          followersCount: _currentUser!.followersCount,
          followingCount: _currentUser!.followingCount,
          createdAt: _currentUser!.createdAt,
          isVerified: _currentUser!.isVerified,
          coins: _currentUser!.coins - cost,
          totalCoinsSpent: _currentUser!.totalCoinsSpent + cost,
          isVIP: true,
          vipExpiryDate: DateTime.now().add(Duration(days: days)),
          legendLevel: _currentUser!.legendLevel,
          totalCoinsEarned: _currentUser!.totalCoinsEarned,
          totalGiftsReceived: _currentUser!.totalGiftsReceived,
          totalGiftsSent: _currentUser!.totalGiftsSent,
          roomsHosted: _currentUser!.roomsHosted,
          roomsJoined: _currentUser!.roomsJoined,
          totalListeningHours: _currentUser!.totalListeningHours,
        );
      }
    }
  }

  // Notifications
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationEntity(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        type: _notifications[index].type,
        title: _notifications[index].title,
        message: _notifications[index].message,
        timestamp: _notifications[index].timestamp,
        isRead: true,
        imageUrl: _notifications[index].imageUrl,
        data: _notifications[index].data,
      );
    }
  }

  // User methods
  Future<UserModel> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _users.firstWhere((u) => u.id == userId);
  }

  Future<List<UserModel>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _users
        .where(
          (u) =>
              u.username.toLowerCase().contains(query.toLowerCase()) ||
              u.fullName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
