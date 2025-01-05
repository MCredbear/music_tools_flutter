import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:music_tools_flutter/taglib/taglib.dart';
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;
import 'dart:js_interop' as js;

void saveAudioFile(Map<String, dynamic> params) {
  final audioFile = params['audioFile'] as AudioFile;
  final xFile = params['xFile'] as XFile;
  audioFile.setTitle(params['title']);
  audioFile.setAlbum(params['album']);
  audioFile.setArtist(params['artist']);
  audioFile.setAlbumArtist(params['albumArtist']);
  audioFile.setCD(params['cd']);
  audioFile.setTrack(params['track']);
  audioFile.setYear(params['year']);
  audioFile.setLyric(params['lyric']);
  audioFile.setComment(params['comment']);
  audioFile.setCover(params['cover']);
  final data = audioFile.save();
  final blob = web.Blob([Uint8List.fromList(data).toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  web.HTMLAnchorElement()
    ..href = url
    ..target = 'blank'
    ..download = xFile.name
    ..click();
  web.URL.revokeObjectURL(url);
}
