import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/controller/home_controller.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/model/order_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/ui/home_screens/order_map_screen.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:lawyer/widget/location_view.dart';
import 'package:lawyer/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../model/language_title.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<HomeController>(
      init: HomeController(),
      dispose: (state) {
        FireStoreUtils().closeStream();
      },
      builder: (controller) {
        return controller.isLoading.value
            ? Constant.loader(context)
            : controller.driverModel.value.isOnline == false
            ? _OfflineView()
            : StreamBuilder<List<OrderModel>>(
          stream: FireStoreUtils().getOrders(
              controller.driverModel.value,
              Constant.currentLocation?.latitude,
              Constant.currentLocation?.longitude),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _LoadingView(themeChange: themeChange);
            }
            if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
              return _EmptyView(themeChange: themeChange);
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemBuilder: (context, index) {
                  final orderModel = snapshot.data![index];
                  return _AnimatedNewCaseCard(
                    orderModel: orderModel,
                    index: index,
                    themeChange: themeChange,
                    onTap: () {
                      Get.to(const OrderMapScreen(), arguments: {
                        "orderModel": orderModel.id.toString()
                      })?.then((value) {
                        if (value == true) {
                          controller.selectedIndex.value = 1;
                        }
                      });
                    },
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}

/// 🔴 Offline state widget — also shows a diagnostic panel so the lawyer
/// can self-diagnose what's blocking them from going online.
class _OfflineView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          _DiagnosticPanel(themeChange: themeChange),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.redAccent,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "You are offline",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the gold toggle in the top bar to go online",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.subTitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ⏳ Loading shimmer
class _LoadingView extends StatelessWidget {
  final DarkThemeProvider themeChange;
  const _LoadingView({required this.themeChange});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemBuilder: (context, index) {
        return _ShimmerCard(themeChange: themeChange);
      },
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final DarkThemeProvider themeChange;
  const _ShimmerCard({required this.themeChange});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_shimmer.value - 0.4).clamp(0.0, 1.0),
              _shimmer.value.clamp(0.0, 1.0),
              (_shimmer.value + 0.4).clamp(0.0, 1.0),
            ],
            colors: widget.themeChange.getThem()
                ? [
                    AppColors.darkContainerBackground,
                    AppColors.darkContainerBackground.withOpacity(0.5),
                    AppColors.darkContainerBackground,
                  ]
                : [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                    Colors.grey.shade200,
                  ],
          ),
        ),
      ),
    );
  }
}

/// 📭 Empty state widget
class _EmptyView extends StatefulWidget {
  final DarkThemeProvider themeChange;
  const _EmptyView({required this.themeChange});

  @override
  State<_EmptyView> createState() => _EmptyViewState();
}

class _EmptyViewState extends State<_EmptyView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _DiagnosticPanel(themeChange: widget.themeChange),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _buildEmptyContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.8 + (value * 0.2), child: child),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 40,
              left: 28,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandGold.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              top: 84,
              right: 44,
              child: Container(
                width: 96,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.brandGold.withValues(alpha: 0.12),
                      AppColors.brandGold.withValues(alpha: 0.48),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 96,
              left: 46,
              child: Container(
                width: 120,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.brandGold.withValues(alpha: 0.35),
                      AppColors.brandGold.withValues(alpha: 0.10),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFEFB), Color(0xFFF3EEE4)],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.40), width: 1.3),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _float,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _float.value),
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF8E1A0), Color(0xFFC9A227)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandGold.withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        size: 58,
                        color: Color(0xFF6B5310),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No New Cases",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandNavy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your dashboard is ready. New legal requests will appear here as soon as clients submit them.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: AppColors.brandNavy.withValues(alpha: 0.72),
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.brandNavy,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.65), width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandGold.withValues(alpha: 0.16),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.brandGold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandGold.withValues(alpha: 0.55),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Listening for new cases...",
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: AppColors.brandGoldLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔬 Diagnostic panel: shows why no cases are appearing so the lawyer
/// can self-diagnose (online, has specialties, has cities, cases in DB, etc.).
class _DiagnosticPanel extends StatelessWidget {
  final DarkThemeProvider themeChange;
  const _DiagnosticPanel({required this.themeChange});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return Obx(() {
      final m = ctrl.driverModel.value;
      final isOnline = m.isOnline == true;
      final hasSpecialty = (m.serviceIds != null && m.serviceIds!.isNotEmpty) ||
          (m.serviceId != null && m.serviceId!.isNotEmpty);
      final specialtyCount = m.serviceIds?.length ?? 0;
      final cityCount = m.cityIds?.length ?? 0;
      final zoneCount = m.zoneIds?.length ?? 0;
      final cityLabel = (m.cityIds != null && m.cityIds!.isNotEmpty)
          ? m.cityIds!.join(', ')
          : 'Any';
      final totalAvailable = ctrl.availableRides.length;
      final verified = m.documentVerification == true;
      final verifStatus = m.verificationStatus ?? '';

      // Build the list of action hints to show.
      final hints = <String>[];
      if (!isOnline) hints.add('Go online (toggle in the top bar)');
      if (!hasSpecialty) hints.add('Pick at least 1 case category in Lawyer Information');
      if (!verified && verifStatus.isEmpty) {
        hints.add('Submit identity documents from the signup screen');
      } else if (verifStatus == 'pending') {
        hints.add('Documents under admin review');
      } else if (verifStatus == 'rejected') {
        hints.add('Documents rejected — resubmit them');
      }
      if (totalAvailable == 0) {
        hints.add('No new cases in system yet — wait for a customer to post one');
      } else if (totalAvailable > 0 && hasSpecialty) {
        hints.add('$totalAvailable case(s) in system — check if any match your specialties');
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkContainerBackground
              : AppColors.containerBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.brandGold.withValues(alpha: 0.30),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.troubleshoot_rounded,
                    size: 18, color: AppColors.brandGold),
                const SizedBox(width: 6),
                Text(
                  'Why no cases?',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _row(context, 'Online', isOnline ? 'Yes' : 'No', isOnline),
            _row(context, 'Categories', '$specialtyCount selected', hasSpecialty),
            _row(context, 'Cities', cityLabel, cityCount > 0),
            _row(context, 'Zones', '$zoneCount selected', zoneCount > 0),
            _row(
              context,
              'Verification',
              verifStatus.isEmpty
                  ? (verified ? 'Verified' : 'Not submitted')
                  : verifStatus,
              verified,
            ),
            _row(context, 'Cases in system', '$totalAvailable available',
                totalAvailable > 0),
            if (hints.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              ...hints.map((h) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right_rounded,
                            size: 16, color: AppColors.brandGold),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            h,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            // Per-case match analysis — shows EACH case in the system and
            // exactly why it was accepted or rejected by the filters.
            if (totalAvailable > 0) ...[
              const SizedBox(height: 10),
              Container(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              Text(
                'Per-case match analysis',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              ..._analyzeCases(ctrl, m).map(
                  (info) => _caseRow(context, info)),
            ],
          ],
        ),
      );
    });
  }

  /// For each case in `availableRides`, compute why it would or wouldn't
  /// reach this lawyer through the filter chain.
  List<_CaseMatchInfo> _analyzeCases(
      HomeController ctrl, DriverUserModel m) {
    final lawyerServiceIds = <String>{
      ...?m.serviceIds,
      if ((m.serviceId ?? '').isNotEmpty) m.serviceId!,
    };
    final lawyerCities = m.cityIds ?? const <String>[];
    final lawyerZones =
        (m.zoneIds ?? const []).map((e) => e.toString()).toList();
    final hasZoneFilter = lawyerCities.isNotEmpty || lawyerZones.isNotEmpty;

    final out = <_CaseMatchInfo>[];
    for (final c in ctrl.availableRides) {
      final reasons = <String>[];
      bool wouldShow = true;

      // Category check
      if (lawyerServiceIds.isEmpty) {
        reasons.add('You have 0 categories — no cases match');
        wouldShow = false;
      } else if (c.serviceId == null || c.serviceId!.isEmpty) {
        reasons.add('Case has no serviceId');
        wouldShow = false;
      } else if (!lawyerServiceIds.contains(c.serviceId)) {
        reasons.add('Category "${c.serviceId}" not in your list');
        wouldShow = false;
      }

      // Zone is now informational only — does NOT block.
      // Annotates the case but doesn't change `wouldShow`.
      if (hasZoneFilter) {
        final hasCity = (c.cityName ?? '').isNotEmpty;
        final hasZone = (c.zoneId ?? '').isNotEmpty;
        final hasProv = (c.province ?? '').isNotEmpty;
        if (hasCity || hasZone || hasProv) {
          final matchCity = hasCity && lawyerCities.contains(c.cityName);
          final matchZone = hasZone && lawyerZones.contains(c.zoneId);
          final matchProv = hasProv &&
              (m.province ?? '').isNotEmpty &&
              c.province == m.province;
          if (!matchCity && !matchZone && !matchProv) {
            reasons.add(
                'Zone soft-mismatch (not blocking): city "${c.cityName ?? "-"}"/province "${c.province ?? "-"}"');
            // wouldShow stays true — only categories block.
          }
        }
      }

      if (reasons.isEmpty) reasons.add('Matches all your filters');
      out.add(_CaseMatchInfo(
        caseId: c.id ?? '?',
        serviceId: c.serviceId ?? '-',
        cityName: c.cityName ?? '-',
        zoneId: c.zoneId ?? '-',
        wouldShow: wouldShow,
        reasons: reasons,
      ));
    }
    return out;
  }

  Widget _caseRow(BuildContext context, _CaseMatchInfo info) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final color = info.wouldShow ? const Color(0xFF1D7A3A) : const Color(0xFFB02828);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(info.wouldShow ? Icons.check_rounded : Icons.block_rounded,
                  size: 14, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Case ${info.caseId.length > 10 ? info.caseId.substring(0, 10) : info.caseId}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ),
              Text(
                info.wouldShow ? 'MATCH' : 'BLOCKED',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 9.5,
                  color: color,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'svc: ${info.serviceId.length > 18 ? "${info.serviceId.substring(0, 18)}…" : info.serviceId}   city: ${info.cityName}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: onSurface.withValues(alpha: 0.55),
            ),
          ),
          ...info.reasons.map((r) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '• $r',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: onSurface.withValues(alpha: 0.75),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, bool ok) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: ok ? const Color(0xFF1D7A3A) : const Color(0xFFB02828),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: onSurface.withValues(alpha: 0.65),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Per-case match analysis result for the diagnostic panel.
class _CaseMatchInfo {
  final String caseId;
  final String serviceId;
  final String cityName;
  final String zoneId;
  final bool wouldShow;
  final List<String> reasons;
  _CaseMatchInfo({
    required this.caseId,
    required this.serviceId,
    required this.cityName,
    required this.zoneId,
    required this.wouldShow,
    required this.reasons,
  });
}

/// ⚡ Animated New Case Card with "NEW" badge and entrance animation
class _AnimatedNewCaseCard extends StatefulWidget {
  final OrderModel orderModel;
  final int index;
  final DarkThemeProvider themeChange;
  final VoidCallback onTap;

  const _AnimatedNewCaseCard({
    required this.orderModel,
    required this.index,
    required this.themeChange,
    required this.onTap,
  });

  @override
  State<_AnimatedNewCaseCard> createState() => _AnimatedNewCaseCardState();
}

class _AnimatedNewCaseCardState extends State<_AnimatedNewCaseCard>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _slideIn;
  late Animation<double> _fadeIn;
  late Animation<double> _pulse;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideIn = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeIn),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Staggered entrance
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caseTitle = widget.orderModel.service?.title != null &&
            widget.orderModel.service!.title!.isNotEmpty
        ? widget.orderModel.service!.title!.firstWhere(
            (e) => e.type == 'en',
            orElse: () => LanguageTitle(title: 'New Case', type: 'en'),
          ).title ?? 'New Case'
        : 'New Case';
    final serviceImage = widget.orderModel.service?.image ?? '';
    final isDark = widget.themeChange.getThem();

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slideIn.value),
        child: Opacity(opacity: _fadeIn.value, child: child),
      ),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) => Transform.scale(
          scale: _isPressed ? 0.97 : _pulse.value,
          child: child,
        ),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkContainerBackground : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? AppColors.brandGold.withOpacity(0.2)
                    : AppColors.brandGold.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandGold.withOpacity(isDark ? 0.08 : 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔴 Top bar with "NEW CASE" badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.brandGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.gavel,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              "NEW CASE",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Pulsing dot — Flexible to clip gracefully on very
                      // narrow screens instead of overflowing.
                      Flexible(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.5, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (ctx, v, _) => Opacity(
                            opacity: v,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4ADE80),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    "Available",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info + amount
                      UserView(
                        userId: widget.orderModel.userId,
                        amount: widget.orderModel.offerRate,
                      ),

                      const SizedBox(height: 12),

                      // Case title + image row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (serviceImage.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                serviceImage,
                                height: 64,
                                width: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  height: 64,
                                  width: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.brandGold.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.gavel,
                                      color: AppColors.brandGold, size: 32),
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                color: AppColors.brandGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.brandGold.withOpacity(0.2),
                                ),
                              ),
                              child: Icon(Icons.balance,
                                  color: AppColors.brandGold, size: 32),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  caseTitle,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.orderModel.description ?? "Legal case assistance required",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.subTitleColor,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Divider(
                        color: isDark ? AppColors.darkContainerBorder : Colors.grey.shade200,
                        height: 1,
                      ),
                      const SizedBox(height: 10),

                      // Location — tappable, opens customer's exact pin in Maps
                      LocationView(
                        sourceLocation: widget.orderModel.sourceLocationName ??
                            "Location not specified",
                        latitude: widget.orderModel.sourceLocationLatLng?.latitude,
                        longitude: widget.orderModel.sourceLocationLatLng?.longitude,
                      ),

                      const SizedBox(height: 10),

                      // Payment info + date
                      Row(
                        children: [
                          Expanded(
                            child: _infoChip(
                              Icons.payments_outlined,
                              widget.orderModel.paymentType ?? "N/A",
                              AppColors.info.withOpacity(0.1),
                              AppColors.info,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _infoChip(
                              Icons.local_offer_outlined,
                              "${widget.orderModel.offerRate ?? '0'} PKR",
                              AppColors.brandGold.withOpacity(0.1),
                              AppColors.brandGold,
                              isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Date + tap hint — date is Expanded so a long localised
                      // timestamp never pushes the CTA chip off the card.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              widget.orderModel.createdDate != null
                                  ? Constant.dateAndTimeFormatTimestamp(
                                      widget.orderModel.createdDate!)
                                  : 'Unknown',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.subTitleColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "View Case",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 10, color: Colors.white),
                              ],
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
      ),
    );
  }

  Widget _infoChip(
      IconData icon, String label, Color bgColor, Color iconColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
