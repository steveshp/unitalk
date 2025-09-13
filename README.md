# Unitolk - Real-time Speech-to-Text Translator

A Flutter web application that provides real-time speech-to-text transcription using OpenAI's Whisper AI model, with support for multiple languages and translation capabilities.

## Features

- 🎙️ **Real-time Audio Recording**: Web-compatible audio capture with waveform visualization
- 🤖 **Whisper AI Integration**: Support for both Lemonfox and OpenAI Whisper APIs
- 🌍 **Multi-language Support**: Transcribe in 10+ languages
- 📝 **Live Transcription Display**: See transcriptions as they're processed
- 🎨 **Modern UI**: Dark theme with animated components
- ⚡ **Web Optimized**: Built specifically for Flutter Web platform

## Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Chrome browser (for web development)
- API keys for Whisper services (Lemonfox or OpenAI)

## Setup Instructions

### 1. Clone the Repository

```bash
cd /Users/steveshpnaver.com/flutter_projects/unitolk
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Keys

Edit the file `lib/core/constants/api_config.dart` and add your API keys:

```dart
class ApiConfig {
  // Choose one or both Whisper providers:

  // Option 1: Lemonfox (Cheaper - $0.50/3hrs)
  // Get key from: https://lemonfox.ai
  static const String lemonfoxApiKey = 'YOUR_LEMONFOX_API_KEY';

  // Option 2: OpenAI (More expensive - $1.08/3hrs)
  // Get key from: https://platform.openai.com/api-keys
  static const String openAIApiKey = 'YOUR_OPENAI_API_KEY';
}
```

### 4. Run the Application

For web development:
```bash
flutter run -d chrome
```

For production build:
```bash
flutter build web
```

## Usage

1. **Start Recording**: Click the blue microphone button to start recording
2. **Select Language**: Choose your preferred language from the dropdown
3. **Stop Recording**: Click the red stop button to end recording
4. **View Transcription**: Transcriptions appear automatically in the display area
5. **Pause/Resume**: Use the pause button during recording if needed

## Project Structure

```
lib/
├── core/
│   └── constants/
│       └── api_config.dart         # API configuration
├── data/
│   ├── models/
│   │   ├── audio_state.dart        # Audio state model
│   │   └── transcription_result.dart # Transcription model
│   └── services/
│       ├── audio_service.dart      # Audio recording service
│       └── whisper_service.dart    # Whisper API service
├── presentation/
│   ├── controllers/
│   │   └── audio_controller.dart   # GetX controller
│   ├── pages/
│   │   └── recording_page.dart     # Main UI page
│   └── widgets/
│       ├── waveform_widget.dart    # Audio waveform visualization
│       └── transcription_display.dart # Transcription display
└── main.dart                        # App entry point
```

## API Providers

### Lemonfox (Recommended)
- **Cost**: $0.50 per 3 hours
- **Quality**: Excellent
- **Speed**: Fast
- **Get API Key**: https://lemonfox.ai

### OpenAI Whisper
- **Cost**: $0.006/minute ($1.08 per 3 hours)
- **Quality**: Excellent
- **Speed**: Fast
- **Get API Key**: https://platform.openai.com/api-keys

## Supported Languages

- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Italian (it)
- Portuguese (pt)
- Russian (ru)
- Japanese (ja)
- Korean (ko)
- Chinese (zh)

## Browser Compatibility

- ✅ Chrome (Recommended)
- ✅ Edge
- ✅ Firefox
- ⚠️ Safari (Limited WebM support)

## Troubleshooting

### Microphone Permission Denied
- Ensure your browser has permission to access the microphone
- Check if you're using HTTPS (required for microphone access)

### No Transcription Results
- Verify your API keys are correctly configured
- Check your internet connection
- Ensure you've selected a supported language

### Audio Not Recording
- Refresh the page and grant microphone permissions
- Try using Chrome browser for best compatibility

## Development

To contribute or modify the application:

1. Follow Flutter best practices
2. Test on multiple browsers
3. Ensure API keys are not committed to version control
4. Run tests before committing:
```bash
flutter test
```

## License

This project is private and not for public distribution.

## Support

For issues or questions, please contact the development team.

---

**Note**: Remember to never commit your API keys to version control. Use environment variables or secure storage for production deployments.