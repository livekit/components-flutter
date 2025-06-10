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

import 'package:flutter/widgets.dart';

import 'package:responsive_builder/responsive_builder.dart';

import 'layouts.dart';

class GridLayoutBuilder implements ParticipantLayoutBuilder {
  const GridLayoutBuilder();

  @override
  Widget build(
    BuildContext context,
    List<TrackWidget> children,
    List<String> pinnedTracks,
  ) {
    var deviceScreenType = getDeviceType(MediaQuery.of(context).size);
    var orientation = MediaQuery.of(context).orientation;
    return GridView.count(
      crossAxisCount: deviceScreenType == DeviceScreenType.mobile && orientation == Orientation.portrait ? 2 : 4,
      childAspectRatio: 1.5,
      children: children.map((e) => e.widget).toList(),
    );
  }
}
