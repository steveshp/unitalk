import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/transcription_result.dart';
import 'auth_service.dart';

abstract class WhisperProvider {
  Future<TranscriptionResult?> transcribe(Uint8List audioData, {String? language});
}

class LemonfoxProvider implements WhisperProvider {
  static const String baseUrl = 'https://api.lemonfox.ai/v1';
  final String apiKey;
  final Dio _dio;

  LemonfoxProvider({required this.apiKey})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ));

  @override
  Future<TranscriptionResult?> transcribe(Uint8List audioData, {String? language}) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          audioData,
          filename: 'audio.webm',
        ),
        'model': 'whisper-1',
        if (language != null) 'language': language,
        'response_format': 'json',
      });

      final response = await _dio.post(
        '/audio/transcriptions',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return TranscriptionResult(
          text: data['text'] ?? '',
          language: data['language'] ?? language,
          confidence: data['confidence']?.toDouble(),
          timestamp: DateTime.now(),
          provider: 'lemonfox',
        );
      }
      return null;
    } catch (e) {
      debugPrint('Lemonfox transcription error: $e');
      return null;
    }
  }
}

class OpenAIProvider implements WhisperProvider {
  static const String baseUrl = 'https://api.openai.com/v1';
  final String apiKey;
  final Dio _dio;

  OpenAIProvider({required this.apiKey})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ));

  @override
  Future<TranscriptionResult?> transcribe(Uint8List audioData, {String? language}) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          audioData,
          filename: 'audio.webm',
        ),
        'model': 'whisper-1',
        if (language != null) 'language': language,
        'response_format': 'json',
      });

      final response = await _dio.post(
        '/audio/transcriptions',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return TranscriptionResult(
          text: data['text'] ?? '',
          language: data['language'] ?? language,
          timestamp: DateTime.now(),
          provider: 'openai',
        );
      }
      return null;
    } catch (e) {
      debugPrint('OpenAI transcription error: $e');
      return null;
    }
  }
}

class WhisperService {
  final List<WhisperProvider> _providers = [];
  WhisperProvider? _primaryProvider;
  final AuthService _authService = AuthService();

  WhisperService({
    String? lemonfoxApiKey,
    String? openAIApiKey,
  }) {
    // Initialize providers based on available API keys
    if (lemonfoxApiKey != null && lemonfoxApiKey.isNotEmpty) {
      final lemonfox = LemonfoxProvider(apiKey: lemonfoxApiKey);
      _providers.add(lemonfox);
      _primaryProvider = lemonfox; // Lemonfox is preferred (cheaper)
    }

    if (openAIApiKey != null && openAIApiKey.isNotEmpty) {
      final openai = OpenAIProvider(apiKey: openAIApiKey);
      _providers.add(openai);
      _primaryProvider ??= openai; // Use OpenAI if Lemonfox not available
    }
  }

  // Firebase에서 API 키를 가져와서 프로바이더 초기화
  Future<void> initializeFromFirebase() async {
    try {
      final apiKeys = await _authService.getApiKeys();

      _providers.clear();
      _primaryProvider = null;

      // Lemonfox 프로바이더 추가 (우선순위 높음)
      if (apiKeys['lemonfoxApiKey'] != null && apiKeys['lemonfoxApiKey']!.isNotEmpty) {
        final lemonfox = LemonfoxProvider(apiKey: apiKeys['lemonfoxApiKey']!);
        _providers.add(lemonfox);
        _primaryProvider = lemonfox;
      }

      // OpenAI 프로바이더 추가 (폴백용)
      if (apiKeys['openAIApiKey'] != null && apiKeys['openAIApiKey']!.isNotEmpty) {
        final openai = OpenAIProvider(apiKey: apiKeys['openAIApiKey']!);
        _providers.add(openai);
        _primaryProvider ??= openai;
      }

      debugPrint('WhisperService initialized with ${_providers.length} providers');
    } catch (e) {
      debugPrint('Error initializing WhisperService from Firebase: $e');
    }
  }

  Future<TranscriptionResult?> transcribe(
    Uint8List audioData, {
    String? language,
    bool useFallback = true,
  }) async {
    if (_providers.isEmpty) {
      debugPrint('No Whisper providers configured');
      return null;
    }

    // Try primary provider first
    if (_primaryProvider != null) {
      final result = await _primaryProvider!.transcribe(audioData, language: language);
      if (result != null) {
        return result;
      }
    }

    // If primary fails and fallback is enabled, try other providers
    if (useFallback) {
      for (final provider in _providers) {
        if (provider != _primaryProvider) {
          final result = await provider.transcribe(audioData, language: language);
          if (result != null) {
            return result;
          }
        }
      }
    }

    return null;
  }

  bool get hasProviders => _providers.isNotEmpty;

  String get activeProvider {
    if (_primaryProvider is LemonfoxProvider) return 'Lemonfox';
    if (_primaryProvider is OpenAIProvider) return 'OpenAI';
    return 'None';
  }
}