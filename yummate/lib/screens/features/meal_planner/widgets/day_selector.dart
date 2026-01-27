import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final String selectedDay;
  final ValueChanged<String> onDaySelected;

  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFFFF6B35), size: 20),
            SizedBox(width: 8),
            Text(
              'Select Day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => GestureDetector(
                    onTap: () => onDaySelected(day),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: selectedDay == day
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFFFF6B35),
                                  Color(0xFFFF8C42),
                                ],
                              )
                            : null,
                        color: selectedDay == day ? null : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedDay == day
                              ? Colors.transparent
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: selectedDay == day
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFF6B35,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedDay == day
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
