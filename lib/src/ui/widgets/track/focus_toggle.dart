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

import 'package:provider/provider.dart';

import '../../../context/room_context.dart';
import '../../../context/track_reference_context.dart';
import '../../../debug/logger.dart';

class FocusToggle extends StatelessWidget {
  const FocusToggle({
    super.key,
    this.showBackToGridView = false,
  });

  final bool showBackToGridView;

  @override
  Widget build(BuildContext context) {
    final roomCtx = context.read<RoomContext>();
    final trackCtx = Provider.of<TrackReferenceContext?>(context);
    final String? sid = trackCtx?.sid;
    Debug.log('===>     FocusButton for $sid');
    if (trackCtx == null) {
      return const SizedBox();
    }
    final shouldShowBackToGridView = roomCtx.pinnedTracks.contains(sid) && sid == roomCtx.pinnedTracks.first;

    if (shouldShowBackToGridView && !showBackToGridView) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: IconButton(
        icon: Icon(shouldShowBackToGridView ? Icons.grid_view : Icons.open_in_full),
        color: Colors.white70,
        onPressed: () {
          if (sid == null) {
            return;
          }
          if (shouldShowBackToGridView) {
            roomCtx.clearPinnedTracks();
          } else {
            roomCtx.pinningTrack(sid);
          }
        },
      ),
    );
  }
}
