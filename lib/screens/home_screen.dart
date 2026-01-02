import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hello_world/widgets/header.dart';
import '../models/event_model.dart';
import '../models/category_model.dart';
import '../services/event_service.dart';
import '../widgets/event_card.dart';
import '../widgets/bottom_nav_bar.dart';
import 'event_detail_screen.dart';
import 'registration_screen.dart';
import 'create_event_screen.dart'; // <--- 1. IMPORT ADDED

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- NAVIGATION STATE ---
  int _currentTabIndex = 0;

  // --- HOME FEED STATE ---
  final EventService _eventService = EventService();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  List<Event> _events = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;

  // Filters
  String _searchQuery = "";
  DateTime? _selectedDate;
  List<int> _selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();
    _initData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMoreEvents();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- DATA FETCHING ---
  Future<void> _initData() async {
    setState(() => _isLoading = true);
    final cats = await _eventService.getCategories();
    await _refreshEvents(initialCategories: cats);
  }

  Future<void> _refreshEvents({List<Category>? initialCategories}) async {
    setState(() {
      _isLoading = true;
      if (initialCategories != null) _categories = initialCategories;
      _events = [];
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final newEvents = await _eventService.getEvents(
        page: 1,
        searchQuery: _searchQuery,
        categoryIds: _selectedCategoryIds,
        selectedDate: _selectedDate,
      );

      if (mounted) {
        setState(() {
          _events = newEvents;
          _hasMore = newEvents.length >= 10;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error refresh: $e");
    }
  }

  Future<void> _loadMoreEvents() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final newEvents = await _eventService.getEvents(
        page: nextPage,
        categoryIds: _selectedCategoryIds,
        searchQuery: _searchQuery,
        selectedDate: _selectedDate,
      );

      if (mounted) {
        setState(() {
          if (newEvents.isEmpty) {
            _hasMore = false;
          } else {
            _events.addAll(newEvents);
            _currentPage = nextPage;
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  // --- FILTER HANDLERS ---
  void _onSearchChanged(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _refreshEvents());
  }

  void _onDateSelected(DateTime? date) {
    setState(() => _selectedDate = date);
    _refreshEvents();
  }

  void _onCategoriesChanged(List<int> ids) {
    setState(() => _selectedCategoryIds = ids);
    _refreshEvents();
  }

  // --- BUILDERS FOR TABS ---

  // Tab 0: Home Feed
  Widget _buildHomeFeed() {
    return Column(
      children: [
        HeaderWidget(
          selectedDate: _selectedDate,
          onDateSelect: _onDateSelected,
          availableCategories: _categories,
          selectedCategoryIds: _selectedCategoryIds,
          onCategoriesChanged: _onCategoriesChanged,
          searchTerm: _searchQuery,
          onSearchChange: _onSearchChanged,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _events.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.white.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  "No events found",
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: () => _refreshEvents(),
            color: const Color(0xFF6366F1),
            backgroundColor: Colors.white,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 10, bottom: 100), // Padding for BottomNav
              itemCount: _events.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _events.length) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: CircularProgressIndicator(color: Colors.white)),
                  );
                }
                return EventCard(
                  event: _events[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(
                        eventId: _events[index].documentId,
                        previewEvent: _events[index],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Tab 2: My Registrations Placeholder
  Widget _buildMyRegistrations() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, size: 80, color: Color(0xFF6366F1)),
          SizedBox(height: 16),
          Text("My Tickets", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Your booked events will appear here", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildHomeFeed(),             // Index 0
            const CreateEventScreen(),    // Index 1: <--- 2. WIRED UP HERE
            _buildMyRegistrations(),      // Index 2
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
            // Optional: Refresh Home when tapping Home tab
            if (index == 0) {
              _refreshEvents();
            }
          });
        },
      ),
    );
  }
}