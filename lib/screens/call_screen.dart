import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallPage extends StatelessWidget {
  const CallPage({Key? key, required this.callID}) : super(key: key);
  final String callID;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userID = user?.uid ?? 'default_id';
    final String userName = user?.email ?? 'default_name';

    return ZegoUIKitPrebuiltCall(
      appID: 1201674385,
      appSign:
          'fe62f5daf3961a0d939f1f4362f5433fcb926b5842f9c83579e6e38602481cc6',
      userID: userID,
      userName: userName,
      callID: callID,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..onOnlySelfInRoom = (context) => Navigator.of(context).pop(),
    );
  }
}
