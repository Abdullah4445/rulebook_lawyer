import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Phase 2.8 — Lawyer earnings analytics dashboard.
/// Reads wallet_transaction docs for the current lawyer and aggregates them
/// into today / week / month / year totals plus a 7-day bar chart.
class EarningsScreen extends StatelessWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Drive card / text colors from the active theme so OS dark mode is honoured
    // even when the in-app toggle hasn't been flipped.
    final isDark = theme.brightness == Brightness.dark;
    final uid = FireStoreUtils.getCurrentUid();
    final symbol = Constant.currencyModel?.symbol ?? 'PKR';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(CollectionName.walletTransaction)
              .where('userId', isEqualTo: uid)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Constant.loader(context);
            }
            final docs = snap.data?.docs ?? [];
            // Keep only positive (income) transactions for the lawyer side.
            final incomes = docs
                .map((d) => _Tx.fromMap(d.data()))
                .where((t) => t.amount > 0 && t.date != null)
                .toList()
              ..sort((a, b) => b.date!.compareTo(a.date!));

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heroCard(theme, incomes, symbol),
                  const SizedBox(height: 14),
                  _periodGrid(theme, isDark, incomes, symbol),
                  const SizedBox(height: 18),
                  _chartSection(theme, isDark, incomes, symbol),
                  const SizedBox(height: 18),
                  _recentSection(theme, isDark, incomes, symbol),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _heroCard(ThemeData theme, List<_Tx> incomes, String symbol) {
    final total = incomes.fold<double>(0, (s, t) => s + t.amount);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGold.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text('Total earnings'.tr,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$symbol ${NumberFormat('#,##0.##').format(total)}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 30,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${incomes.length} ${"transaction(s)".tr}',
            style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _periodGrid(
      ThemeData theme, bool isDark, List<_Tx> incomes, String symbol) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);

    double sumSince(DateTime since) {
      return incomes
          .where((t) => t.date!.isAfter(since.subtract(const Duration(seconds: 1))))
          .fold<double>(0, (s, t) => s + t.amount);
    }

    final cells = <Map<String, dynamic>>[
      {'label': 'Today'.tr, 'val': sumSince(startOfDay), 'icon': Icons.today_rounded},
      {'label': 'This week'.tr, 'val': sumSince(startOfWeek), 'icon': Icons.calendar_view_week_rounded},
      {'label': 'This month'.tr, 'val': sumSince(startOfMonth), 'icon': Icons.calendar_month_rounded},
      {'label': 'This year'.tr, 'val': sumSince(startOfYear), 'icon': Icons.timeline_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: cells.length,
      itemBuilder: (_, i) {
        final c = cells[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkContainerBackground
                : AppColors.containerBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark
                    ? AppColors.darkContainerBorder
                    : AppColors.containerBorder,
                width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.brandGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(c['icon'] as IconData,
                    color: AppColors.brandGoldDeep, size: 14),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c['label'] as String,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6))),
                  const SizedBox(height: 2),
                  Text(
                    '$symbol ${NumberFormat('#,##0').format(c['val'] as double)}',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                        color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chartSection(
      ThemeData theme, bool isDark, List<_Tx> incomes, String symbol) {
    // Aggregate by day for last 7 days.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<double> last7 = List.filled(7, 0);
    final labels = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return DateFormat('EEE').format(d).substring(0, 1);
    });
    for (final t in incomes) {
      final d = DateTime(t.date!.year, t.date!.month, t.date!.day);
      final delta = today.difference(d).inDays;
      if (delta >= 0 && delta < 7) {
        last7[6 - delta] += t.amount;
      }
    }
    final maxVal = last7.fold<double>(0, (m, v) => v > m ? v : m);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark
                ? AppColors.darkContainerBorder
                : AppColors.containerBorder,
            width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.bar_chart_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text('Last 7 days'.tr,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: const Size.fromHeight(150),
              painter: _BarChartPainter(
                values: last7,
                labels: labels,
                maxVal: maxVal,
                barColor: AppColors.brandGold,
                textColor: theme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                gridColor: theme.dividerColor.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentSection(
      ThemeData theme, bool isDark, List<_Tx> incomes, String symbol) {
    final recent = incomes.take(8).toList();
    final fmt = DateFormat('MMM d · h:mm a');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark
                ? AppColors.darkContainerBorder
                : AppColors.containerBorder,
            width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text('Recent earnings'.tr,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface)),
              const Spacer(),
              Text('${incomes.length} ${"total".tr}',
                  style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.55))),
            ],
          ),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text('No earnings yet.'.tr,
                    style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55))),
              ),
            )
          else
            ...recent.map((t) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF28A745).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_downward_rounded,
                      color: Color(0xFF28A745), size: 18),
                ),
                title: Text(
                  (t.note ?? '').isNotEmpty ? t.note! : 'Case payment'.tr,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: theme.colorScheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(fmt.format(t.date!),
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6))),
                trailing: Text(
                  '+ $symbol ${NumberFormat('#,##0.##').format(t.amount)}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: const Color(0xFF28A745)),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _Tx {
  final double amount;
  final DateTime? date;
  final String? note;
  final String? orderType;
  _Tx({required this.amount, this.date, this.note, this.orderType});

  factory _Tx.fromMap(Map<String, dynamic> m) {
    final raw = m['amount'];
    final amt = raw is num
        ? raw.toDouble()
        : (raw == null ? 0.0 : double.tryParse(raw.toString()) ?? 0.0);
    final ts = m['createdDate'];
    return _Tx(
      amount: amt,
      date: ts is Timestamp ? ts.toDate() : null,
      note: m['note'] as String?,
      orderType: m['orderType'] as String?,
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxVal;
  final Color barColor;
  final Color textColor;
  final Color gridColor;

  _BarChartPainter({
    required this.values,
    required this.labels,
    required this.maxVal,
    required this.barColor,
    required this.textColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final chartHeight = size.height - 22;
    final barAreaWidth = size.width;
    final barCount = values.length;
    final slot = barAreaWidth / barCount;
    final barWidth = slot * 0.55;
    final effectiveMax = maxVal == 0 ? 1.0 : maxVal;

    // Subtle gridline
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(0, chartHeight),
        Offset(size.width, chartHeight), gridPaint);

    final barPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          barColor,
          barColor.withValues(alpha: 0.55),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));

    for (int i = 0; i < barCount; i++) {
      final v = values[i];
      final h = (v / effectiveMax) * (chartHeight - 4);
      final left = i * slot + (slot - barWidth) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, chartHeight - h, barWidth, h),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);

      // Day label
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(left + (barWidth - tp.width) / 2, chartHeight + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.values != values || old.maxVal != maxVal;
}
