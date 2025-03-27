// Copyright 2024 LiveKit, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import '../../../context/room_context.dart';
import '../theme.dart';

class JoinButtonWidget extends StatelessWidget {
  JoinButtonWidget({
    Key? key,
    required this.roomCtx,
    required this.connected,
    this.onPressed,
    this.backgroundColor = LKColors.lkBlue,
    this.overlayColor = Colors.grey,
    this.foregroundColor = Colors.white,
    this.disabledColor = Colors.grey,
    this.disabledOverlayColor = LKColors.lkLightBlue,
  }) : super(key: key);

  RoomContext roomCtx;
  bool connected;
  final Function()? onPressed;

  final Color backgroundColor;
  final Color foregroundColor;
  final Color overlayColor;
  final Color disabledColor;
  final Color disabledOverlayColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed != null
          ? onPressed!()
          : !connected
              ? roomCtx.connect()
              : null,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
            connected ? disabledColor : backgroundColor),
        foregroundColor: WidgetStateProperty.all(foregroundColor),
        overlayColor: WidgetStateProperty.all(
            connected ? overlayColor : disabledOverlayColor),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
        ),
        padding: WidgetStateProperty.all(const EdgeInsets.all(12)),
      ),
      child: Text(
        'Join Room',
        style: TextStyle(color: foregroundColor, fontSize: 16),
      ),
    );
  }
}
