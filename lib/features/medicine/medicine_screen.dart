import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/skeleton_box.dart';
import 'theme/time_period.dart';
import 'widgets/medicine_header.dart';
import 'widgets/date_banner.dart';
import 'widgets/summary_card.dart';
import 'widgets/time_slots_row.dart';
import 'widgets/meal_section.dart';
import 'widgets/time_period_background.dart';
import 'widgets/prescription_summary.dart';
import 'widgets/prescription_card.dart';
import 'widgets/date_picker_bottom_sheet.dart';
import 'data/mock_data.dart' as mock;
import 'prescription_detail_screen.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  // Collapse after significant downward scroll; expand as soon as user reverses
  // direction (iOS-Safari-style reverse-scroll reveal).
  static const double _collapseThreshold = 40.0;
  static const double _reverseScrollDelta = 6.0;

  int _selectedTab = 0;
  TimePeriod _selectedPeriod = TimePeriod.morning;
  final ScrollController _scrollController = ScrollController();
  bool _headerCollapsed = false;
  double _lastOffset = 0.0;
  DateTime _lastToggleTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _toggleCooldown = Duration(milliseconds: 320);
  DateTime _selectedDate = DateTime(2026, 4, 21);
  bool _loading = true;
  Timer? _skeletonTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _skeletonTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void didUpdateWidget(covariant MedicineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final delta = offset - _lastOffset;
    final sinceLastToggle = DateTime.now().difference(_lastToggleTime);
    final cooledDown = sinceLastToggle >= _toggleCooldown;

    if (offset <= 0) {
      if (_headerCollapsed) {
        _lastToggleTime = DateTime.now();
        setState(() => _headerCollapsed = false);
      }
    } else if (cooledDown &&
        !_headerCollapsed &&
        delta > 0 &&
        offset > _collapseThreshold) {
      _lastToggleTime = DateTime.now();
      setState(() => _headerCollapsed = true);
    } else if (cooledDown &&
        _headerCollapsed &&
        delta < -_reverseScrollDelta) {
      _lastToggleTime = DateTime.now();
      setState(() => _headerCollapsed = false);
    }

    _lastOffset = offset;
  }

  void _onTabChanged(int i) {
    if (i == _selectedTab) return;
    setState(() {
      _selectedTab = i;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePickerBottomSheet(
      context,
      selected: _selectedDate,
      markedDates: mock.markedDates,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _headerCollapsed = false;
      });
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  void _onPeriodSelected(TimePeriod p) {
    setState(() {
      _selectedPeriod = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _MedicineSkeleton();
    final bool isPrescription = _selectedTab == 1;
    final Color currentColor = isPrescription
        ? AppColors.primary400
        : TimePeriodTheme.of(_selectedPeriod).backgroundColor;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const duration = Duration(milliseconds: 260);
    const curve = Curves.easeOutCubic;

    return AnimatedContainer(
      duration: duration,
      curve: curve,
      color: _headerCollapsed ? currentColor : AppColors.bgPrimary,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            AnimatedSize(
              duration: duration,
              curve: curve,
              alignment: Alignment.topCenter,
              child: _headerCollapsed
                  ? const SizedBox(width: double.infinity, height: 0)
                  : Padding(
                      padding: EdgeInsets.only(top: statusBarHeight),
                      child: MedicineHeader(
                        selectedTab: _selectedTab,
                        onTabChanged: _onTabChanged,
                      ),
                    ),
            ),
            Expanded(
              child: TweenAnimationBuilder<double>(
                duration: duration,
                curve: curve,
                tween: Tween(end: _headerCollapsed ? 0.0 : 24.0),
                builder: (context, radius, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radius),
                      topRight: Radius.circular(radius),
                    ),
                    child: child,
                  );
                },
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: isPrescription
                          ? const ColoredBox(color: AppColors.primary400)
                          : TimePeriodBackground(period: _selectedPeriod),
                    ),
                    AnimatedPositioned(
                      duration: duration,
                      curve: curve,
                      top: _headerCollapsed ? statusBarHeight + 16 : 16,
                      left: 0,
                      right: 0,
                      child: DateBanner(
                        date: _selectedDate,
                        onTapChip: () => _showDatePicker(context),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: duration,
                      curve: curve,
                      top: _headerCollapsed ? statusBarHeight + 81 : 81,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: isPrescription
                          ? _PrescriptionContent(
                              scrollController: _scrollController,
                              date: _selectedDate,
                            )
                          : _MedicineListContent(
                              selectedPeriod: _selectedPeriod,
                              onSelectPeriod: _onPeriodSelected,
                              scrollController: _scrollController,
                              date: _selectedDate,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicineListContent extends StatefulWidget {
  final TimePeriod selectedPeriod;
  final ValueChanged<TimePeriod> onSelectPeriod;
  final ScrollController scrollController;
  final DateTime date;

  const _MedicineListContent({
    required this.selectedPeriod,
    required this.onSelectPeriod,
    required this.scrollController,
    required this.date,
  });

  @override
  State<_MedicineListContent> createState() => _MedicineListContentState();
}

class _MedicineListContentState extends State<_MedicineListContent>
    with SingleTickerProviderStateMixin {
  // Per-period taken state (before + after meal lists)
  final Map<TimePeriod, List<bool>> _takenBefore = {};
  final Map<TimePeriod, List<bool>> _takenAfter = {};

  late final AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _entryCtrl.forward());
    _initState(widget.date);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  Widget _stagger(int index, int total, Widget child) {
    final start = (index / total) * 0.5;
    final end = (start + 0.55).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _entryCtrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) {
        final t = anim.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  @override
  void didUpdateWidget(covariant _MedicineListContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _initState(widget.date);
    }
  }

  void _initState(DateTime date) {
    final data = mock.medicineFor(date);
    _takenBefore.clear();
    _takenAfter.clear();
    for (final p in TimePeriod.values) {
      final pd = data.medicinesFor(p);
      _takenBefore[p] = List<bool>.filled(pd.beforeMeal.length, false);
      _takenAfter[p] = List<bool>.filled(pd.afterMeal.length, false);
    }
  }

  bool _isPeriodDone(TimePeriod p) {
    final before = _takenBefore[p] ?? const <bool>[];
    final after = _takenAfter[p] ?? const <bool>[];
    if (before.isEmpty && after.isEmpty) return false;
    return before.every((v) => v) && after.every((v) => v);
  }

  void _showSnack(bool taken) {
    if (taken) {
      AppToast.success(context, 'บันทึกการทานยาแล้ว');
    } else {
      AppToast.info(context, 'ยกเลิกการบันทึก');
    }
  }

  void _toggleBeforeItem(TimePeriod p, int idx) {
    setState(() {
      final list = _takenBefore[p]!;
      list[idx] = !list[idx];
      _showSnack(list[idx]);
    });
  }

  void _toggleAfterItem(TimePeriod p, int idx) {
    setState(() {
      final list = _takenAfter[p]!;
      list[idx] = !list[idx];
      _showSnack(list[idx]);
    });
  }

  void _toggleAllBefore(TimePeriod p) {
    setState(() {
      final list = _takenBefore[p]!;
      final next = !list.every((v) => v);
      for (int i = 0; i < list.length; i++) {
        list[i] = next;
      }
      _showSnack(next);
    });
  }

  void _toggleAllAfter(TimePeriod p) {
    setState(() {
      final list = _takenAfter[p]!;
      final next = !list.every((v) => v);
      for (int i = 0; i < list.length; i++) {
        list[i] = next;
      }
      _showSnack(next);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = mock.medicineFor(widget.date);
    final period = widget.selectedPeriod;
    final periodData = data.medicinesFor(period);
    final hasAny =
        periodData.beforeMeal.isNotEmpty || periodData.afterMeal.isNotEmpty;

    final doneByPeriod = <TimePeriod, bool>{
      for (final p in TimePeriod.values) p: _isPeriodDone(p),
    };

    final beforeTaken = _takenBefore[period] ?? const <bool>[];
    final afterTaken = _takenAfter[period] ?? const <bool>[];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stagger(
            0,
            4,
            SummaryCard(
              morningCount: data.morningCount,
              dayCount: data.dayCount,
              eveningCount: data.eveningCount,
              bedtimeCount: data.bedtimeCount,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 16, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stagger(
                    1,
                    4,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TimeSlotsRow(
                        selected: period,
                        onSelected: widget.onSelectPeriod,
                        doneByPeriod: doneByPeriod,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!hasAny)
                    const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(
                        child: Text(
                          'ไม่มีรายการยาในช่วงนี้',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  if (periodData.beforeMeal.isNotEmpty) ...[
                    _stagger(
                      2,
                      4,
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: MealSection(
                          label1: 'ก่อน',
                          label2: 'อาหาร',
                          itemCount: periodData.beforeMeal.length,
                          medicines: periodData.beforeMeal,
                          takenStates: beforeTaken,
                          allTaken: beforeTaken.isNotEmpty &&
                              beforeTaken.every((v) => v),
                          onToggleAll: () => _toggleAllBefore(period),
                          onToggleItem: (i) => _toggleBeforeItem(period, i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (periodData.afterMeal.isNotEmpty)
                    _stagger(
                      3,
                      4,
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: MealSection(
                          label1: 'หลัง',
                          label2: 'อาหาร',
                          itemCount: periodData.afterMeal.length,
                          medicines: periodData.afterMeal,
                          takenStates: afterTaken,
                          allTaken: afterTaken.isNotEmpty &&
                              afterTaken.every((v) => v),
                          onToggleAll: () => _toggleAllAfter(period),
                          onToggleItem: (i) => _toggleAfterItem(period, i),
                        ),
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

class _PrescriptionContent extends StatelessWidget {
  final ScrollController scrollController;
  final DateTime date;

  const _PrescriptionContent({
    required this.scrollController,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final data = mock.prescriptionFor(date);
    final prescriptions = data.prescriptions;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrescriptionSummary(
            itemCount: prescriptions.length,
            onAcknowledge: prescriptions.isEmpty
                ? null
                : () => AppToast.success(
                      context,
                      'เพิ่มยาในตารางการทานยาแล้ว',
                    ),
          ),
          Expanded(
            child: prescriptions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: Text(
                        'ไม่มีใบสั่งยาในวันนี้',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 16, bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < prescriptions.length; i++) ...[
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: PrescriptionCard(
                              item: prescriptions[i],
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final med in data.detailByHospital[
                                  prescriptions[i].hospital] ??
                              const <MedicineDetailItem>[]) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: MedicineDetailCard(item: med),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (i < prescriptions.length - 1)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.borderDefault,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MedicineSkeleton extends StatelessWidget {
  const _MedicineSkeleton();

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SkeletonHost(
        builder: (_, shimmer) => SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (title + tabs placeholder)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(shimmer: shimmer, width: 140, height: 24),
                    SkeletonBox(
                        shimmer: shimmer,
                        width: 172,
                        height: 36,
                        borderRadius: 100),
                  ],
                ),
                const SizedBox(height: 24),
                // Date banner
                SkeletonBox(shimmer: shimmer, width: 90, height: 14),
                const SizedBox(height: 8),
                SkeletonBox(
                    shimmer: shimmer,
                    width: 200,
                    height: 32,
                    borderRadius: 100),
                const SizedBox(height: 32),
                // Summary card (rounded top)
                SkeletonBox(
                    shimmer: shimmer, height: 64, borderRadius: 24),
                const SizedBox(height: 16),
                // Time slots row (4 cards)
                SizedBox(
                  height: 96,
                  child: Row(
                    children: List.generate(4, (i) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
                          child: SkeletonBox(
                              shimmer: shimmer, borderRadius: 24),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                // Meal section card
                SkeletonBox(
                    shimmer: shimmer, height: 200, borderRadius: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
