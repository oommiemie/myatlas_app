import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
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

  @override
  void dispose() {
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
