import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/audio_controller.dart';
import '../widgets/waveform_widget.dart';
import '../widgets/transcription_display.dart';
import '../../data/models/audio_state.dart';

class RecordingPage extends StatelessWidget {
  RecordingPage({Key? key}) : super(key: key);

  final AudioController audioController = Get.put(AudioController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        title: const Text(
          'Unitolk - Speech to Text',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Waveform visualization
            Container(
              height: 150,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F1E),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Obx(() => WaveformWidget(
                    amplitude: audioController.amplitude.value,
                    isRecording: audioController.recordingStatus.value ==
                        RecordingStatus.recording,
                    waveColor: Colors.blueAccent,
                    height: 150,
                  )),
            ),

            // Recording duration
            Obx(() => Text(
                  audioController.formatDuration(
                      audioController.recordingDuration.value),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                )),

            const SizedBox(height: 20),

            // Language selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Obx(() => DropdownButton<String>(
                    value: audioController.selectedLanguage.value,
                    dropdownColor: const Color(0xFF0F0F1E),
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox(),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish')),
                      DropdownMenuItem(value: 'fr', child: Text('French')),
                      DropdownMenuItem(value: 'de', child: Text('German')),
                      DropdownMenuItem(value: 'it', child: Text('Italian')),
                      DropdownMenuItem(value: 'pt', child: Text('Portuguese')),
                      DropdownMenuItem(value: 'ru', child: Text('Russian')),
                      DropdownMenuItem(value: 'ja', child: Text('Japanese')),
                      DropdownMenuItem(value: 'ko', child: Text('Korean')),
                      DropdownMenuItem(value: 'zh', child: Text('Chinese')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        audioController.setLanguage(value);
                      }
                    },
                  )),
            ),

            const SizedBox(height: 40),

            // Recording controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main recording button
                Obx(() {
                  final status = audioController.recordingStatus.value;
                  final isRecording = status == RecordingStatus.recording;
                  final isPaused = status == RecordingStatus.paused;

                  return GestureDetector(
                    onTap: () {
                      if (status == RecordingStatus.idle ||
                          status == RecordingStatus.stopped) {
                        audioController.startRecording();
                      } else if (isRecording || isPaused) {
                        audioController.stopRecording();
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isRecording || isPaused
                            ? Colors.redAccent
                            : Colors.blueAccent,
                        boxShadow: [
                          BoxShadow(
                            color: (isRecording || isPaused
                                    ? Colors.redAccent
                                    : Colors.blueAccent)
                                .withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        isRecording || isPaused ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 40,
                      ),
                    ).animate(
                      onPlay: (controller) {
                        if (isRecording) {
                          controller.repeat();
                        }
                      },
                    ).scale(
                      duration: const Duration(milliseconds: 600),
                      begin: const Offset(1, 1),
                      end: isRecording
                          ? const Offset(1.1, 1.1)
                          : const Offset(1, 1),
                    ),
                  );
                }),

                const SizedBox(width: 40),

                // Pause/Resume button
                Obx(() {
                  final status = audioController.recordingStatus.value;
                  if (status == RecordingStatus.recording ||
                      status == RecordingStatus.paused) {
                    return GestureDetector(
                      onTap: () {
                        if (status == RecordingStatus.recording) {
                          audioController.pauseRecording();
                        } else {
                          audioController.resumeRecording();
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0F0F1E),
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          status == RecordingStatus.paused
                              ? Icons.play_arrow
                              : Icons.pause,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    );
                  }
                  return const SizedBox(width: 60);
                }),
              ],
            ),

            const SizedBox(height: 40),

            // Processing indicator
            Obx(() {
              if (audioController.isProcessing.value) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Processing audio...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),

            // Error message
            Obx(() {
              if (audioController.errorMessage.value.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    audioController.errorMessage.value,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return const SizedBox();
            }),

            const SizedBox(height: 20),

            // Transcription display
            const TranscriptionDisplay(),

            const SizedBox(height: 20),

            // Auto-transcribe toggle
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Auto-transcribe',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Obx(() => Switch(
                        value: audioController.autoTranscribe.value,
                        onChanged: (_) {
                          audioController.toggleAutoTranscribe();
                        },
                        activeColor: Colors.blueAccent,
                      )),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}