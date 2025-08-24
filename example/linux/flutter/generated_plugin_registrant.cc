//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_webrtc/flutter_web_r_t_c_plugin.h>
#include <livekit_client/live_kit_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) flutter_webrtc_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterWebRTCPlugin");
  flutter_web_r_t_c_plugin_register_with_registrar(flutter_webrtc_registrar);
  g_autoptr(FlPluginRegistrar) livekit_client_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "LiveKitPlugin");
  live_kit_plugin_register_with_registrar(livekit_client_registrar);
}
