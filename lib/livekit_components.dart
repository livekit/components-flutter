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

library livekit_components;

export 'src/context/chat_context.dart';
export 'src/context/room_context.dart';
export 'src/context/participant_context.dart';
export 'src/context/track_reference_context.dart';

export 'src/debug/logger.dart';

export 'src/types/agent_state.dart';
export 'src/types/transcription.dart';

export 'src/ui/builder/camera_preview.dart';
export 'src/ui/builder/room/chat_toggle.dart';
export 'src/ui/builder/room/chat.dart';
export 'src/ui/builder/room/disconnect_button.dart';
export 'src/ui/builder/room/join_button.dart';
export 'src/ui/builder/room/media_device_select_button.dart';
export 'src/ui/builder/room/media_device.dart';
export 'src/ui/builder/room/room_connection_state.dart';
export 'src/ui/builder/room/room_metadata.dart';
export 'src/ui/builder/room/room_name.dart';
export 'src/ui/builder/room/room_participants.dart';
export 'src/ui/builder/room/room.dart';
export 'src/ui/builder/room/screenshare_toggle.dart';
export 'src/ui/builder/room/room_active_recording_indicator.dart';
export 'src/ui/builder/room/transcription.dart';

export 'src/ui/builder/participant/participant_track.dart';
export 'src/ui/builder/participant/participant_attributes.dart';
export 'src/ui/builder/participant/participant_loop.dart';
export 'src/ui/builder/participant/participant_metadata.dart';
export 'src/ui/builder/participant/participant_muted_indicator.dart';
export 'src/ui/builder/participant/participant_name.dart';
export 'src/ui/builder/participant/participant_kind.dart';
export 'src/ui/builder/participant/participant_permissions.dart';
export 'src/ui/builder/participant/participant_transcription.dart';
export 'src/ui/builder/participant/participant_selector.dart';

export 'src/ui/builder/track/connection_quality_indicator.dart';
export 'src/ui/builder/track/e2e_encryption_indicator.dart';
export 'src/ui/builder/track/is_speaking_indicator.dart';

export 'src/ui/widgets/participant/connection_quality_indicator.dart';
export 'src/ui/widgets/participant/participant_status_bar.dart';
export 'src/ui/widgets/participant/participant_tile_widget.dart';
export 'src/ui/widgets/participant/is_speaking_indicator.dart';

export 'src/ui/widgets/room/camera_select_button.dart';
export 'src/ui/widgets/room/chat_toggle.dart';
export 'src/ui/widgets/room/chat_widget.dart';
export 'src/ui/widgets/room/media_device_select_button.dart';
export 'src/ui/widgets/room/microphone_select_button.dart';
export 'src/ui/widgets/room/control_bar.dart';
export 'src/ui/widgets/room/disconnect_button.dart';
export 'src/ui/widgets/room/screenshare_toggle.dart';
export 'src/ui/widgets/room/clear_pin_button.dart';
export 'src/ui/widgets/participant/transcription_widget.dart';

export 'src/ui/widgets/track/audio_visualizer_widget.dart';
export 'src/ui/widgets/track/focus_toggle.dart';
export 'src/ui/widgets/track/no_track_widget.dart';
export 'src/ui/widgets/track/video_track_widget.dart';
export 'src/ui/widgets/track/track_stats_widget.dart';
export 'src/ui/widgets/theme.dart';
export 'src/ui/widgets/toast.dart';
export 'src/ui/widgets/camera_preview.dart';

export 'src/ui/layout/layouts.dart';
export 'src/ui/layout/grid_layout.dart';
export 'src/ui/layout/carousel_layout.dart';

export 'src/ui/prejoin/prejoin.dart';
