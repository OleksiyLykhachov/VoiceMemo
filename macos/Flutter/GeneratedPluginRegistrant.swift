//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audio_session
import just_audio
import objectbox_flutter_libs
import record_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  JustAudioPlugin.register(with: registry.registrar(forPlugin: "JustAudioPlugin"))
  ObjectboxFlutterLibsPlugin.register(with: registry.registrar(forPlugin: "ObjectboxFlutterLibsPlugin"))
  RecordMacOsPlugin.register(with: registry.registrar(forPlugin: "RecordMacOsPlugin"))
}
