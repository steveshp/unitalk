import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/constants/api_config.dart';
import '../../data/models/audio_state.dart';
import '../../data/models/transcription_result.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/whisper_service.dart';
import '../../data/services/auth_service.dart';

class AudioController extends GetxController {
  final AudioService _audioService = AudioService();
  late final WhisperService _whisperService;
  final AuthService _authService = AuthService();

  // Observable states
  final Rx<RecordingStatus> recordingStatus = RecordingStatus.idle.obs;
  final RxDouble amplitude = 0.0.obs;
  final Rx<Duration> recordingDuration = Duration.zero.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isProcessing = false.obs;

  // Transcription results
  final RxList<TranscriptionResult> transcriptions = <TranscriptionResult>[].obs;
  final Rx<TranscriptionResult?> currentTranscription = Rx<TranscriptionResult?>(null);

  // Configuration
  final RxString selectedLanguage = 'en'.obs;
  final RxBool autoTranscribe = true.obs;

  StreamSubscription<AudioState>? _audioStateSubscription;
  StreamSubscription<double>? _amplitudeSubscription;
  Timer? _durationTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _setupListeners();
  }

  void _initializeServices() async {
    // 먼저 로컬 설정으로 초기화 (데모 키)
    _whisperService = WhisperService(
      lemonfoxApiKey: ApiConfig.lemonfoxApiKey,
      openAIApiKey: ApiConfig.openAIApiKey,
    );

    // Firebase에서 사용자별 API 키 가져오기
    if (_authService.isAuthenticated) {
      await _whisperService.initializeFromFirebase();
    }

    if (!_whisperService.hasProviders) {
      errorMessage.value = '로그인 후 설정에서 API 키를 추가해주세요';
    }
  }

  void _setupListeners() {
    _audioStateSubscription = _audioService.stateStream.listen((state) {
      recordingStatus.value = state.status;
      if (state.error != null) {
        errorMessage.value = state.error!;
      }
      if (state.amplitude != null) {
        amplitude.value = state.amplitude!;
      }
    });

    _amplitudeSubscription = _audioService.amplitudeStream.listen((amp) {
      amplitude.value = amp;
    });
  }

  Future<void> startRecording() async {
    try {
      errorMessage.value = '';
      await _audioService.startRecording();
      _startDurationTimer();
    } catch (e) {
      errorMessage.value = 'Failed to start recording: $e';
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> pauseRecording() async {
    try {
      await _audioService.pauseRecording();
      _durationTimer?.cancel();
    } catch (e) {
      errorMessage.value = 'Failed to pause recording: $e';
      debugPrint('Error pausing recording: $e');
    }
  }

  Future<void> resumeRecording() async {
    try {
      await _audioService.resumeRecording();
      _startDurationTimer();
    } catch (e) {
      errorMessage.value = 'Failed to resume recording: $e';
      debugPrint('Error resuming recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      _durationTimer?.cancel();
      recordingDuration.value = Duration.zero;

      final audioData = await _audioService.stopRecording();

      if (audioData != null && autoTranscribe.value) {
        await transcribeAudio(audioData);
      }
    } catch (e) {
      errorMessage.value = 'Failed to stop recording: $e';
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> transcribeAudio(Uint8List audioData) async {
    try {
      isProcessing.value = true;
      errorMessage.value = '';

      final result = await _whisperService.transcribe(
        audioData,
        language: selectedLanguage.value,
      );

      if (result != null) {
        currentTranscription.value = result;
        transcriptions.add(result);
      } else {
        errorMessage.value = 'Failed to transcribe audio. Please check your API keys.';
      }
    } catch (e) {
      errorMessage.value = 'Transcription error: $e';
      debugPrint('Transcription error: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    final startTime = DateTime.now();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      recordingDuration.value = DateTime.now().difference(startTime);
    });
  }

  void clearTranscriptions() {
    transcriptions.clear();
    currentTranscription.value = null;
  }

  void setLanguage(String language) {
    selectedLanguage.value = language;
  }

  void toggleAutoTranscribe() {
    autoTranscribe.value = !autoTranscribe.value;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void onClose() {
    _durationTimer?.cancel();
    _audioStateSubscription?.cancel();
    _amplitudeSubscription?.cancel();
    _audioService.dispose();
    super.onClose();
  }
}