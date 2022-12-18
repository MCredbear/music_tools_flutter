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
        return await _mp3file.read(this);
      case Format.flac:
        return await _flacFile.read(this);
      default:
        return false;
    }
  }

  void save() {}

  String getTitle() {
    switch (_format) {
      case Format.mp3:
        return _mp3file.getTitle();
      case Format.flac:
        return _flacFile.getTitle();
      default:
        return "";
    }
  }

  String getArtist() {
    switch (_format) {
      case Format.mp3:
        return _mp3file.getArtist();
      case Format.flac:
        return _flacFile.getArtist();
      default:
        return "";
    }
  }

  String getAlbum() {
    switch (_format) {
      case Format.mp3:
        return _mp3file.getAlbum();
      case Format.flac:
        return _flacFile.getAlbum();
      default:
        return "";
    }
  }

  String getAlbumArtist() {
    switch (_format) {
      case Format.mp3:
        return _mp3file.getAlbumArtist();
      case Format.flac:
        return _flacFile.getAlbumArtist();
      default:
        return "";
    }
  }

  String getLyric() {
    switch (_format) {
      case Format.mp3:
        return _mp3file.getLyric();
      case Format.flac:
        return _flacFile.getLyric();
      default:
        return "";
    }
  }

  String getComment() {
    switch (_format) {
      case Format.mp3:
        return _mp3file.getComment();
      case Format.flac:
        return _flacFile.getComment();
      default:
        return "";
    }
  }

  Uint8List getCover() {
    switch (_format) {
      case Format.mp3:
        return _mp3file.getCover();
      case Format.flac:
        return _flacFile.getCover();
      default:
        return Uint8List(0);
    }
  }

  String getTrack() {
    switch (_format) {
      case Format.mp3:
        return _mp3file.getTrack();
      case Format.flac:
        return _flacFile.getTrack();
      default:
        return "";
    }
  }

  String getCD() {
    switch (_format) {
      case Format.mp3:
        return _mp3file.getCD();
      case Format.flac:
        return _flacFile.getCD();
      default:
        return "";
    }
  }

  String getYear() {
    switch (_format) {
      case Format.mp3:
        return _mp3file.getYear();
      default:
        return "";
    }
  }

  String getEncoder() {
    switch (_format) {
      case Format.mp3:
        return _mp3file.getEncoder();
      case Format.flac:
        return _flacFile.getEncoder();
      default:
        return "";
    }
  }

  final String _path;

  late Enum _format;

  late Mp3File _mp3file;
  late FlacFile _flacFile;

  Uint8List cover = Uint8List(0);
}
