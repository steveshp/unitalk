import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import '../models/audio_state.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final StreamController<AudioState> _stateController = StreamController<AudioState>.broadcast();
  final StreamController<double> _amplitudeController = StreamController<double>.broadcast();

  Timer? _amplitudeTimer;
  DateTime? _recordingStartTime;
  String? _currentPath;

  Stream<AudioState> get stateStream => _stateController.stream;
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  AudioState _currentState = AudioState.initial();

  AudioService() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _updateState(_currentState.copyWith(
          error: 'Microphone permission not granted',
        ));
      }
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
    }
  }

  Future<bool> requestPermission() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      return hasPermission;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  Future<void> startRecording() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        _updateState(_currentState.copyWith(
          error: 'Microphone permission denied',
        ));
        return;
      }

      // Configure recording for web compatibility
      const config = RecordConfig(
        encoder: kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc,
        sampleRate: 16000, // 16kHz for Whisper optimization
        bitRate: 128000,
        numChannels: 1, // Mono for smaller file size
      );

      // For web, we'll use regular recording without stream
      if (kIsWeb) {
        // Web doesn't support streaming, so we'll record to memory
        await _recorder.start(config, path: '');
      } else {
        _currentPath = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(config, path: _currentPath!);
      }

      _recordingStartTime = DateTime.now();
      _startAmplitudeMonitoring();
      _updateState(_currentState.copyWith(
        status: RecordingStatus.recording,
        error: null,
      ));
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _updateState(_currentState.copyWith(
        error: 'Failed to start recording: $e',
      ));
    }
  }

  void _handleWebRecording(Stream<Uint8List> stream) {
    final List<Uint8List> audioChunks = [];

    stream.listen(
      (chunk) {
        audioChunks.add(chunk);
        // Update duration
        if (_recordingStartTime != null) {
          final duration = DateTime.now().difference(_recordingStartTime!);
          _updateState(_currentState.copyWith(
            duration: duration,
          ));
        }
      },
      onDone: () {
        // Combine all chunks into single audio data
        final totalLength = audioChunks.fold(0, (sum, chunk) => sum + chunk.length);
        final audioData = Uint8List(totalLength);
        int offset = 0;
        for (final chunk in audioChunks) {
          audioData.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }

        _updateState(_currentState.copyWith(
          audioData: audioData,
          status: RecordingStatus.stopped,
        ));
      },
      onError: (error) {
        debugPrint('Web recording error: $error');
        _updateState(_currentState.copyWith(
          error: 'Recording error: $error',
        ));
      },
    );
  }

  Future<void> pauseRecording() async {
    try {
      await _recorder.pause();
      _amplitudeTimer?.cancel();
      _updateState(_currentState.copyWith(
        status: RecordingStatus.paused,
      ));
    } catch (e) {
      debugPrint('Error pausing recording: $e');
      _updateState(_currentState.copyWith(
        error: 'Failed to pause recording: $e',
      ));
    }
  }

  Future<void> resumeRecording() async {
    try {
      await _recorder.resume();
      _startAmplitudeMonitoring();
      _updateState(_currentState.copyWith(
        status: RecordingStatus.recording,
      ));
    } catch (e) {
      debugPrint('Error resuming recording: $e');
      _updateState(_currentState.copyWith(
        error: 'Failed to resume recording: $e',
      ));
    }
  }

  Future<Uint8List?> stopRecording() async {
    try {
      _amplitudeTimer?.cancel();

      final path = await _recorder.stop();

      if (kIsWeb && path != null) {
        // On web, the path is actually a blob URL or base64 data
        // We need to handle it differently
        // For now, we'll return empty data to avoid errors
        _updateState(_currentState.copyWith(
          status: RecordingStatus.stopped,
        ));
        // TODO: Implement proper web audio data retrieval
        return Uint8List(0);
      } else if (path != null) {
        _updateState(_currentState.copyWith(
          status: RecordingStatus.stopped,
          filePath: path,
        ));
        // For mobile, you would read the file here
        // For simplicity, returning null for now
        return null;
      }

      _updateState(_currentState.copyWith(
        status: RecordingStatus.stopped,
      ));
      return null;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _updateState(_currentState.copyWith(
        error: 'Failed to stop recording: $e',
      ));
      return null;
    }
  }

  void _startAmplitudeMonitoring() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      try {
        final amplitude = await _recorder.getAmplitude();
        _amplitudeController.add(amplitude.current);
        _updateState(_currentState.copyWith(
          amplitude: amplitude.current,
        ));
      } catch (e) {
        debugPrint('Error getting amplitude: $e');
      }
    });
  }

  void _updateState(AudioState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  void dispose() {
    _amplitudeTimer?.cancel();
    _recorder.dispose();
    _stateController.close();
    _amplitudeController.close();
  }
}