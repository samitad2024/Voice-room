import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/pages/login_page.dart';
import '../../wallet/bloc/wallet_bloc.dart';
import '../../wallet/pages/wallet_page.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/room_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadActiveRoomsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? AppStrings.explore
              : _selectedIndex == 1
              ? AppStrings.myRooms
              : AppStrings.profile,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallet_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => sl<WalletBloc>(),
                    child: const WalletPage(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutEvent());
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => sl<AuthBloc>(),
                    child: const LoginPage(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildExplorePage() : _buildComingSoon(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'My Rooms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateRoomDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Start a Room'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildExplorePage() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(const RefreshRoomsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is SearchLoaded) {
          return _buildSearchResults(state);
        }

        if (state is HomeLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const RefreshRoomsEvent());
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppStrings.search,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<HomeBloc>().add(
                                  const LoadActiveRoomsEvent(),
                                );
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        context.read<HomeBloc>().add(SearchRoomsEvent(value));
                      } else {
                        context.read<HomeBloc>().add(
                          const LoadActiveRoomsEvent(),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Trending Rooms
                  if (state.trendingRooms.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      AppStrings.trending,
                      Icons.trending_up,
                    ),
                    const SizedBox(height: 12),
                    ...state.trendingRooms.map((room) => RoomCard(room: room)),
                    const SizedBox(height: 24),
                  ],

                  // Active Rooms
                  _buildSectionHeader(
                    context,
                    AppStrings.activeNow,
                    Icons.fiber_manual_record,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  if (state.activeRooms.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          AppStrings.noRoomsAvailable,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    )
                  else
                    ...state.activeRooms.map((room) => RoomCard(room: room)),

                  const SizedBox(height: 24),

                  // Upcoming Rooms
                  if (state.scheduledRooms.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      AppStrings.upcomingRooms,
                      Icons.schedule,
                    ),
                    const SizedBox(height: 12),
                    ...state.scheduledRooms.map((room) => RoomCard(room: room)),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchResults(SearchLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppStrings.search,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<HomeBloc>().add(const LoadActiveRoomsEvent());
                },
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                context.read<HomeBloc>().add(SearchRoomsEvent(value));
              } else {
                context.read<HomeBloc>().add(const LoadActiveRoomsEvent());
              }
            },
          ),

          const SizedBox(height: 24),

          Text(
            '${state.results.length} results for "${state.query}"',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          if (state.results.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No rooms found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ...state.results.map((room) => RoomCard(room: room)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildComingSoon() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Coming Soon',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This feature is under development',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Technology';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create New Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Room Title',
                  hintText: 'Enter room title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'What will you discuss?',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items:
                    [
                      'Technology',
                      'Business',
                      'Music',
                      'Sports',
                      'Lifestyle',
                      'Education',
                    ].map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                // In a real app, we would create the room here
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Room created successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
