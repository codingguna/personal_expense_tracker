// lib/ui/statistics_page.dart
import 'package:flutter/material.dart';
import 'widgets/toggle_chip.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String period = 'Day';
  String type = 'Expense';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: const [
          Icon(Icons.download_outlined),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Period Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToggleChip(
                  values: const ['Day', 'Week', 'Month', 'Year'],
                  selected: period,
                  onChanged: (v) =>
                      setState(() => period = v),
                ),
                DropdownButton<String>(
                  value: type,
                  items: const [
                    DropdownMenuItem(
                        value: 'Expense', child: Text('Expense')),
                    DropdownMenuItem(
                        value: 'Income', child: Text('Income')),
                  ],
                  onChanged: (v) =>
                      setState(() => type = v!),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔹 Chart Placeholder (matches design)
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6F5),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Text(
                '$type Chart ($period)',
                style: const TextStyle(
                    color: Color(0xFF2F8F83)),
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Top Spending
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Top Spending',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
