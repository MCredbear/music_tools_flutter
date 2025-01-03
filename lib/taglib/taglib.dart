// ignore_for_file: curly_braces_in_flow_control_structures

library taglib;

import 'dart:convert';
import 'package:flutter/foundation.dart';

part 'mp3.dart';
part 'flac.dart';

enum Format { unknow, mp3, flac }

class AudioFile {
  AudioFile(Uint8List rawData) : _rawData = rawData {
    // guess format from first bytes of rawData
    if (_rawData.length > 4) {
      if (_rawData[0] == 0x49 && _rawData[1] == 0x44 && _rawData[2] == 0x33) {
        _format = Format.mp3;
        _mp3file = Mp3File(this);
      } else if (_rawData[0] == 0x66 &&
          _rawData[1] == 0x4C &&
          _rawData[2] == 0x61 &&
          _rawData[3] == 0x43) {
        _format = Format.flac;
        _flacFile = FlacFile(this);
      } else
        _format = Format.unknow;
    } else
      _format = Format.unknow;

    switch (_format) {
      case Format.mp3:
        _mp3file = Mp3File(this);
        break;
      case Format.flac:
        _flacFile = FlacFile(this);
        break;
      default:
        break;
    }
  }

  List<int> save() {
    switch (_format) {
      case Format.mp3:
        _mp3file!.save();
        break;
      case Format.flac:
        _flacFile!.save();
        break;
      default:
        break;
    }

    return _rawData;
  }

  Format get format => _format;

  String? getTitle() {
    return switch (_format) {
      Format.mp3 => _mp3file!.getTitle(),
      Format.flac => _flacFile!.getTitle(),
      _ => null
    };
  }

  String? getArtist() {
    return switch (_format) {
      Format.mp3 => _mp3file!.getArtist(),
      Format.flac => _flacFile!.getArtist(),
      _ => null
    };
  }

  String? getAlbum() {
    return switch (_format) {
      Format.mp3 => _mp3file!.getAlbum(),
      Format.flac => _flacFile!.getAlbum(),
      _ => null
    };
  }

  String? getAlbumArtist() {
    return switch (_format) {
      Format.mp3 => _mp3file!.getAlbumArtist(),
      Format.flac => _flacFile!.getAlbumArtist(),
      _ => null
    };
  }

  String? getLyric() {
    return switch (_format) {
      Format.mp3 => _mp3file!.getLyric(),
      Format.flac => _flacFile!.getLyric(),
      _ => null
    };
  }

  String? getComment() {
    return switch (_format) {
      Format.mp3 => _mp3file!.getComment(),
      Format.flac => _flacFile!.getComment(),
      _ => null
    };
  }

  Uint8List? getCover() {
    return switch (_format) {
      Format.mp3 => _mp3file!.getCover(),
      Format.flac => _flacFile!.getCover(),
      _ => null
    };
  }

  String? getTrack() {
    return switch (_format) {
      Format.mp3 => _mp3file!.getTrack(),
      Format.flac => _flacFile!.getTrack(),
      _ => null
    };
  }

  String? getCD() {
    return switch (_format) {
      Format.mp3 => _mp3file!.getCD(),
      Format.flac => _flacFile!.getCD(),
      _ => null
    };
  }

  String? getYear() {
    return switch (_format) {
      Format.mp3 => _mp3file!.getYear(),
      Format.flac => _flacFile!.getYear(),
      _ => null
    };
  }

  String? getEncoder() {
    return switch (_format) {
      Format.mp3 => _mp3file!.getEncoder(),
      Format.flac => _flacFile!.getEncoder(),
      _ => null
    };
  }

  void setTitle(String? title) {
    return switch (_format) {
      Format.mp3 => _mp3file!.setTitle(title),
      Format.flac => _flacFile!.setTitle(title),
      _ => null
    };
  }

  void setArtist(String? artist) {
    return switch (_format) {
      Format.mp3 => _mp3file!.setArtist(artist),
      Format.flac => _flacFile!.setArtist(artist),
      _ => null
    };
  }

  void setAlbum(String? album) {
    return switch (_format) {
      Format.mp3 => _mp3file!.setAlbum(album),
      Format.flac => _flacFile!.setAlbum(album),
      _ => null
    };
  }

  void setAlbumArtist(String? albumArtist) {
    return switch (_format) {
      Format.mp3 => _mp3file!.setAlbumArtist(albumArtist),
      Format.flac => _flacFile!.setAlbumArtist(albumArtist),
      _ => null
    };
  }

  void setLyric(String? lyric) {
    return switch (_format) {
      Format.mp3 => _mp3file!.setLyric(lyric),
      Format.flac => _flacFile!.setLyric(lyric),
      _ => null
    };
  }

  void setComment(String? comment) {
    return switch (_format) {
      Format.mp3 => _mp3file!.setComment(comment),
      Format.flac => _flacFile!.setComment(comment),
      _ => null
    };
  }

  void setCover(Uint8List? cover) {
    return switch (_format) {
      Format.mp3 => _mp3file!.setCover(cover),
      Format.flac => _flacFile!.setCover(cover),
      _ => null
    };
  }

  void setTrack(String? track) {
    return switch (_format) {
      Format.mp3 => _mp3file!.setTrack(track),
      Format.flac => _flacFile!.setTrack(track),
      _ => null
    };
  }

  void setCD(String? cd) {
    return switch (_format) {
      Format.mp3 => _mp3file!.setCD(cd),
      Format.flac => _flacFile!.setCD(cd),
      _ => null
    };
  }

  void setYear(String? year) {
    return switch (_format) {
      Format.mp3 => _mp3file!.setYear(year),
      Format.flac => _flacFile!.setYear(year),
      _ => null
    };
  }

  void setEncoder(String? encoder) {
    return switch (_format) {
      Format.mp3 => _mp3file!.setEncoder(encoder),
      Format.flac => _flacFile!.setEncoder(encoder),
      _ => null
    };
  }

  late Format _format;

  List<int> _rawData = [];

  Mp3File? _mp3file;
  FlacFile? _flacFile;
}
