# VoiceLoop

## 架构概述

VoiceLoop 是一个基于 Flutter 的实时离线语音翻译应用，集成了 ASR（语音识别）、VAD（语音活动检测）、TTS（文本转语音）和翻译能力。应用采用模块化扁平化目录结构。

- **状态管理**：Riverpod (flutter_riverpod)
- **路由**：go_router
- **主题**：纯 Flutter Material 3 (ColorScheme.fromSeed)
- **ASR 引擎**：sherpa_onnx (SenseVoice Small / Whisper / Zipformer)
- **VAD 引擎**：sherpa_onnx (Silero VAD)
- **TTS 引擎**：sherpa_onnx (Piper / Matcha) + flutter_tts 备用
- **翻译引擎**：平台通道 (Android: ML Kit / iOS: Apple Translation)
- **存储**：JSON 文件 (sessions.json / messages.json)
- **GPU 加速**：sherpa_onnx 自动使用 NNAPI (Android) / CoreML (iOS)

## 目录结构

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── languages.dart
│   ├── extensions/
│   │   └── context_extensions.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── logger.dart
├── models/
│   ├── app_settings.dart
│   ├── asr_model_info.dart
│   ├── translation_message.dart
│   ├── translation_result.dart
│   ├── translation_session.dart
│   └── tts_model_info.dart
├── services/
│   ├── asr_service.dart
│   ├── audio_pipeline.dart
│   ├── audio_player_service.dart
│   ├── audio_recorder_service.dart
│   ├── database_service.dart
│   ├── model_manager.dart
│   ├── session_exporter.dart
│   ├── tts_service.dart
│   └── vad_service.dart
├── providers/
│   ├── pipeline_provider.dart
│   ├── service_provider.dart
│   ├── session_provider.dart
│   ├── settings_provider.dart
│   └── translation_provider.dart
├── pages/
│   ├── home_page.dart
│   ├── mirror_page.dart
│   ├── history_page.dart
│   ├── session_detail_page.dart
│   └── settings_page.dart
├── widgets/
│   ├── empty_state.dart
│   ├── language_selector.dart
│   ├── message_bubble.dart
│   ├── record_button.dart
│   └── translation_card.dart
└── platform/
    ├── translation_channel.dart
    └── system_audio_channel.dart
```

## 编译命令

```bash
export PATH="/root/flutter/bin:$PATH" && cd /root/tts && flutter analyze
```

## 平台原生文件

### Android
- `android/app/src/main/kotlin/com/voiceloop/voice_loop/TranslationPlugin.kt` — ML Kit 翻译
- `android/app/src/main/kotlin/com/voiceloop/voice_loop/SystemAudioPlugin.kt` — 系统音频捕获
- `android/app/src/main/kotlin/com/voiceloop/voice_loop/MediaProjectionService.kt` — 前台服务

### iOS
- `ios/Runner/AppDelegate.swift` — 平台通道注册
