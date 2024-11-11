import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/providers/audio_provider.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    super.key,
    this.audioFile,
    this.url,
    this.isDeleteble = true,
  });
  final File? audioFile;
  final String? url;
  final bool isDeleteble;
  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final audioProvider = Provider.of<AudioProvider>(context, listen: false);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
          child: GestureDetector(
            onTap: () async {
              if (widget.url != null) {
                await audioProvider.setAudioAndPlay(
                  url: widget.url,
                );
              } else {
                await audioProvider.setAudioAndPlay(
                  path: widget.audioFile!.path,
                );
              }
            },
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
          ),
        ),
        widget.isDeleteble ? const Gap(10) : const Gap(0),
        widget.isDeleteble
            ? GestureDetector(
                onTap: () async {
                  await audioProvider.clear();
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              )
            : const Gap(0),
      ],
    );
  }
}
