import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/operation.dart';
import '../services/storage_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  double totalIn = 0;
  double totalOut = 0;
  Map<int, Map<String, double>> monthlyData = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final data = await StorageService.loadData();
    final ops = (data['operations'] as List)
        .map((e) => Operation.fromJson(e))
        .toList();

    double inSum = 0;
    double outSum = 0;
    final Map<int, Map<String, double>> monthly = {
      for (var i = 1; i <= 12; i++) i: {'in': 0, 'out': 0},
    };

    for (var op in ops) {
      final month = op.date.month;
      if (op.type == 'in') {
        inSum += op.amount;
        monthly[month]!['in'] = monthly[month]!['in']! + op.amount;
      } else {
        outSum += op.amount;
        monthly[month]!['out'] = monthly[month]!['out']! + op.amount;
      }
    }

    setState(() {
      totalIn = inSum;
      totalOut = outSum;
      monthlyData = monthly;
    });
  }

  List<BarChartGroupData> _buildBarGroups() {
    final List<BarChartGroupData> groups = [];

    for (var month = 1; month <= 12; month++) {
      final inVal = monthlyData[month]?['in'] ?? 0;
      final outVal = monthlyData[month]?['out'] ?? 0;

      groups.add(
        BarChartGroupData(
          x: month,
          barsSpace: 6,
          barRods: [
            BarChartRodData(
              toY: inVal,
              color: Colors.green[600],
              width: 10,
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: outVal,
              color: Colors.red[600],
              width: 10,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard(
                  title: 'Total déposé',
                  amount: totalIn,
                  color: Colors.green[400]!,
                  icon: Icons.arrow_downward,
                ),
                _buildSummaryCard(
                  title: 'Total retiré',
                  amount: totalOut,
                  color: Colors.red[400]!,
                  icon: Icons.arrow_upward,
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Évolution mensuelle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              height: 320,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: BarChart(
                BarChartData(
                  maxY: _getMaxY(),
                  alignment: BarChartAlignment.spaceBetween,
                  groupsSpace: 16,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getMaxY() / 5,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey[400]!, strokeWidth: 0.5),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: _getMaxY() / 5,
                        getTitlesWidget: (value, _) => Text(
                          '${value.toInt().toString()} DZD',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          const months = [
                            '',
                            'Jan',
                            'Fév',
                            'Mar',
                            'Avr',
                            'Mai',
                            'Juin',
                            'Juil',
                            'Aoû',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Déc',
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              months[value.toInt()],
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    double maxVal = 0;
    for (final m in monthlyData.values) {
      final inVal = m['in'] ?? 0;
      final outVal = m['out'] ?? 0;
      maxVal = [maxVal, inVal, outVal].reduce((a, b) => a > b ? a : b);
    }
    return maxVal == 0 ? 100 : (maxVal * 1.2).ceilToDouble();
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 14, color: color)),
              const SizedBox(height: 8),
              Text(
                '${amount.toStringAsFixed(2)} DZD',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.green[600]!, 'Dépôt'),
        const SizedBox(width: 20),
        _legendItem(Colors.red[600]!, 'Retrait'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
