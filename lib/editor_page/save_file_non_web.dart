import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:taglib_dart/taglib_dart.dart';

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
  final file = File(xFile.path);
  final modifiedTime = file.statSync().modified;
  final accessedTime = file.statSync().accessed;
  file.writeAsBytesSync(data);
  file.setLastModifiedSync(modifiedTime);
  file.setLastAccessedSync(accessedTime);
}
