import 'package:flutter/material.dart';
import 'package:test_camera_detection/utils/enum/enum_extension.dart';

class StateMapping extends StatelessWidget {
  const StateMapping({super.key, required this.item});

  final LivenessState item;

  @override
  Widget build(BuildContext context) {
    final fontStyle = const TextStyle(fontSize: 14, color: Colors.white);
    switch (item) {
      case LivenessState.smile:
        return Text('not smile', style: fontStyle);
      case LivenessState.closeEye:
        return Text('not close your eye', style: fontStyle);
      case LivenessState.notInShape:
        return Text('please inside box', style: fontStyle);
      case LivenessState.notStraight:
        return Text('please look forward', style: fontStyle);
      case LivenessState.tooDark:
        return Text('please go to brightness', style: fontStyle);
      case LivenessState.blocked:
        return Text('please check blocked', style: fontStyle);
      case LivenessState.valid:
        return Text('pass', style: fontStyle);
      default:
        return Text('');
    }
  }
}
