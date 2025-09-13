import 'dart:typed_data';

enum RecordingStatus {
  idle,
  recording,
  paused,
  stopped,
  processing,
}

class AudioState {
  final RecordingStatus status;
  final Duration? duration;
  final double? amplitude;
  final String? filePath;
  final Uint8List? audioData;
  final String? error;

  AudioState({
    required this.status,
    this.duration,
    this.amplitude,
    this.filePath,
    this.audioData,
    this.error,
  });

  AudioState copyWith({
    RecordingStatus? status,
    Duration? duration,
    double? amplitude,
    String? filePath,
    Uint8List? audioData,
    String? error,
  }) {
    return AudioState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      amplitude: amplitude ?? this.amplitude,
      filePath: filePath ?? this.filePath,
      audioData: audioData ?? this.audioData,
      error: error ?? this.error,
    );
  }

  factory AudioState.initial() {
    return AudioState(status: RecordingStatus.idle);
  }
}