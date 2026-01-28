import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final String selectedDay;
  final ValueChanged<String> onDaySelected;
  final List<String> days;

  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFFFF6B35), size: 20),
            SizedBox(width: 8),
            Text(
              'Select Day',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50, // Selector-এর উচ্চতা
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Infinite loop সিমুলেট করার জন্য একটি বড় সংখ্যা
            itemBuilder: (context, index) {
              // % operator ব্যবহার করে ইন্ডেক্সকে ০-৬ এর মধ্যে রাখা হয়
              final int realIndex = index % days.length;
              final String fullDayString = days[realIndex];
              final String displayName = fullDayString.split(' ')[0];
              final isSelected = selectedDay == fullDayString;

              return GestureDetector(
                onTap: () => onDaySelected(fullDayString),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)])
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}