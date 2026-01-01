// lib/widgets/event_card.dart
import 'dart:ui'; // Cần cho ImageFilter
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần package intl
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format Date: "Mon, Jan 1"
    final formattedDate = DateFormat('EEE, MMM d').format(event.date);
    // Format Time: "10:00 AM"
    final formattedTime = DateFormat('jm').format(event.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Tương ứng bg-surfaceLight (chỉnh thành trắng cho App Light Mode)
        borderRadius: BorderRadius.circular(24), // rounded-3xl
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- IMAGE SECTION ---
              SizedBox(
                height: 160, // h-40
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.network(
                        event.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    // Category Badge (Absolute top-left)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // backdrop-blur
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6), // bg-black/60
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Text(
                              event.categoryName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- CONTENT SECTION (p-5) ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 20, // text-xl
                        fontWeight: FontWeight.w600, // font-semibold
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      event.description,
                      maxLines: 2, // line-clamp-2
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14, // text-sm
                        color: Colors.grey[600], // text-secondary
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Footer Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Date & Time
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.blue[600]),
                                const SizedBox(width: 6),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 22), // Indent to align with text above
                              child: Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Right: Register Button (Circle with Arrow)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black, // bg-black (or white if dark mode)
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}