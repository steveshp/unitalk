class ApiConfig {
  // Whisper API Keys
  // Lemonfox API (Preferred - Cheaper: $0.50 per 3 hours)
  // Get your API key from: https://lemonfox.ai
  static const String lemonfoxApiKey = 'demo-key-replace-with-real-key'; // Add your Lemonfox API key here

  // OpenAI API (Fallback - More expensive: $1.08 per 3 hours)
  // Get your API key from: https://platform.openai.com/api-keys
  static const String openAIApiKey = 'demo-key-replace-with-real-key'; // Add your OpenAI API key here

  // Google Translate API (For translation features)
  // Get your API key from: https://cloud.google.com/translate
  static const String googleTranslateApiKey = ''; // Add your Google Translate API key here

  // Firebase Configuration (For multi-device sync)
  // Configure in Firebase Console: https://console.firebase.google.com
  static const bool useFirebase = false; // Set to true to enable Firebase features
}