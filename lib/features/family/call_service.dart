import 'package:flutter/cupertino.dart';

import 'care_giver_screen.dart';
import 'call_screen.dart';

class ActiveCall {
  ActiveCall({
    required this.member,
    required this.type,
    required this.elapsed,
    required this.muted,
    required this.paused,
  });
  final FamilyMember member;
  final CallType type;
  final Duration elapsed;
  final bool muted;
  final bool paused;
}

class CallService {
  CallService._();
  static final CallService instance = CallService._();

  final ValueNotifier<ActiveCall?> minimized = ValueNotifier<ActiveCall?>(null);

  void minimize(ActiveCall call) {
    minimized.value = call;
  }

  void clear() {
    minimized.value = null;
  }
}
