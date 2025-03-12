part of 'taglib.dart';

class FlacMetaBlock {
  FlacMetaBlock(this.type, this.data);

  int type;
  List<int> data;
}

class VorbisComment {
  VorbisComment(this.name, this.data);

  String name;
  List<int> data;
}

/// Vorbis Comment or called Xiph Comment
class VorbisCommentBlock {
  VorbisCommentBlock(this._flacMetaBlock) {
    if (_flacMetaBlock.data.isNotEmpty) {
      int vendorSize = _flacMetaBlock.data[0] |
          _flacMetaBlock.data[1] << 8 |
          _flacMetaBlock.data[2] << 16 |
          _flacMetaBlock.data[3] << 24;
      int commentsCount = _flacMetaBlock.data[4 + vendorSize] |
          _flacMetaBlock.data[5 + vendorSize] << 8 |
          _flacMetaBlock.data[6 + vendorSize] << 16 |
          _flacMetaBlock.data[7 + vendorSize] << 24;
      int pos = 4 + vendorSize + 4;
      for (int i = 0; i < commentsCount; i++) {
        int commentSize = _flacMetaBlock.data[pos] |
            _flacMetaBlock.data[pos + 1] << 8 |
            _flacMetaBlock.data[pos + 2] << 16 |
            _flacMetaBlock.data[pos + 3] << 24;
        if (commentSize > 0) {
          var comment =
              _flacMetaBlock.data.sublist(pos + 4, pos + 4 + commentSize);
          _comments.add(VorbisComment(
              String.fromCharCodes(
                      comment.sublist(0, comment.indexOf('='.codeUnitAt(0))))
                  .toUpperCase(),
              comment.sublist(comment.indexOf('='.codeUnitAt(0)) + 1)));
        }
        pos += 4 + commentSize;
      }
    }
  }

  final FlacMetaBlock _flacMetaBlock;
  final List<VorbisComment> _comments = [];

  void save() {
    var vendor = 'taglib_dart'.codeUnits;
    var vendorLength = vendor.length;
    var vendorLengthBytes = List<int>.filled(4, 0);
    vendorLengthBytes[3] = vendorLength >> 24;
    vendorLength %= 0x1000000;
    vendorLengthBytes[2] = vendorLength >> 16;
    vendorLength %= 0x10000;
    vendorLengthBytes[1] = vendorLength >> 8;
    vendorLength %= 0x100;
    vendorLengthBytes[0] = vendorLength;
    var commentsCount = _comments.length;
    var commentsCountBytes = List<int>.filled(4, 0);
    commentsCountBytes[3] = commentsCount >> 24;
    commentsCount %= 0x1000000;
    commentsCountBytes[2] = commentsCount >> 16;
    commentsCount %= 0x10000;
    commentsCountBytes[1] = commentsCount >> 8;
    commentsCount %= 0x100;
    commentsCountBytes[0] = commentsCount;
    List<int> commentsData = [];
    for (var comment in _comments) {
      var commentSize = comment.name.codeUnits.length +
          '='.codeUnits.length +
          comment.data.length;
      var commentSizeBytes = List<int>.filled(4, 0);
      commentSizeBytes[3] = commentSize >> 24;
      commentSize %= 0x1000000;
      commentSizeBytes[2] = commentSize >> 16;
      commentSize %= 0x10000;
      commentSizeBytes[1] = commentSize >> 8;
      commentSize %= 0x100;
      commentSizeBytes[0] = commentSize;
      commentsData += commentSizeBytes +
          comment.name.codeUnits +
          '='.codeUnits +
          comment.data;
    }
    _flacMetaBlock.data =
        vendorLengthBytes + vendor + commentsCountBytes + commentsData;
  }

  String? getTitle() {
    for (final comment in _comments) {
      if (comment.name == 'TITLE') {
        return utf8.decode(comment.data);
      }
    }
    return null;
  }

  String? getArtist() {
    for (final comment in _comments) {
      if (comment.name == 'ARTIST') {
        return utf8.decode(comment.data);
      }
    }
    return null;
  }

  String? getAlbum() {
    for (final comment in _comments) {
      if (comment.name == 'ALBUM') {
        return utf8.decode(comment.data);
      }
    }
    return null;
  }

  String? getAlbumArtist() {
    for (final comment in _comments) {
      if (comment.name == 'ALBUMARTIST') {
        return utf8.decode(comment.data);
      } else if (comment.name == 'ALBUM_ARTIST') {
        return utf8.decode(comment.data);
      }
    }
    return null;
  }

  String? getLyric() {
    for (final comment in _comments) {
      if (comment.name == 'LYRICS') {
        return utf8.decode(comment.data);
      }
    }
    return null;
  }

  String? getComment() {
    for (final comment in _comments) {
      if (comment.name == 'DESCRIPTION') {
        return utf8.decode(comment.data);
      } else if (comment.name == 'COMMENT') {
        return utf8.decode(comment.data);
      }
    }
    return '';
  }

  String? getTrack() {
    for (final comment in _comments) {
      if (comment.name == 'TRACKNUMBER') {
        return utf8.decode(comment.data);
      } else if (comment.name == 'TRACKNUM') {
        return utf8.decode(comment.data);
      }
    }
    return null;
  }

  String? getCD() {
    for (final comment in _comments) {
      if (comment.name == 'DISCNUMBER') {
        return utf8.decode(comment.data);
      }
    }
    return null;
  }

  String? getYear() {
    for (final comment in _comments) {
      if (comment.name == 'DATE') {
        return utf8.decode(comment.data);
      } else if (comment.name == 'YEAR') {
        return utf8.decode(comment.data);
      }
    }
    return null;
  }

  String? getEncoder() {
    for (final comment in _comments) {
      if (comment.name == 'ENCODER') {
        return utf8.decode(comment.data);
      }
    }
    return null;
  }

  void setTitle(String? title) {
    if (title != null) {
      for (final comment in _comments) {
        if (comment.name == 'TITLE') {
          comment.data = utf8.encode(title);
          return;
        }
      }
      _comments.add(VorbisComment('TITLE', utf8.encode(title)));
    } else {
      for (final comment in _comments) {
        if (comment.name == 'TITLE') {
          _comments.remove(comment);
          return;
        }
      }
    }
  }

  void setArtist(String? artist) {
    if (artist != null) {
      for (final comment in _comments) {
        if (comment.name == 'ARTIST') {
          comment.data = utf8.encode(artist);
          return;
        }
      }
      _comments.add(VorbisComment('ARTIST', utf8.encode(artist)));
    } else {
      for (final comment in _comments) {
        if (comment.name == 'ARTIST') {
          _comments.remove(comment);
          return;
        }
      }
    }
  }

  void setAlbum(String? album) {
    if (album != null) {
      for (final comment in _comments) {
        if (comment.name == 'ALBUM') {
          comment.data = utf8.encode(album);
          return;
        }
      }
      _comments.add(VorbisComment('ALBUM', utf8.encode(album)));
    } else {
      for (final comment in _comments) {
        if (comment.name == 'ALBUM') {
          _comments.remove(comment);
          return;
        }
      }
    }
  }

  void setAlbumArtist(String? albumArtist) {
    if (albumArtist != null) {
      for (final comment in _comments) {
        if (comment.name == 'ALBUMARTIST') {
          comment.data = utf8.encode(albumArtist);
          return;
        }
      }
      for (final comment in _comments) {
        if (comment.name == 'ALBUM_ARTIST') {
          comment.data = utf8.encode(albumArtist);
          return;
        }
      }
      _comments.add(VorbisComment('ALBUMARTIST', utf8.encode(albumArtist)));
    } else {
      for (final comment in _comments) {
        if (comment.name == 'ALBUMARTIST') {
          _comments.remove(comment);
          return;
        }
      }
      for (final comment in _comments) {
        if (comment.name == 'ALBUM_ARTIST') {
          _comments.remove(comment);
          return;
        }
      }
    }
  }

  void setLyric(String? lyric) {
    if (lyric != null) {
      for (final comment in _comments) {
        if (comment.name == 'LYRICS') {
          comment.data = utf8.encode(lyric);
          return;
        }
      }
      _comments.add(VorbisComment('LYRICS', utf8.encode(lyric)));
    } else {
      for (final comment in _comments) {
        if (comment.name == 'LYRICS') {
          _comments.remove(comment);
          return;
        }
      }
    }
  }

  void setComment(String? comment) {
    if (comment != null) {
      for (final comment_ in _comments) {
        if (comment_.name == 'DESCRIPTION') {
          comment_.data = utf8.encode(comment);
          return;
        }
        if (comment_.name == 'COMMENT') {
          comment_.data = utf8.encode(comment);
          return;
        }
      }
      _comments.add(VorbisComment('DESCRIPTION', utf8.encode(comment)));
    } else {
      for (final comment_ in _comments) {
        if (comment_.name == 'DESCRIPTION') {
          _comments.remove(comment_);
          return;
        }
        if (comment_.name == 'COMMENT') {
          _comments.remove(comment_);
          return;
        }
      }
    }
  }

  void setTrack(String? track) {
    if (track != null) {
      for (final comment in _comments) {
        if (comment.name == 'TRACKNUMBER') {
          comment.data = utf8.encode(track);
          return;
        }
        if (comment.name == 'TRACKNUM') {
          comment.data = utf8.encode(track);
          return;
        }
      }
      _comments.add(VorbisComment('TRACKNUMBER', utf8.encode(track)));
    } else {
      for (final comment in _comments) {
        if (comment.name == 'TRACKNUMBER') {
          _comments.remove(comment);
          return;
        }
        if (comment.name == 'TRACKNUM') {
          _comments.remove(comment);
          return;
        }
      }
    }
  }

  void setCD(String? cd) {
    if (cd != null) {
      for (final comment in _comments) {
        if (comment.name == 'DISCNUMBER') {
          comment.data = utf8.encode(cd);
          return;
        }
      }
      _comments.add(VorbisComment('DISCNUMBER', utf8.encode(cd)));
    } else {
      for (final comment in _comments) {
        if (comment.name == 'DISCNUMBER') {
          _comments.remove(comment);
          return;
        }
      }
    }
  }

  void setYear(String? year) {
    if (year != null) {
      for (final comment in _comments) {
        if (comment.name == 'DATE') {
          comment.data = utf8.encode(year);
          return;
        }
        if (comment.name == 'YEAR') {
          comment.data = utf8.encode(year);
          return;
        }
      }
      _comments.add(VorbisComment('DATE', utf8.encode(year)));
    } else {
      for (final comment in _comments) {
        if (comment.name == 'DATE') {
          _comments.remove(comment);
          return;
        }
        if (comment.name == 'YEAR') {
          _comments.remove(comment);
          return;
        }
      }
    }
  }

  void setEncoder(String? encoder) {
    if (encoder != null) {
      for (final comment in _comments) {
        if (comment.name == 'ENCODER') {
          comment.data = utf8.encode(encoder);
          return;
        }
      }
      _comments.add(VorbisComment('ENCODER', utf8.encode(encoder)));
    } else {
      for (final comment in _comments) {
        if (comment.name == 'ENCODER') {
          _comments.remove(comment);
          return;
        }
      }
    }
  }
}

class PictureBlock {
  PictureBlock(this._flacMetaBlock) {
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
  Uint8List? _cover;

  void save() {
    if (_cover != null) {
      if (_cover!.isNotEmpty) {
        // In fact, only image's byte data matters, the other information is usually ignored, even the MIME type.
        List<int> data = [0x00, 0x00, 0x00, 0x03] + // image type (use as)
            [0x00, 0x00, 0x00, 0x0a] + // MIME length
            'image/jpeg'.codeUnits + // MIME type
            [0x00, 0x00, 0x00, 0x00] + // description length
            [] + // description
            [0x00, 0x00, 0x00, 0x00] + // image width
            [0x00, 0x00, 0x00, 0x00] + // image height
            [0x00, 0x00, 0x00, 0x00] + // color digit
            [0x00, 0x00, 0x00, 0x00]; // index image's color's count
        // image size
        int imageSize = _cover!.length;
        data.add(imageSize >> 24);
        imageSize %= 0x1000000;
        data.add(imageSize >> 16);
        imageSize %= 0x10000;
        data.add(imageSize >> 8);
        imageSize %= 0x100;
        data.add(imageSize);

        data += _cover!;
        _flacMetaBlock.data = data;
        return;
      }
    }
    _flacMetaBlock.data = [];
  }

  Uint8List? getCover() {
    return _cover;
  }

  void setCover(Uint8List? cover) {
    _cover = cover;
  }
}

class FlacFile {
  FlacFile(this._audioFile) {
    var isLast = false;
    var index = 4;
    while (!isLast) {
      var metaBlockHeader = _audioFile._rawData.sublist(index, index + 1);
      index += 1;
      var header = metaBlockHeader[0];
      isLast = ((header & 0x80) >> 7) == 1;
      var type = header & 0x7F;
      var sizes = _audioFile._rawData.sublist(index, index + 3);
      index += 3;
      var dataLength = (sizes[0] << 16) + (sizes[1] << 8) + sizes[2];
      var metadataBytes =
          _audioFile._rawData.sublist(index, index + dataLength);
      index += dataLength;
      _flacMetaBlocks.add(FlacMetaBlock(type, metadataBytes));
      if (type == 4) {
        _vorbisCommentBlock = VorbisCommentBlock(_flacMetaBlocks.last);
      }
      if (type == 6) {
        _pictureBlock = PictureBlock(_flacMetaBlocks.last);
      }
    }
  }

  final AudioFile _audioFile;

  final List<FlacMetaBlock> _flacMetaBlocks = [];

  VorbisCommentBlock? _vorbisCommentBlock;
  PictureBlock? _pictureBlock;

  void save() {
    var totalData = _audioFile._rawData;
    var isLast = false;
    int index = 4;
    while (!isLast) {
      var metaBlockHeader = totalData.sublist(index, index + 1);
      index += 1;
      var header = metaBlockHeader[0];
      isLast = ((header & 0x80) >> 7) == 1;
      var sizes = totalData.sublist(index, index + 3);
      index += 3;
      var dataLength = (sizes[0] << 16) + (sizes[1] << 8) + sizes[2];
      index += dataLength;
    }
    totalData = totalData.sublist(index);
    _vorbisCommentBlock?.save();
    _pictureBlock?.save();
    List<int> flacMetaBlocksData = [];
    for (var flacMetaBlock in _flacMetaBlocks) {
      var header = List<int>.filled(4, 0);
      if (identical(flacMetaBlock, _flacMetaBlocks.last)) {
        header[0] |= 0x80;
      }
      header[0] |= flacMetaBlock.type;
      var length = flacMetaBlock.data.length;
      header[3] = length % 0x100;
      length >>= 8;
      header[2] = length % 0x100;
      length >>= 8;
      header[1] = length;
      flacMetaBlocksData += header + flacMetaBlock.data;
    }
    totalData = 'fLaC'.codeUnits + flacMetaBlocksData + totalData;
    _audioFile._rawData = totalData;
  }

  String? getTitle() => _vorbisCommentBlock?.getTitle();

  String? getArtist() => _vorbisCommentBlock?.getArtist();

  String? getAlbum() {
    return _vorbisCommentBlock?.getAlbum();
  }

  String? getAlbumArtist() {
    return _vorbisCommentBlock?.getAlbumArtist();
  }

  String? getComment() => _vorbisCommentBlock?.getComment();

  Uint8List? getCover() => _pictureBlock?.getCover();

  String? getLyric() => _vorbisCommentBlock?.getLyric();

  String? getTrack() => _vorbisCommentBlock?.getTrack();

  String? getCD() => _vorbisCommentBlock?.getCD();

  String? getYear() => _vorbisCommentBlock?.getYear();

  String? getEncoder() => _vorbisCommentBlock?.getCD();

  void setTitle(String? title) {
    if (title != null) {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setTitle(title);
      } else {
        final flacMetaBlock = FlacMetaBlock(4, []);
        _flacMetaBlocks.add(flacMetaBlock);
        _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
        _vorbisCommentBlock!.setTitle(title);
      }
    } else {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setTitle(title);
      }
    }
  }

  void setArtist(String? artist) {
    if (artist != null) {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setArtist(artist);
      } else {
        final flacMetaBlock = FlacMetaBlock(4, []);
        _flacMetaBlocks.add(flacMetaBlock);
        _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
        _vorbisCommentBlock!.setArtist(artist);
      }
    } else {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setArtist(artist);
      }
    }
  }

  void setAlbum(String? album) {
    if (album != null) {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setAlbum(album);
      } else {
        final flacMetaBlock = FlacMetaBlock(4, []);
        _flacMetaBlocks.add(flacMetaBlock);
        _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
        _vorbisCommentBlock!.setAlbum(album);
      }
    } else {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setAlbum(album);
      }
    }
  }

  void setAlbumArtist(String? albumArtist) {
    if (albumArtist != null) {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setAlbumArtist(albumArtist);
      } else {
        final flacMetaBlock = FlacMetaBlock(4, []);
        _flacMetaBlocks.add(flacMetaBlock);
        _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
        _vorbisCommentBlock!.setAlbumArtist(albumArtist);
      }
    } else {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setAlbumArtist(albumArtist);
      }
    }
  }

  void setLyric(String? lyric) {
    if (lyric != null) {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setLyric(lyric);
      } else {
        final flacMetaBlock = FlacMetaBlock(4, []);
        _flacMetaBlocks.add(flacMetaBlock);
        _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
        _vorbisCommentBlock!.setLyric(lyric);
      }
    } else {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setLyric(lyric);
      }
    }
  }

  void setComment(String? comment) {
    if (comment != null) {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setComment(comment);
      } else {
        final flacMetaBlock = FlacMetaBlock(4, []);
        _flacMetaBlocks.add(flacMetaBlock);
        _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
        _vorbisCommentBlock!.setComment(comment);
      }
    } else {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setComment(comment);
      }
    }
  }

  void setCover(Uint8List? cover) {
    if (cover != null) {
      if (_pictureBlock != null) {
        _pictureBlock!.setCover(cover);
      } else {
        final flacMetaBlock = FlacMetaBlock(6, List.filled(32, 0));
        _flacMetaBlocks.add(flacMetaBlock);
        _pictureBlock = PictureBlock(flacMetaBlock);
        _pictureBlock!.setCover(cover);
      }
    } else {
      for (var flacMetaBlock in _flacMetaBlocks) {
        if (flacMetaBlock.type == 6) {
          _flacMetaBlocks.remove(flacMetaBlock);
          break;
        }
      }
      _pictureBlock = null;
    }
  }

  void setTrack(String? track) {
    if (track != null) {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setTrack(track);
      } else {
        final flacMetaBlock = FlacMetaBlock(4, []);
        _flacMetaBlocks.add(flacMetaBlock);
        _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
        _vorbisCommentBlock!.setTrack(track);
      }
    } else {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setTrack(track);
      }
    }
  }

  void setCD(String? cd) {
    if (cd != null) {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setCD(cd);
      } else {
        final flacMetaBlock = FlacMetaBlock(4, []);
        _flacMetaBlocks.add(flacMetaBlock);
        _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
        _vorbisCommentBlock!.setCD(cd);
      }
    } else {
      if (_vorbisCommentBlock != null) _vorbisCommentBlock!.setCD(cd);
    }
  }

  void setYear(String? year) {
    if (year != null) {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setYear(year);
      } else {
        final flacMetaBlock = FlacMetaBlock(4, []);
        _flacMetaBlocks.add(flacMetaBlock);
        _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
        _vorbisCommentBlock!.setYear(year);
      }
    } else {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setYear(year);
      }
    }
  }

  void setEncoder(String? encoder) {
    if (encoder != null) {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setEncoder(encoder);
      } else {
        final flacMetaBlock = FlacMetaBlock(4, []);
        _flacMetaBlocks.add(flacMetaBlock);
        _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
        _vorbisCommentBlock!.setEncoder(encoder);
      }
    } else {
      if (_vorbisCommentBlock != null) {
        _vorbisCommentBlock!.setEncoder(encoder);
      }
    }
  }
}
