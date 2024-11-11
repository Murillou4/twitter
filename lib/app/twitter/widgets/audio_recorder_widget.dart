import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/providers/audio_provider.dart';

class AudioRecorderWidget extends StatefulWidget {
  const AudioRecorderWidget({super.key});

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  late final audioProvider = Provider.of<AudioProvider>(context, listen: false);
  bool _isRecording = false;
  bool _isRecordingStarted = false;
  Timer? _timer;
  Duration _recordDuration = Duration.zero;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.drawerBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isRecordingStarted) ...[
                GestureDetector(
                  onTap: () async {
                    if (_isRecording) {
                      await audioProvider.pauseRecorder();
                      setState(() {
                        _isRecording = false;
                        _timer?.cancel();
                      });
                    } else {
                      await audioProvider.resumeRecorder();
                      setState(() {
                        _isRecording = true;
                        _timer =
                            Timer.periodic(const Duration(seconds: 1), (timer) {
                          setState(() {
                            _recordDuration =
                                _recordDuration + const Duration(seconds: 1);
                          });
                        });
                      });
                    }
                  },
                  child: Icon(
                    _isRecording ? Icons.pause : Icons.mic,
                    color: Colors.white,
                  ),
                ),
                const Gap(10),
                Text(
                  _recordDuration.inSeconds.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: () async {
                    await audioProvider.setPathAndRecordAudio();
                    setState(() {
                      _isRecording = true;
                      _isRecordingStarted = true;
                      _timer =
                          Timer.periodic(const Duration(seconds: 1), (timer) {
                        setState(() {
                          _recordDuration =
                              _recordDuration + const Duration(seconds: 1);
                        });
                      });
                    });
                  },
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                  ),
                ),
                const Gap(10),
                const Text(
                  '0',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              ],
            ],
          ),
        ),
        _isRecordingStarted ? const Gap(10) : Container(),
        _isRecordingStarted
            ? GestureDetector(
                onTap: () async {
                  _isRecording = false;
                  _isRecordingStarted = false;
                  _timer?.cancel();
                  _recordDuration = Duration.zero;

                  await audioProvider.stopAndClearRecorder();
                },
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              )
            : Container(),
      ],
    );
  }
}
