import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/skeleton_box.dart';
import '../medicine/widgets/date_banner.dart';
import 'data/mock_data.dart';
import 'widgets/appointment_header.dart';
import 'widgets/appointment_section.dart';
import 'widgets/appointment_summary_card.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int _selectedTab = 0;
  final ScrollController _scrollController = ScrollController();
  final DateTime _selectedDate = DateTime(2026, 4, 12);
  bool _loading = true;
  Timer? _skeletonTimer;

  @override
  void initState() {
    super.initState();
    _skeletonTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _AppointmentSkeleton();
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bundle = _selectedTab == 0
        ? hospitalAppointments
        : homeVisitAppointments;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight),
            child: AppointmentHeader(
              selectedTab: _selectedTab,
              onTabChanged: _onTabChanged,
              onBack: Navigator.of(context).canPop()
                  ? () => Navigator.of(context).pop()
                  : null,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Container(
                color: AppColors.primary400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: DateBanner(date: _selectedDate),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        child: Container(
                          color: AppColors.bgPrimary,
                          width: double.infinity,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppointmentSummaryCard(
                                  soonCount: bundle.soonCount,
                                  weekCount: bundle.weekCount,
                                  monthCount: bundle.monthCount,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 16, 16, 120),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (final bucket
                                          in AppointmentBucket.values) ...[
                                        AppointmentSection(
                                          bucket: bucket,
                                          items: bundle.byBucket[bucket] ??
                                              const [],
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}

class _AppointmentSkeleton extends StatelessWidget {
  const _AppointmentSkeleton();

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SkeletonHost(
        builder: (_, shimmer) => SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, statusBarHeight + 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(
                      shimmer: shimmer,
                      width: 36,
                      height: 36,
                      borderRadius: 100),
                  const SizedBox(width: 12),
                  SkeletonBox(shimmer: shimmer, width: 140, height: 24),
                ],
              ),
              const SizedBox(height: 12),
              SkeletonBox(shimmer: shimmer, height: 36, borderRadius: 100),
              const SizedBox(height: 24),
              SkeletonBox(
                  shimmer: shimmer,
                  width: 200,
                  height: 32,
                  borderRadius: 100),
              const SizedBox(height: 16),
              SkeletonBox(shimmer: shimmer, height: 80, borderRadius: 24),
              const SizedBox(height: 16),
              for (int i = 0; i < 3; i++) ...[
                SkeletonBox(shimmer: shimmer, height: 90, borderRadius: 16),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
