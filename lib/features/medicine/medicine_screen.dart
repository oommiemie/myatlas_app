import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_toast.dart';
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
import '../../core/utils/thai_date.dart';
import 'prescription_detail_screen.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  // Hysteresis: collapse only after significant scroll, expand only at top
  static const double _collapseThreshold = 40.0;
  static const double _expandThreshold = 0.0;

  int _selectedTab = 0;
  TimePeriod _selectedPeriod = TimePeriod.morning;
  final ScrollController _scrollController = ScrollController();
  bool _headerCollapsed = false;
  DateTime _selectedDate = DateTime(2026, 4, 21);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant MedicineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    if (!_headerCollapsed) {
      if (offset > _collapseThreshold) {
        setState(() => _headerCollapsed = true);
      }
    } else {
      if (offset <= _expandThreshold) {
        setState(() => _headerCollapsed = false);
      }
    }
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
      _headerCollapsed = false;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPrescription = _selectedTab == 1;
    final Color currentColor = isPrescription
        ? AppColors.primary400
        : TimePeriodTheme.of(_selectedPeriod).backgroundColor;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      color: _headerCollapsed ? currentColor : AppColors.bgPrimary,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: Alignment.bottomCenter,
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
                  child: ClipRRect(
                    borderRadius: _headerCollapsed
                        ? BorderRadius.zero
                        : const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned.fill(
                          child: isPrescription
                              ? const ColoredBox(color: AppColors.primary400)
                              : TimePeriodBackground(period: _selectedPeriod),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          top: _headerCollapsed ? statusBarHeight + 16 : 16,
                          left: 0,
                          right: 0,
                          child: DateBanner(
                            date: _selectedDate,
                            onTapChip: () => _showDatePicker(context),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
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

class _MedicineListContentState extends State<_MedicineListContent> {
  // Per-period taken state (before + after meal lists)
  final Map<TimePeriod, List<bool>> _takenBefore = {};
  final Map<TimePeriod, List<bool>> _takenAfter = {};

  @override
  void initState() {
    super.initState();
    _initState(widget.date);
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
          SummaryCard(
            morningCount: data.morningCount,
            dayCount: data.dayCount,
            eveningCount: data.eveningCount,
            bedtimeCount: data.bedtimeCount,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 16, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TimeSlotsRow(
                      selected: period,
                      onSelected: widget.onSelectPeriod,
                      doneByPeriod: doneByPeriod,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    const SizedBox(height: 16),
                  ],
                  if (periodData.afterMeal.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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

  void _openDetail(
    BuildContext context,
    PrescriptionItem item,
    List<MedicineDetailItem> medicines,
  ) {
    showPrescriptionDetailSheet(
      context,
      serviceDate: ThaiDate.format(date),
      hospital: item.hospital,
      symptoms: item.symptoms,
      coverage: 'UC',
      medicines: medicines,
    );
  }

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
          PrescriptionSummary(itemCount: prescriptions.length),
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
                              onTapDetails: () => _openDetail(
                                context,
                                prescriptions[i],
                                data.detailByHospital[
                                        prescriptions[i].hospital] ??
                                    const [],
                              ),
                            ),
                          ),
                          if (i < prescriptions.length - 1)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
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
