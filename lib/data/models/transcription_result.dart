class TranscriptionResult {
  final String text;
  final String? language;
  final double? confidence;
  final Duration? duration;
  final DateTime timestamp;
  final String provider; // 'lemonfox' or 'openai'

  TranscriptionResult({
    required this.text,
    this.language,
    this.confidence,
    this.duration,
    required this.timestamp,
    required this.provider,
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      text: json['text'] ?? '',
      language: json['language'],
      confidence: json['confidence']?.toDouble(),
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      timestamp: DateTime.parse(json['timestamp']),
      provider: json['provider'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'language': language,
      'confidence': confidence,
      'duration': duration?.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'provider': provider,
    };
  }

  TranscriptionResult copyWith({
    String? text,
    String? language,
    double? confidence,
    Duration? duration,
    DateTime? timestamp,
    String? provider,
  }) {
    return TranscriptionResult(
      text: text ?? this.text,
      language: language ?? this.language,
      confidence: confidence ?? this.confidence,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
      provider: provider ?? this.provider,
    );
  }
}