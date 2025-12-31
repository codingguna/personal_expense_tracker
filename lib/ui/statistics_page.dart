// lib/ui/statistics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'widgets/bottom_nav_bar.dart';
import '../expenses/expense_model.dart';
import '../expenses/expense_provider.dart';
import '../income/income_model.dart';
import '../income/income_provider.dart';

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

  int selectedIndex = 0;

  List<String> labels = [];
  List<double> values = [];

  DateTime _safe(DateTime? d) => d?.toLocal() ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final expenses =
        ref.watch(expenseListProvider).value ?? <Expense>[];
    final incomes =
        ref.watch(incomeListProvider).value ?? <Income>[];

    _buildAggregatedData(
      expenses: expenses,
      incomes: incomes,
    );

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Statistics',
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Column(
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
                    label: Text(p.name.toUpperCase()),
                    selected: selected,
                    selectedColor: const Color(0xFF2F8F83),
                    labelStyle: TextStyle(
                      color:
                          selected ? Colors.white : Colors.black,
                    ),
                    onSelected: (_) {
                      setState(() {
                        period = p;
                        selectedIndex = 0;
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
            child: Align(
              alignment: Alignment.centerRight,
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
                    selectedIndex = 0;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// GRAPH
          _buildChart(context),

          const SizedBox(height: 16),

          Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        type == StatsType.expense
            ? 'Expenses List'
            : 'Income List',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
          /// LIST
          Expanded(
            child: type == StatsType.expense
                ? _expenseList(expenses)
                : _incomeList(incomes),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // ================= LISTS =================

  Widget _expenseList(List<Expense> expenses) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: expenses.length,
      itemBuilder: (_, i) {
        final e = expenses[i];
        final bucket = _bucketIndex(_safe(e.createdAt));
        final isSelected = bucket == selectedIndex;

        return _listTile(
          title: e.title,
          amount: e.amount,
          isSelected: isSelected,
          isExpense: true,
          onTap: () => setState(() => selectedIndex = bucket),
        );
      },
    );
  }

  Widget _incomeList(List<Income> incomes) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: incomes.length,
      itemBuilder: (_, i) {
        final inc = incomes[i];
        final bucket = _bucketIndex(_safe(inc.createdAt));
        final isSelected = bucket == selectedIndex;

        return _listTile(
          title: 'Income',
          amount: inc.amount,
          isSelected: isSelected,
          isExpense: false,
          onTap: () => setState(() => selectedIndex = bucket),
        );
      },
    );
  }

  Widget _listTile({
    required String title,
    required double amount,
    required bool isSelected,
    required bool isExpense,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF2F8F83) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color.fromARGB(255, 125, 214, 226) : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${isExpense ? '-' : '+'} ₹${amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isExpense
                        ? Colors.redAccent
                        : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= AGGREGATION =================

  void _buildAggregatedData({
    required List<Expense> expenses,
    required List<Income> incomes,
  }) {
    labels = [];
    values = [];

    final now = DateTime.now();

    switch (period) {
      case StatsPeriod.day:
        labels = List.generate(
          24,
          (h) =>
              '${h == 0 ? 12 : h > 12 ? h - 12 : h} ${h < 12 ? 'AM' : 'PM'}',
        );
        values = List.filled(24, 0);

        if (type == StatsType.expense) {
          for (final Expense e in expenses) {
            final t = _safe(e.createdAt);
            values[t.hour] += e.amount;          
          }
        } else {
          for (final Income i in incomes) {
            final t = _safe(i.createdAt);
            values[t.hour] += i.amount;
          }
        }
        break;

      case StatsPeriod.week:
        labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        values = List.filled(7, 0);

        if (type == StatsType.expense) {
          for (final Expense e in expenses) {
            values[_safe(e.createdAt).weekday - 1] += e.amount;
          }
        } else {
          for (final Income i in incomes) {
            values[_safe(i.createdAt).weekday - 1] += i.amount;
          }
        }
        break;

      case StatsPeriod.month:
        labels = ['W1', 'W2', 'W3', 'W4', 'W5'];
        values = List.filled(5, 0);

        if (type == StatsType.expense) {
          for (final Expense e in expenses) {
            final t = _safe(e.createdAt);
            if (t.month == now.month && t.year == now.year) {
              values[((t.day - 1) ~/ 7).clamp(0, 4)] += e.amount;
            }
          }
        } else {
          for (final Income i in incomes) {
            final t = _safe(i.createdAt);
            if (t.month == now.month && t.year == now.year) {
              values[((t.day - 1) ~/ 7).clamp(0, 4)] += i.amount;
            }
          }
        }
        break;

      case StatsPeriod.year:
        labels = const [
          'Jan','Feb','Mar','Apr','May','Jun',
          'Jul','Aug','Sep','Oct','Nov','Dec'
        ];
        values = List.filled(12, 0);

        if (type == StatsType.expense) {
          for (final Expense e in expenses) {
            final t = _safe(e.createdAt);
            if (t.year == now.year) {
              values[t.month - 1] += e.amount;
            }
          }
        } else {
          for (final Income i in incomes) {
            final t = _safe(i.createdAt);
            if (t.year == now.year) {
              values[t.month - 1] += i.amount;
            }
          }
        }
        break;
    }
  }

  int _bucketIndex(DateTime t) {
    switch (period) {
      case StatsPeriod.day:
        return t.hour;
      case StatsPeriod.week:
        return t.weekday - 1;
      case StatsPeriod.month:
        return ((t.day - 1) ~/ 7).clamp(0, 4);
      case StatsPeriod.year:
        return t.month - 1;
    }
  }

  // ================= GRAPH =================

  int _labelStep(BuildContext context) {
    const labelWidth = 60;
    final width = MediaQuery.of(context).size.width;
    final maxLabels =
        (width / labelWidth).floor().clamp(3, labels.length);
    return (labels.length / maxLabels).ceil();
  }

  Widget _buildChart(BuildContext context) {
    final step = _labelStep(context);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.22,
      child: LineChart(
        LineChartData(
          minY: _minY(),
          maxY: _maxY(),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox();
                  }
                  if (i % step != 0 && i != selectedIndex) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: i == selectedIndex
                            ? const Color(0xFF2F8F83)
                            : const Color.fromARGB(255, 86, 209, 199),
                        fontWeight:
                            i == selectedIndex ? FontWeight.bold : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                values.length,
                (i) => FlSpot(i.toDouble(), values[i]),
              ),
              isCurved: true,
              curveSmoothness:
                  period == StatsPeriod.day ? 0.45 : 0.35,
              barWidth: 3,
              color: const Color(0xFF2F8F83),
              dotData: FlDotData(
                show: true,
                checkToShowDot: (s, _) =>
                    s.x.toInt() == selectedIndex,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 44, 116, 107).withOpacity(0.25),
                    const Color.fromARGB(255, 73, 153, 144).withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],

          extraLinesData: ExtraLinesData(
            verticalLines: [
              VerticalLine(
                x: selectedIndex.toDouble(),
                color: Colors.grey.withOpacity(0.4),
                dashArray: [6, 6],
              ),
            ],
          ),

          lineTouchData: LineTouchData(
  handleBuiltInTouches: true,

  touchTooltipData: LineTouchTooltipData(
    tooltipBgColor: const Color.fromARGB(220, 120, 250, 233),
    tooltipRoundedRadius: 8,
    tooltipPadding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    ),
    tooltipMargin: 12,
    fitInsideHorizontally: true,
    fitInsideVertically: true,

    getTooltipItems: (touchedSpots) {
      return touchedSpots.map((spot) {
        return LineTooltipItem(
          spot.y.toStringAsFixed(0),
          const TextStyle(
            color: Colors.black, // ✅ BLACK TEXT
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        );
      }).toList();
    },
  ),

  touchCallback: (_, response) {
    if (response?.lineBarSpots?.isNotEmpty ?? false) {
      setState(() {
        selectedIndex =
            response!.lineBarSpots!.first.x.toInt();
      });
    }
  },
),

        ),
      ),
    );
  }
double _maxY() {
  if (values.isEmpty) return 0;

  final maxValue = values.reduce((a, b) => a > b ? a : b);

  if (maxValue <= 0) return 10;

  // Add 20% headroom so curve never touches top
  return maxValue * 1.2;
}

double _minY() {
  if (values.isEmpty) return 0;

  final nonZero = values.where((v) => v > 0).toList();
  if (nonZero.isEmpty) return 0;

  // final minValue = nonZero.reduce((a, b) => a < b ? a : b);

  // Lift baseline slightly for Day view only
  if (period == StatsPeriod.day) {
    return 0;
  }

  return 0;
}



}
