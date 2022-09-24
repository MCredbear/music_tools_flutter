// ignore_for_file: curly_braces_in_flow_control_structures

library taglib;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:mobx/mobx.dart';

part 'taglib.g.dart';

part 'mp3.dart';
part 'flac.dart';

class AudioFile = AudioFileBase with _$AudioFile;

abstract class AudioFileBase with Store {
  AudioFileBase(this.path);
  Future<void> read() async {
    if (extension(path).lastIndexOf(RegExp('mp3', caseSensitive: false)) != -1)
      await readMp3FIle(this);
    if (extension(path).lastIndexOf(RegExp('flac', caseSensitive: false)) != -1)
      readFlacFIle(this);
  }

  void save() {}

  String path;
  @observable
  String title = '',
      artist = '',
      album = '',
      albumArtist = '',
      lyric = '',
      comment = '',
      track = '',
      cd = '',
      year = '',
      encoder = '';
  @observable
  Uint8List cover = Uint8List(0);

  @action
  void setTitle(String title) {
    this.title = title;
  }

  @action
  void setArtist(String artist) {
    this.artist = artist;
  }

  @action
  void setAlbum(String album) {
    this.album = album;
  }

  @action
  void setAlbumArtist(String albumArtist) {
    this.albumArtist = albumArtist;
  }

  @action
  void setLyric(String lyric) {
    this.lyric = lyric;
  }

  @action
  void setComment(String comment) {
    this.comment = comment;
  }

  @action
  void setTrack(String track) {
    this.track = track;
  }

  @action
  void setCD(String cd) {
    this.cd = cd;
  }

  @action
  void setYear(String year) {
    this.year = year;
  }

  @action
  void setEncoder(String encoder) {
    this.encoder = encoder;
  }

  @action
  void setCovre(Uint8List cover) {
    this.cover = cover;
  }
}
