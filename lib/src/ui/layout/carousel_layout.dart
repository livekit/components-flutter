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

import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:responsive_builder/responsive_builder.dart';

import 'layouts.dart';

class CarouselLayoutBuilder implements ParticipantLayoutBuilder {
  const CarouselLayoutBuilder();

  @override
  Widget build(
    BuildContext context,
    List<TrackWidget> children,
    List<String> pinnedTracks,
  ) {
    List<Widget> pinnedWidgets = [];
    List<Widget> otherWidgets = [];

    /// Move focused tracks to the pinned list
    for (var sid in pinnedTracks) {
      var widget = children
          .where((element) => element.trackIdentifier.identifier == sid)
          .map((e) => e.widget)
          .firstOrNull;
      if (widget != null) {
        pinnedWidgets.add(widget);
      }
    }

    Widget? singlePinnedWidget = pinnedWidgets.firstOrNull;
    if (pinnedWidgets.length > 1) {
      otherWidgets.addAll(pinnedWidgets.skip(1).toList());
    }

    for (var child in children) {
      if (!pinnedTracks.contains(child.trackIdentifier.identifier)) {
        otherWidgets.add(child.widget);
      }
    }

    if (pinnedWidgets.isEmpty) {
      singlePinnedWidget = otherWidgets.firstOrNull;
      if (otherWidgets.length > 1) {
        otherWidgets.removeAt(0);
      }
    }

    var deviceScreenType = getDeviceType(MediaQuery.of(context).size);
    var orientation = MediaQuery.of(context).orientation;
    var isMobile = deviceScreenType == DeviceScreenType.mobile;
    if (isMobile && orientation == Orientation.portrait) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (children.length > 1)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: math.max(0, otherWidgets.length),
                itemBuilder: (BuildContext context, int index) => SizedBox(
                  width: 120,
                  height: 80,
                  child: otherWidgets[index],
                ),
              ),
            ),
          Expanded(
            child: singlePinnedWidget ?? Container(),
          ),
        ],
      );
    }
    return Row(
      children: [
        if (children.length > 1)
          SizedBox(
            width: isMobile && orientation == Orientation.landscape ? 120 : 180,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: math.max(0, otherWidgets.length),
              itemBuilder: (BuildContext context, int index) => SizedBox(
                width: 180,
                height: 120,
                child: otherWidgets[index],
              ),
            ),
          ),
        Expanded(
          child: singlePinnedWidget ?? Container(),
        ),
      ],
    );
  }
}
