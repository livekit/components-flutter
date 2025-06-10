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

import 'package:flutter/material.dart' hide ConnectionState;

import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import '../../../context/room_context.dart';
import '../../../debug/logger.dart';

class RoomConnectionState extends StatelessWidget {
  const RoomConnectionState({
    Key? key,
    required this.builder,
  });

  final Widget Function(BuildContext context, ConnectionState connectionState) builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomContext>(builder: (context, roomCtx, child) {
      Debug.log('====>        RoomConnectionState for ${roomCtx.connectionState}');
      return Selector<RoomContext, ConnectionState>(
        selector: (context, connectionState) => roomCtx.connectionState,
        builder: (context, connectionState, child) {
          return builder(context, connectionState);
        },
      );
    });
  }
}
