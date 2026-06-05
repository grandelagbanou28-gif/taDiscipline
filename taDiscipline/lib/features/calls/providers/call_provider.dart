import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class CallState {
  final bool isInCall;
  final String? roomName;
  const CallState({this.isInCall = false, this.roomName});
}

class CallNotifier extends StateNotifier<CallState> {
  final JitsiMeet _jitsiMeet = JitsiMeet();

  CallNotifier() : super(const CallState());

  Future<void> startCall(String roomName, {String? displayName, String? email}) async {
    state = CallState(isInCall: true, roomName: roomName);
    try {
      var options = JitsiMeetConferenceOptions(
        room: roomName,
        serverURL: 'https://meet.jit.si',
        configOverrides: {
          'startWithAudioMuted': false,
          'startWithVideoMuted': false,
        },
        featureFlags: {
          'pip.enabled': false,
          'calendar.enabled': false,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: displayName ?? 'Utilisateur',
          email: email,
        ),
      );
      await _jitsiMeet.join(options);
    } finally {
      state = const CallState();
    }
  }

  void endCall() {
    state = const CallState();
  }
}

final callProvider = StateNotifierProvider<CallNotifier, CallState>((ref) => CallNotifier());
