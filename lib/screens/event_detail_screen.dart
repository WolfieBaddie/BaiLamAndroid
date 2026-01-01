import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import 'registration_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  final Event? previewEvent; // Optional: Pass data from Home for instant load

  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.previewEvent,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  // Theme Colors
  final Color _backgroundColor = const Color(0xFF111827);
  final Color _surfaceColor = const Color(0xFF1F2937);
  final Color _primaryColor = const Color(0xFF6366F1);

  final EventService _eventService = EventService();
  late Future<Event?> _eventFuture;

  @override
  void initState() {
    super.initState();
    // Fetch fresh data (in case description is long or data updated)
    _eventFuture = _eventService.getEventDetails(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: FutureBuilder<Event?>(
        future: _eventFuture,
        initialData: widget.previewEvent, // Show preview while loading
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && widget.previewEvent == null) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            return Center(child: Text("Event not found", style: TextStyle(color: Colors.grey[400])));
          }

          final event = snapshot.data;
          if (event == null) return const SizedBox(); // Should not happen

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // --- 1. APP BAR WITH IMAGE ---
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: _backgroundColor,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            event.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: _surfaceColor),
                          ),
                          // Gradient Overlay for text readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  _backgroundColor.withOpacity(0.8),
                                  _backgroundColor,
                                ],
                                stops: const [0.0, 0.8, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- 2. CONTENT ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _primaryColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              event.categoryName,
                              style: TextStyle(
                                color: _primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Title
                          Text(
                            event.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Date & Time Row
                          Row(
                            children: [
                              _buildInfoItem(
                                  Icons.calendar_today,
                                  DateFormat('EEE, MMM d, yyyy').format(event.date)
                              ),
                              const SizedBox(width: 24),
                              _buildInfoItem(
                                  Icons.access_time,
                                  DateFormat('jm').format(event.date)
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),
                          Divider(color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 24),

                          // Description
                          const Text(
                            "About Event",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[300],
                              height: 1.6,
                            ),
                          ),

                          // Extra space for bottom button
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // --- 3. BOTTOM ACTION BUTTON ---
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationScreen(event: event),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Register Now",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey[400], size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}