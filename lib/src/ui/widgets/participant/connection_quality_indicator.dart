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

import 'package:livekit_client/livekit_client.dart';

class ConnectionQualityIndicatorWidget extends StatelessWidget {
  final ConnectionQuality connectionQuality;

  const ConnectionQualityIndicatorWidget({super.key, required this.connectionQuality});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Icon(
        connectionQuality == ConnectionQuality.poor ? Icons.wifi_off_outlined : Icons.wifi,
        color: {
          ConnectionQuality.excellent: Colors.green,
          ConnectionQuality.good: Colors.orange,
          ConnectionQuality.poor: Colors.red,
          ConnectionQuality.lost: Colors.grey,
          ConnectionQuality.unknown: Colors.grey,
        }[connectionQuality],
        size: 20,
      ),
    );
  }
}
