part of 'taglib.dart';

class FlacMetaBlock {
  FlacMetaBlock(this.type, this.data);

  int type;
  List<int> data;
}

class VorbisComment {
  VorbisComment(this.name, this.data);

  List<int> name;
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
              comment.sublist(0, comment.indexOf('='.codeUnitAt(0))),
              comment.sublist(comment.indexOf('='.codeUnitAt(0)) + 1)));
        }
        pos += 4 + commentSize;
      }
    }
  }

  final FlacMetaBlock _flacMetaBlock;
  final List<VorbisComment> _comments = [];

  void save() {
    var vendor = '野兽先辈1.1.4.5.1.4'.codeUnits;
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
      var commentSize = comment.name.length + 1 + comment.data.length;
      var commentSizeBytes = List<int>.filled(4, 0);
      commentSizeBytes[3] = commentSize >> 24;
      commentSize %= 0x1000000;
      commentSizeBytes[2] = commentSize >> 16;
      commentSize %= 0x10000;
      commentSizeBytes[1] = commentSize >> 8;
      commentSize %= 0x100;
      commentSizeBytes[0] = commentSize;
      commentsData +=
          commentSizeBytes + comment.name + '='.codeUnits + comment.data;
    }
    _flacMetaBlock.data =
        vendorLengthBytes + vendor + commentsCountBytes + commentsData;
  }

  String getTitle() {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'TITLE'.codeUnits)) {
        return utf8.decode(comment.data);
      }
    }
    return '';
  }

  String getArtist() {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'ARTIST'.codeUnits)) {
        return utf8.decode(comment.data);
      }
    }
    return '';
  }

  String getAlbum() {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'ALBUM'.codeUnits)) {
        return utf8.decode(comment.data);
      }
    }
    return '';
  }

  String getAlbumArtist() {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'ALBUMARTIST'.codeUnits)) {
        return utf8.decode(comment.data);
      } else if (listEquals(comment.name, 'ALBUM_ARTIST'.codeUnits)) {
        return utf8.decode(comment.data);
      }
    }
    return '';
  }

  String getLyric() {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'LYRICS'.codeUnits)) {
        return utf8.decode(comment.data);
      }
    }
    return '';
  }

  String getComment() {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'DESCRIPTION'.codeUnits)) {
        return utf8.decode(comment.data);
      } else if (listEquals(comment.name, 'COMMENT'.codeUnits)) {
        return utf8.decode(comment.data);
      }
    }
    return '';
  }

  String getTrack() {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'TRACKNUMBER'.codeUnits)) {
        return utf8.decode(comment.data);
      } else if (listEquals(comment.name, 'TRACKNUM'.codeUnits)) {
        return utf8.decode(comment.data);
      }
    }
    return '';
  }

  String getCD() {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'DISCNUMBER'.codeUnits)) {
        return utf8.decode(comment.data);
      }
    }
    return '';
  }

  String getYear() {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'DATE'.codeUnits)) {
        return utf8.decode(comment.data);
      } else if (listEquals(comment.name, 'YEAR'.codeUnits)) {
        return utf8.decode(comment.data);
      }
    }
    return '';
  }

  String getEncoder() {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'ENCODER'.codeUnits)) {
        return utf8.decode(comment.data);
      }
    }
    return '';
  }

  void setTitle(String title) {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'TITLE'.codeUnits)) {
        comment.data = utf8.encode(title);
        return;
      }
    }
    _comments.add(VorbisComment('TITLE'.codeUnits, utf8.encode(title)));
  }

  void setArtist(String artist) {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'ARTIST'.codeUnits)) {
        comment.data = utf8.encode(artist);
        return;
      }
    }
    _comments.add(VorbisComment('ARTIST'.codeUnits, utf8.encode(artist)));
  }

  void setAlbum(String album) {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'ALBUM'.codeUnits)) {
        comment.data = utf8.encode(album);
        return;
      }
    }
    _comments.add(VorbisComment('ALBUM'.codeUnits, utf8.encode(album)));
  }

  void setAlbumArtist(String albumArtist) {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'ALBUMARTIST'.codeUnits) |
          listEquals(comment.name, 'ALBUM_ARTIST'.codeUnits)) {
        comment.data = utf8.encode(albumArtist);
        return;
      }
    }
    _comments
        .add(VorbisComment('ALBUMARTIST'.codeUnits, utf8.encode(albumArtist)));
  }

  void setLyric(String lyric) {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'LYRICS'.codeUnits)) {
        comment.data = utf8.encode(lyric);
        return;
      }
    }
    _comments.add(VorbisComment('LYRICS'.codeUnits, utf8.encode(lyric)));
  }

  void setComment(String comment) {
    for (var comment_ in _comments) {
      if (listEquals(comment_.name, 'DESCRIPTION'.codeUnits) |
          listEquals(comment_.name, 'COMMENT'.codeUnits)) {
        comment_.data = utf8.encode(comment);
        return;
      }
    }
    _comments.add(VorbisComment('ALBUMARTIST'.codeUnits, utf8.encode(comment)));
  }

  void setTrack(String track) {
    for (var comment_ in _comments) {
      if (listEquals(comment_.name, 'TRACKNUMBER'.codeUnits) |
          listEquals(comment_.name, 'TRACKNUM'.codeUnits)) {
        comment_.data = utf8.encode(track);
        return;
      }
    }
    _comments.add(VorbisComment('ALBUMARTIST'.codeUnits, utf8.encode(track)));
  }

  void setCD(String cd) {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'DISCNUMBER'.codeUnits)) {
        comment.data = utf8.encode(cd);
        return;
      }
    }
    _comments.add(VorbisComment('DISCNUMBER'.codeUnits, utf8.encode(cd)));
  }

  void setYear(String year) {
    for (var comment_ in _comments) {
      if (listEquals(comment_.name, 'DATE'.codeUnits) |
          listEquals(comment_.name, 'YEAR'.codeUnits)) {
        comment_.data = utf8.encode(year);
        return;
      }
    }
    _comments.add(VorbisComment('ALBUMARTIST'.codeUnits, utf8.encode(year)));
  }

  void setEncoder(String encoder) {
    for (var comment in _comments) {
      if (listEquals(comment.name, 'ENCODER'.codeUnits)) {
        comment.data = utf8.encode(encoder);
        return;
      }
    }
    _comments.add(VorbisComment('ENCODER'.codeUnits, utf8.encode(encoder)));
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
  Uint8List _cover = Uint8List(0);

  void save() {
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
    int imageSize = _cover.length;
    data.add(imageSize >> 24);
    imageSize %= 0x1000000;
    data.add(imageSize >> 16);
    imageSize %= 0x10000;
    data.add(imageSize >> 8);
    imageSize %= 0x100;
    data.add(imageSize);

    data += _cover;
    _flacMetaBlock.data = data;
  }

  Uint8List getCover() {
    return _cover;
  }

  void setCover(Uint8List cover) {
    _cover = cover;
  }
}

class FlacFile {
  FlacFile(this._audioFile);

  final AudioFile _audioFile;

  final List<FlacMetaBlock> _flacMetaBlocks = [];

  VorbisCommentBlock? _vorbisCommentBlock;
  PictureBlock? _pictureBlock;

  Future<bool> read() async {
    File file = File(_audioFile._path);
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
      _flacMetaBlocks.add(FlacMetaBlock(type, metadataBytes));
      if (type == 4) {
        _vorbisCommentBlock = VorbisCommentBlock(_flacMetaBlocks.last);
      }
      if (type == 6) _pictureBlock = PictureBlock(_flacMetaBlocks.last);
    }
    randomAccessFile.closeSync();
    return true;
  }

  Future<bool> save() async {
    File file = File(_audioFile._path);
    DateTime fileTime = file.lastModifiedSync();
    List<int> totalData = file.readAsBytesSync();
    List<int> sign = totalData.sublist(0, 4);
    if (sign.length != 4) return false;
    if ((sign[0] != 'f'.codeUnitAt(0)) |
        (sign[1] != 'L'.codeUnitAt(0)) |
        (sign[2] != 'a'.codeUnitAt(0)) |
        (sign[3] != 'C'.codeUnitAt(0))) return false;
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
    file.writeAsBytesSync(totalData);
    file.setLastModifiedSync(fileTime);
    return true;
  }

  String getTitle() {
    if (_vorbisCommentBlock != null) return _vorbisCommentBlock!.getTitle();
    return '';
  }

  String getArtist() {
    if (_vorbisCommentBlock != null) return _vorbisCommentBlock!.getArtist();
    return '';
  }

  String getAlbum() {
    if (_vorbisCommentBlock != null) return _vorbisCommentBlock!.getAlbum();
    return '';
  }

  String getAlbumArtist() {
    if (_vorbisCommentBlock != null) {
      return _vorbisCommentBlock!.getAlbumArtist();
    }
    return '';
  }

  String getComment() {
    if (_vorbisCommentBlock != null) return _vorbisCommentBlock!.getComment();
    return '';
  }

  Uint8List getCover() {
    if (_pictureBlock != null) return _pictureBlock!.getCover();
    return Uint8List(0);
  }

  String getLyric() {
    if (_vorbisCommentBlock != null) return _vorbisCommentBlock!.getLyric();
    return '';
  }

  String getTrack() {
    if (_vorbisCommentBlock != null) return _vorbisCommentBlock!.getTrack();
    return '';
  }

  String getCD() {
    if (_vorbisCommentBlock != null) return _vorbisCommentBlock!.getCD();
    return '';
  }

  String getYear() {
    if (_vorbisCommentBlock != null) return _vorbisCommentBlock!.getYear();
    return '';
  }

  String getEncoder() {
    if (_vorbisCommentBlock != null) return _vorbisCommentBlock!.getCD();
    return '';
  }

  void setTitle(String title) {
    if (_vorbisCommentBlock != null) {
      _vorbisCommentBlock!.setTitle(title);
    } else {
      final flacMetaBlock = FlacMetaBlock(4, []);
      _flacMetaBlocks.add(flacMetaBlock);
      _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
      _vorbisCommentBlock!.setTitle(title);
    }
  }

  void setArtist(String artist) {
    if (_vorbisCommentBlock != null) {
      _vorbisCommentBlock!.setArtist(artist);
    } else {
      final flacMetaBlock = FlacMetaBlock(4, []);
      _flacMetaBlocks.add(flacMetaBlock);
      _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
      _vorbisCommentBlock!.setArtist(artist);
    }
  }

  void setAlbum(String album) {
    if (_vorbisCommentBlock != null) {
      _vorbisCommentBlock!.setAlbum(album);
    } else {
      final flacMetaBlock = FlacMetaBlock(4, []);
      _flacMetaBlocks.add(flacMetaBlock);
      _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
      _vorbisCommentBlock!.setAlbum(album);
    }
  }

  void setAlbumArtist(String albumArtist) {
    if (_vorbisCommentBlock != null) {
      _vorbisCommentBlock!.setAlbumArtist(albumArtist);
    } else {
      final flacMetaBlock = FlacMetaBlock(4, []);
      _flacMetaBlocks.add(flacMetaBlock);
      _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
      _vorbisCommentBlock!.setAlbumArtist(albumArtist);
    }
  }

  void setLyric(String lyric) {
    if (_vorbisCommentBlock != null) {
      _vorbisCommentBlock!.setLyric(lyric);
    } else {
      final flacMetaBlock = FlacMetaBlock(4, []);
      _flacMetaBlocks.add(flacMetaBlock);
      _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
      _vorbisCommentBlock!.setLyric(lyric);
    }
  }

  void setComment(String comment) {
    if (_vorbisCommentBlock != null) {
      _vorbisCommentBlock!.setComment(comment);
    } else {
      final flacMetaBlock = FlacMetaBlock(4, []);
      _flacMetaBlocks.add(flacMetaBlock);
      _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
      _vorbisCommentBlock!.setComment(comment);
    }
  }

  void setCover(Uint8List cover) {
    if (_pictureBlock != null) {
      _pictureBlock!.setCover(cover);
    } else {
      final flacMetaBlock = FlacMetaBlock(6, []);
      _flacMetaBlocks.add(flacMetaBlock);
      _pictureBlock = PictureBlock(flacMetaBlock);
      _pictureBlock!.setCover(cover);
    }
  }

  void setTrack(String track) {
    if (_vorbisCommentBlock != null) {
      _vorbisCommentBlock!.setTrack(track);
    } else {
      final flacMetaBlock = FlacMetaBlock(4, []);
      _flacMetaBlocks.add(flacMetaBlock);
      _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
      _vorbisCommentBlock!.setTrack(track);
    }
  }

  void setCD(String cd) {
    if (_vorbisCommentBlock != null) {
      _vorbisCommentBlock!.setCD(cd);
    } else {
      final flacMetaBlock = FlacMetaBlock(4, []);
      _flacMetaBlocks.add(flacMetaBlock);
      _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
      _vorbisCommentBlock!.setCD(cd);
    }
  }

  void setYear(String year) {
    if (_vorbisCommentBlock != null) {
      _vorbisCommentBlock!.setYear(year);
    } else {
      final flacMetaBlock = FlacMetaBlock(4, []);
      _flacMetaBlocks.add(flacMetaBlock);
      _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
      _vorbisCommentBlock!.setYear(year);
    }
  }

  void setEncoder(String encoder) {
    if (_vorbisCommentBlock != null) {
      _vorbisCommentBlock!.setEncoder(encoder);
    } else {
      final flacMetaBlock = FlacMetaBlock(4, []);
      _flacMetaBlocks.add(flacMetaBlock);
      _vorbisCommentBlock = VorbisCommentBlock(flacMetaBlock);
      _vorbisCommentBlock!.setEncoder(encoder);
    }
  }
}
