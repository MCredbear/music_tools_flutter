// ignore_for_file: curly_braces_in_flow_control_structures

library taglib;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

part 'mp3.dart';
part 'flac.dart';

enum Format { unknow, mp3, flac }

class AudioFile {
  AudioFile(this._path) {
    if (extension(_path).lastIndexOf(RegExp('mp3', caseSensitive: false)) !=
        -1) {
      _format = Format.mp3;
      _mp3file = Mp3File(this);
    } else if (extension(_path)
            .lastIndexOf(RegExp('flac', caseSensitive: false)) !=
        -1) {
      _format = Format.flac;
      _flacFile = FlacFile(this);
    } else
      _format = Format.unknow;
  }

  Future<bool> read() async {
    switch (_format) {
      case Format.mp3:
        return await _mp3file!.read();
      case Format.flac:
        return await _flacFile!.read();
      default:
        return false;
    }
  }

  Future<bool> save() async {
    switch (_format) {
      case Format.mp3:
        return await _mp3file!.save();
      case Format.flac:
        return await _flacFile!.save();
      default:
        return false;
    }
  }

  String? getTitle() {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.getTitle();
      case Format.flac:
        return _flacFile!.getTitle();
      default:
        return null;
    }
  }

  String? getArtist() {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.getArtist();
      case Format.flac:
        return _flacFile!.getArtist();
      default:
        return null;
    }
  }

  String? getAlbum() {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.getAlbum();
      case Format.flac:
        return _flacFile!.getAlbum();
      default:
        return null;
    }
  }

  String? getAlbumArtist() {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.getAlbumArtist();
      case Format.flac:
        return _flacFile!.getAlbumArtist();
      default:
        return null;
    }
  }

  String? getLyric() {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.getLyric();
      case Format.flac:
        return _flacFile!.getLyric();
      default:
        return null;
    }
  }

  String? getComment() {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.getComment();
      case Format.flac:
        return _flacFile!.getComment();
      default:
        return null;
    }
  }

  Uint8List? getCover() {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.getCover();
      case Format.flac:
        return _flacFile!.getCover();
      default:
        return null;
    }
  }

  String? getTrack() {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.getTrack();
      case Format.flac:
        return _flacFile!.getTrack();
      default:
        return null;
    }
  }

  String? getCD() {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.getCD();
      case Format.flac:
        return _flacFile!.getCD();
      default:
        return null;
    }
  }

  String? getYear() {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.getYear();
      case Format.flac:
        return _flacFile!.getYear();
      default:
        return null;
    }
  }

  String? getEncoder() {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.getEncoder();
      case Format.flac:
        return _flacFile!.getEncoder();
      default:
        return null;
    }
  }

  void setTitle(String? title) {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.setTitle(title);
      case Format.flac:
        return _flacFile!.setTitle(title);
    }
  }

  void setArtist(String? artist) {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.setArtist(artist);
      case Format.flac:
        return _flacFile!.setArtist(artist);
    }
  }

  void setAlbum(String? album) {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.setAlbum(album);
      case Format.flac:
        return _flacFile!.setAlbum(album);
    }
  }

  void setAlbumArtist(String? albumArtist) {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.setAlbumArtist(albumArtist);
      case Format.flac:
        return _flacFile!.setAlbumArtist(albumArtist);
    }
  }

  void setLyric(String? lyric) {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.setLyric(lyric);
      case Format.flac:
        return _flacFile!.setLyric(lyric);
    }
  }

  void setComment(String? comment) {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.setComment(comment);
      case Format.flac:
        return _flacFile!.setComment(comment);
    }
  }

  void setCover(Uint8List? cover) {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.setCover(cover);
      case Format.flac:
        return _flacFile!.setCover(cover);
    }
  }

  void setTrack(String? track) {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.setTrack(track);
      case Format.flac:
        return _flacFile!.setTrack(track);
    }
  }

  void setCD(String? cd) {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.setCD(cd);
      case Format.flac:
        return _flacFile!.setCD(cd);
    }
  }

  void setYear(String? year) {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.setYear(year);
      case Format.flac:
        return _flacFile!.setYear(year);
    }
  }

  void setEncoder(String? encoder) {
    switch (_format) {
      case Format.mp3:
        return _mp3file!.setEncoder(encoder);
      case Format.flac:
        return _flacFile!.setEncoder(encoder);
    }
  }

  final String _path;

  late Enum _format;

  Mp3File? _mp3file;
  FlacFile? _flacFile;

  Uint8List? cover;
}
