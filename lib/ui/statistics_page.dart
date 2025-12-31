// lib/ui/statistics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../expenses/expense_provider.dart';
import '../income/income_provider.dart';
import 'widgets/bottom_nav_bar.dart';

enum StatsPeriod { day, week, month, year }
enum StatsType { expense, income }

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  StatsPeriod period = StatsPeriod.day;
  StatsType type = StatsType.expense;

  int? selectedIndex;

  List<FlSpot> _spots = [];
  List<String> _labels = [];
  List<double> _values = [];

  DateTime _safe(DateTime? d) => d?.toLocal() ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseListProvider).value ?? [];
    final incomes = ref.watch(incomeListProvider).value ?? [];

    _buildStats(expenses, incomes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          /// PERIOD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: StatsPeriod.values.map((p) {
                final selected = p == period;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.name),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        period = p;
                        selectedIndex = null;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          /// TYPE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<StatsType>(
              value: type,
              items: const [
                DropdownMenuItem(
                  value: StatsType.expense,
                  child: Text('Expense'),
                ),
                DropdownMenuItem(
                  value: StatsType.income,
                  child: Text('Income'),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  type = v!;
                  selectedIndex = null;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          /// CHART
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildChart(),
          ),

          const SizedBox(height: 16),

          /// LIST (SYNCED)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              itemCount: _labels.length,
              itemBuilder: (_, i) {
                final isSelected = i == selectedIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = i);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2F8F83)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _labels[i],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹${_values[i].toStringAsFixed(0)}',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : type == StatsType.expense
                                    ? Colors.red
                                    : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // ================= AGGREGATION =================

  void _buildStats(List expenses, List incomes) {
    final source =
        type == StatsType.expense ? expenses : incomes;

    switch (period) {
      case StatsPeriod.day:
        _buildDay(source);
        break;
      case StatsPeriod.week:
        _buildWeek(source);
        break;
      case StatsPeriod.month:
        _buildMonth(source);
        break;
      case StatsPeriod.year:
        _buildYear(source);
        break;
    }
  }

  void _buildDay(List items) {
    final now = DateTime.now();
    final totals = List<double>.filled(24, 0);

    for (final i in items) {
      final t = _safe(i.createdAt);
      if (_sameDay(t, now)) {
        totals[t.hour] += i.amount;
      }
    }

    _labels = List.generate(
      24,
      (h) =>
          '${h == 0 ? 12 : h > 12 ? h - 12 : h} ${h < 12 ? 'AM' : 'PM'}',
    );
    _values = totals;
    _spots = List.generate(
      24,
      (i) => FlSpot(i.toDouble(), totals[i]),
    );
  }

  void _buildWeek(List items) {
    final now = DateTime.now();
    final start =
        now.subtract(Duration(days: now.weekday - 1));

    final totals = List<double>.filled(7, 0);

    for (final i in items) {
      final t = _safe(i.createdAt);
      if (!t.isBefore(start)) {
        totals[t.weekday - 1] += i.amount;
      }
    }

    _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    _values = totals;
    _spots = List.generate(
      7,
      (i) => FlSpot(i.toDouble(), totals[i]),
    );
  }

  void _buildMonth(List items) {
    final now = DateTime.now();
    final totals = List<double>.filled(5, 0);

    for (final i in items) {
      final t = _safe(i.createdAt);
      if (t.year == now.year && t.month == now.month) {
        final w = ((t.day - 1) ~/ 7).clamp(0, 4);
        totals[w] += i.amount;
      }
    }

    _labels = ['W1', 'W2', 'W3', 'W4', 'W5'];
    _values = totals;
    _spots = List.generate(
      5,
      (i) => FlSpot(i.toDouble(), totals[i]),
    );
  }

  void _buildYear(List items) {
    final now = DateTime.now();
    final totals = List<double>.filled(12, 0);

    for (final i in items) {
      final t = _safe(i.createdAt);
      if (t.year == now.year) {
        totals[t.month - 1] += i.amount;
      }
    }

    _labels = const [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    _values = totals;
    _spots = List.generate(
      12,
      (i) => FlSpot(i.toDouble(), totals[i]),
    );
  }

  // ================= CHART =================

  Widget _buildChart() {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= _labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _labels[i],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: _spots,
              isCurved: true,
              curveSmoothness: 0.35,
              barWidth: 3,
              color: const Color(0xFF2F8F83),

              dotData: FlDotData(
                show: true,
                checkToShowDot: (s, _) =>
                    s.x.toInt() == selectedIndex,
                getDotPainter: (_, __, ___, ____) =>
                    FlDotCirclePainter(
                  radius: 6,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: const Color(0xFF2F8F83),
                ),
              ),

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2F8F83).withOpacity(0.35),
                    const Color(0xFF2F8F83).withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ],

          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchCallback: (_, res) {
              if (res?.lineBarSpots?.isNotEmpty ?? false) {
                setState(() {
                  selectedIndex =
                      res!.lineBarSpots!.first.x.toInt();
                });
              }
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.white,
              tooltipRoundedRadius: 12,
              getTooltipItems: (spots) {
                return spots.map(
                  (s) => LineTooltipItem(
                    '₹${s.y.toStringAsFixed(0)}',
                    const TextStyle(
                      color: Color(0xFF2F8F83),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
