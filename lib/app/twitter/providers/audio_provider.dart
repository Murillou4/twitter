import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

class AudioProvider extends ChangeNotifier {
  final _audioPlayer = AudioPlayer();
  final _audioRecorder = AudioRecorder();
  File? _recordedAudioFile;
  File? get recordedAudioFile => _recordedAudioFile;

  Future<void> clear() async {
    _audioPlayer.stop();
    _audioRecorder.stop();
    _recordedAudioFile = null;
    notifyListeners();
  }

  /// Plays the audio from the given [path] or [url].
  ///
  /// If both [path] and [url] are null, throws an exception.
  ///
  /// If [path] is not null, sets the audio player to the local file at [path].
  ///
  /// If [url] is not null, sets the audio player to the URL [url].
  ///
  /// Then plays the audio.
  Future<void> setAudioAndPlay({String? path, String? url}) async {
    try {
      if (_audioPlayer.playing) await stopAndClearPlayer();
      if (path == null && url == null) {
        throw Exception('Both path and url are null');
      }
      if (path != null) {
        await _audioPlayer.setFilePath(path);
      } else if (url != null) {
        await _audioPlayer.setUrl(url);
      }
      await _audioPlayer.play();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resumePlayer() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      rethrow;
    }
  }

  /// Pauses the audio player if it is playing.

  /// If the audio player is not playing, this is a no-op.
  Future<void> pausePlayer() async {
    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Stops the audio player and clears it from memory.
  //
  /// If the audio player is not playing, this is a no-op.
  Future<void> stopAndClearPlayer() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      rethrow;
    }
  }

  /// Starts recording audio to a file in the app's cache directory.
  ///
  /// The file name is the current time in ISO8601 format, with a .opus extension.
  ///
  /// The audio is recorded in the Opus format, and noise suppression is enabled.
  ///
  /// If the recording fails for any reason, throws an exception.
  Future<void> setPathAndRecordAudio() async {
    try {
      String cachePath = (await getApplicationCacheDirectory()).path;
      String audioPath = '$cachePath/${DateTime.now().toIso8601String()}.opus';
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.opus,
            noiseSuppress: true,
          ),
          path: audioPath,
        );
      } else {
        throw Exception('Permission denied');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resumeRecorder() async {
    try {
      await _audioRecorder.resume();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pauseRecorder() async {
    try {
      await _audioRecorder.pause();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stopAndClearRecorder() async {
    try {
      String? audioPath = await _audioRecorder.stop();
      if (audioPath != null) {
        _recordedAudioFile = File(audioPath);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
