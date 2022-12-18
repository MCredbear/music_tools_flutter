part of 'taglib.dart';

class FlacMetaBlock {
  FlacMetaBlock(this.type, this.data);
  int type;
  List<int> data;
}

/// Vorbis Comment or called Xiph Comment
class VorbisComment {
  VorbisComment(this._flacMetaBlock) {
    int vendorSize = _flacMetaBlock.data[0] |
        _flacMetaBlock.data[1] << 8 |
        _flacMetaBlock.data[2] << 16 |
        _flacMetaBlock.data[3] << 24;
    int commentsCount = _flacMetaBlock.data[4 + vendorSize] |
        _flacMetaBlock.data[5 + vendorSize] << 8 |
        _flacMetaBlock.data[6 + vendorSize] << 16 |
        _flacMetaBlock.data[7 + vendorSize] << 24;
    int pos = 8 + vendorSize;
    for (int i = 0; i < commentsCount; i++) {
      int commentSize = _flacMetaBlock.data[pos] |
          _flacMetaBlock.data[pos + 1] << 8 |
          _flacMetaBlock.data[pos + 2] << 16 |
          _flacMetaBlock.data[pos + 3] << 24;
      if (commentSize > 0) {
        var comment =
            _flacMetaBlock.data.sublist(pos + 4, pos + 4 + commentSize);
        comments.putIfAbsent(
            comment.sublist(0, comment.indexOf('='.codeUnitAt(0))),
            () => comment.sublist(comment.indexOf('='.codeUnitAt(0)) + 1));
      }
      pos += 4 + commentSize;
    }
  }

  final FlacMetaBlock _flacMetaBlock;
  Map<List<int>, List<int>> comments = {};

  String getTitle() {
    for (var name in comments.keys) {
      if (listEquals(name, 'TITLE'.codeUnits)) {
        return utf8.decode(comments[name]!);
      }
    }
    return '';
  }

  String getArtist() {
    for (var name in comments.keys) {
      if (listEquals(name, 'ARTIST'.codeUnits)) {
        return utf8.decode(comments[name]!);
      }
    }
    return '';
  }

  String getAlbum() {
    for (var name in comments.keys) {
      if (listEquals(name, 'ALBUM'.codeUnits)) {
        return utf8.decode(comments[name]!);
      }
    }
    return '';
  }

  String getAlbumArtist() {
    for (var name in comments.keys) {
      if (listEquals(name, 'ALBUMARTIST'.codeUnits)) {
        return utf8.decode(comments[name]!);
      } else if (listEquals(name, 'ALBUM_ARTIST'.codeUnits)) {
        return utf8.decode(comments[name]!);
      }
    }
    return '';
  }

  String getLyric() {
    for (var name in comments.keys) {
      if (listEquals(name, 'LYRICS'.codeUnits)) {
        return utf8.decode(comments[name]!);
      }
    }
    return '';
  }

  String getComment() {
    for (var name in comments.keys) {
      if (listEquals(name, 'DESCRIPTION'.codeUnits)) {
        return utf8.decode(comments[name]!);
      } else if (listEquals(name, 'COMMENT'.codeUnits)) {
        return utf8.decode(comments[name]!);
      }
    }
    return '';
  }

  String getTrack() {
    for (var name in comments.keys) {
      if (listEquals(name, 'TRACKNUMBER'.codeUnits)) {
        return utf8.decode(comments[name]!);
      } else if (listEquals(name, 'TRACKNUM'.codeUnits)) {
        return utf8.decode(comments[name]!);
      }
    }
    return '';
  }

  String getCD() {
    for (var name in comments.keys) {
      if (listEquals(name, 'DISCNUMBER'.codeUnits)) {
        return utf8.decode(comments[name]!);
      }
    }
    return '';
  }

  String getYear() {
    for (var name in comments.keys) {
      if (listEquals(name, 'DATE'.codeUnits)) {
        return utf8.decode(comments[name]!);
      } else if (listEquals(name, 'YEAR'.codeUnits)) {
        return utf8.decode(comments[name]!);
      }
    }
    return '';
  }

  String getEncoder() {
    for (var name in comments.keys) {
      if (listEquals(name, 'ENCODER'.codeUnits)) {
        return utf8.decode(comments[name]!);
      }
    }
    return '';
  }
}

class Picture {
  Picture(this._flacMetaBlock) {
    int mimeTypeLength = _flacMetaBlock.data[4] << 24 |
        _flacMetaBlock.data[5] << 16 |
        _flacMetaBlock.data[6] << 8 |
        _flacMetaBlock.data[7];
    int descStringLength = _flacMetaBlock.data[8 + mimeTypeLength] << 24 |
        _flacMetaBlock.data[9 + mimeTypeLength] << 16 |
        _flacMetaBlock.data[10 + mimeTypeLength] << 8 |
        _flacMetaBlock.data[11 + mimeTypeLength];
    _cover = Uint8List.fromList(_flacMetaBlock.data
        .sublist(12 + mimeTypeLength + descStringLength + 20));
  }

  final FlacMetaBlock _flacMetaBlock;
  Uint8List _cover = Uint8List(0);

  Uint8List getCover() {
    return _cover;
  }
}

class FlacFile {
  FlacFile(this.audioFile);

  AudioFile audioFile;

  List<FlacMetaBlock> flacMetaBlocks = [];

  VorbisComment? _vorbisComment;
  Picture? _picture;

  Future<bool> read(AudioFile audioFile) async {
    File file = File(audioFile._path);
    var randomAccessFile = file.openSync();
    List<int> sign = randomAccessFile.readSync(4);
    if (sign.length != 4) return false;
    if ((sign[0] != 'f'.codeUnitAt(0)) |
        (sign[1] != 'L'.codeUnitAt(0)) |
        (sign[2] != 'a'.codeUnitAt(0)) |
        (sign[3] != 'C'.codeUnitAt(0))) return false;
    var isLast = false;
    while (!isLast) {
      var metaBlockHeader = randomAccessFile.readSync(1);
      var header = metaBlockHeader[0];
      isLast = ((header & 0x80) >> 7) == 1;
      var type = header & 0x7F;
      var sizes = randomAccessFile.readSync(3);
      var dataLength = (sizes[0] << 16) + (sizes[1] << 8) + sizes[2];
      var metadataBytes = randomAccessFile.readSync(dataLength);
      flacMetaBlocks.add(FlacMetaBlock(type, metadataBytes));
      if (type == 4) _vorbisComment = VorbisComment(flacMetaBlocks.last);
      if (type == 6) _picture = Picture(flacMetaBlocks.last);
    }

    return true;
  }

  String getTitle() {
    if (_vorbisComment != null) return _vorbisComment!.getTitle();
    return '';
  }

  String getArtist() {
    if (_vorbisComment != null) return _vorbisComment!.getArtist();
    return '';
  }

  String getAlbum() {
    if (_vorbisComment != null) return _vorbisComment!.getAlbum();
    return '';
  }

  String getAlbumArtist() {
    if (_vorbisComment != null) return _vorbisComment!.getAlbumArtist();
    return '';
  }

  String getComment() {
    if (_vorbisComment != null) return _vorbisComment!.getComment();
    return '';
  }

  Uint8List getCover() {
    if (_picture != null) return _picture!.getCover();
    return Uint8List(0);
  }

  String getLyric() {
    if (_vorbisComment != null) return _vorbisComment!.getLyric();
    return '';
  }

  String getTrack() {
    if (_vorbisComment != null) return _vorbisComment!.getTrack();
    return '';
  }

  String getCD() {
    if (_vorbisComment != null) return _vorbisComment!.getCD();
    return '';
  }

  String getEncoder() {
    if (_vorbisComment != null) return _vorbisComment!.getCD();
    return '';
  }
}
