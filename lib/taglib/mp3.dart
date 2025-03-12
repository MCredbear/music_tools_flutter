part of 'taglib.dart';

extension IterableExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class ID3Frame {
  ID3Frame(this.name, this.data);
  List<int> name;
  List<int> data;
}

class Mp3File {
  Mp3File(this._audioFile) {
    final rawData = _audioFile._rawData;
    int mpegFrameIndex = findFirstMpegFrame(rawData);

    if (mpegFrameIndex > 10) {
      List<int> head = rawData.sublist(0, 10);

      if (head[0] == 'I'.codeUnitAt(0) &&
          head[1] == 'D'.codeUnitAt(0) &&
          head[2] == '3'.codeUnitAt(0)) {
        int version = head[3];
        int tagSize = 0;

        if (version == 2) {
          tagSize =
              (head[6] << 24) | (head[7] << 16) | (head[8] << 8) | head[9];
        } else {
          tagSize =
              (head[6] << 21) | (head[7] << 14) | (head[8] << 7) | head[9];
        }

        if (tagSize != 0) {
          List<int> tagData = rawData.sublist(10, 10 + tagSize);
          int i = 0;
          while (i < tagData.length - 10) {
            if (tagData[i] == 0) break;
            int frameSize = 0;
            if (version == 2) {
              frameSize = (tagData[i + 3] << 16) |
                  (tagData[i + 4] << 8) |
                  tagData[i + 5];
              _frames.add(ID3Frame(tagData.sublist(i, i + 3),
                  tagData.sublist(i + 6, i + 6 + frameSize)));
              i += frameSize + 6;
            } else if (version == 3) {
              frameSize = (tagData[i + 4] << 24) |
                  (tagData[i + 5] << 16) |
                  (tagData[i + 6] << 8) |
                  tagData[i + 7];
              _frames.add(ID3Frame(tagData.sublist(i, i + 4),
                  tagData.sublist(i + 10, i + 10 + frameSize)));
              i += frameSize + 10;
            } else if (version == 4) {
              frameSize = (tagData[i + 4] << 21) |
                  (tagData[i + 5] << 14) |
                  (tagData[i + 6] << 7) |
                  tagData[i + 7];
              _frames.add(ID3Frame(tagData.sublist(i, i + 4),
                  tagData.sublist(i + 10, i + 10 + frameSize)));
              i += frameSize + 10;
            }
          }
        }
      }
    }
  }

  final AudioFile _audioFile;

  final List<ID3Frame> _frames = [];

  int findFirstMpegFrame(List<int> rawData) {
    for (int i = 0; i < rawData.length - 1; i++) {
      if (rawData[i] == 0xFF && (rawData[i + 1] & 0xE0) == 0xE0) {
        return i;
      }
    }
    return -1;
  }

  void save() {
    List<int> head = 'ID3'.codeUnits + [0x04, 0x00, 0x00];
    List<int> tagData = [];
    for (var element in _frames) {
      List<int> frameData = [];
      frameData.addAll(element.name);
      int frameSize = element.data.length;
      frameData.add((frameSize >> 21) & 0x7F);
      frameData.add((frameSize >> 14) & 0x7F);
      frameData.add((frameSize >> 7) & 0x7F);
      frameData.add(frameSize & 0x7F);
      frameData += [0x00, 0x00]; // Flags
      frameData += element.data;
      tagData.addAll(frameData);
    }
    int tagSize = tagData.length;
    head.add((tagSize >> 21) & 0x7F);
    head.add((tagSize >> 14) & 0x7F);
    head.add((tagSize >> 7) & 0x7F);
    head.add(tagSize & 0x7F);
    int mpegFrameIndex = findFirstMpegFrame(_audioFile._rawData);
    _audioFile._rawData =
        head + tagData + _audioFile._rawData.sublist(mpegFrameIndex);
  }

  String? getTitle() {
    for (final frame in _frames) {
      if (listEquals(frame.name, 'TIT2'.codeUnits)) {
        return defaultReading(frame.data);
      }
    }
    return null;
  }

  String? getArtist() {
    for (final frame in _frames) {
      if (listEquals(frame.name, 'TPE1'.codeUnits)) {
        return defaultReading(frame.data);
      }
    }
    return null;
  }

  String? getAlbum() {
    for (final frame in _frames) {
      if (listEquals(frame.name, 'TALB'.codeUnits)) {
        return defaultReading(frame.data);
      }
    }
    return null;
  }

  String? getAlbumArtist() {
    for (final frame in _frames) {
      if (listEquals(frame.name, 'TPE2'.codeUnits)) {
        return defaultReading(frame.data);
      }
    }
    return null;
  }

  String? getLyric() {
    for (final frame in _frames) {
      if (listEquals(frame.name, 'USLT'.codeUnits)) {
        switch (frame.data.first) {
          case 0x00:
            return readLatin1(frame.data.sublist(10));
          case 0x01:
            return readUtf16LeString(frame.data.sublist(8));
          case 0x02:
            return readUtf16BeString(frame.data.sublist(8));
          case 0x03:
            return readUtf8String(frame.data.sublist(5));
        }
      }
    }
    return null;
  }

  String? getComment() {
    for (final frame in _frames) {
      if (listEquals(frame.name, 'COMM'.codeUnits)) {
        switch (frame.data.first) {
          case 0x00:
            return readLatin1(frame.data.sublist(5));
          case 0x01:
            return readUtf16LeString(frame.data.sublist(8));
          case 0x02:
            return readUtf16BeString(frame.data.sublist(8));
          case 0x03:
            return readUtf8String(frame.data.sublist(5));
        }
      }
    }
    return null;
  }

  Uint8List? getCover() {
    for (final frame in _frames) {
      if (listEquals(frame.name, 'APIC'.codeUnits)) {
        int mimeEnd = frame.data.indexOf(0, 1);
        int descriptionEnd = frame.data.indexOf(0, mimeEnd + 2);
        if ((frame.data[0] == 0x01) | (frame.data[0] == 0x02)) {
          descriptionEnd += 1;
        }
        return Uint8List.fromList(frame.data.sublist(descriptionEnd + 1));
      }
    }
    return null;
  }

  String? getTrack() {
    for (final frame in _frames) {
      if (listEquals(frame.name, 'TRCK'.codeUnits)) {
        return defaultReading(frame.data);
      }
    }
    return null;
  }

  String? getCD() {
    for (final frame in _frames) {
      if (listEquals(frame.name, 'TPOS'.codeUnits)) {
        return defaultReading(frame.data);
      }
    }
    return null;
  }

  String? getYear() {
    for (final frame in _frames) {
      if (listEquals(frame.name, 'TYER'.codeUnits)) {
        return defaultReading(frame.data);
      }
    }
    return null;
  }

  String? getEncoder() {
    for (final frame in _frames) {
      if (listEquals(frame.name, 'TENC'.codeUnits)) {
        return defaultReading(frame.data);
      }
    }
    return null;
  }

  String readLatin1(List<int> byteList) {
    return String.fromCharCodes(byteList);
  }

  String readUtf16LeString(List<int> byteList) {
    List<int> utf16LeString =
        List.generate((byteList.length / 2).ceil(), (index) => 0);
    for (int i = 0; i < byteList.length; i++) {
      if (i % 2 == 0) {
        utf16LeString[i ~/ 2] = byteList[i];
      } else {
        utf16LeString[i ~/ 2] |= byteList[i] << 8;
      }
    }
    return String.fromCharCodes(utf16LeString);
  }

  String readUtf16BeString(List<int> byteList) {
    List<int> utf16BeString =
        List.generate((byteList.length / 2).ceil(), (index) => 0);
    for (int i = 0; i < byteList.length; i++) {
      if (i % 2 == 0) {
        utf16BeString[i ~/ 2] = byteList[i] << 8;
      } else {
        utf16BeString[i ~/ 2] |= byteList[i];
      }
    }
    return String.fromCharCodes(utf16BeString);
  }

  String readUtf8String(List<int> byteList) {
    int end = byteList.indexWhere((element) => element == 0x00);
    if (end == -1) end = byteList.length;
    return utf8.decode(byteList.sublist(0, end));
  }

  String defaultReading(List<int> byteList) {
    if (byteList.length > 1) {
      switch (byteList.first) {
        case 0x00:
          return readLatin1(byteList.sublist(1));
        case 0x01:
          return readUtf16LeString(byteList.sublist(1));
        case 0x02:
          return readUtf16BeString(byteList.sublist(1));
        case 0x03:
          return readUtf8String(byteList.sublist(1));
        default:
          return '';
      }
    } else {
      return '';
    }
  }

  // String txxxReading(List<int> byteList) {
  //   if (byteList.length > 2) {
  //     if (byteList.first == 0x00) return (readLatin1(byteList.sublist(2)));
  //     if (byteList.first == 0x01) {
  //       return (readUtf16LeString(byteList.sublist(2)));
  //     }
  //     if (byteList.first == 0x02) {
  //       return (readUtf16BeString(byteList.sublist(2)));
  //     }
  //     return '';
  //   } else {
  //     return '';
  //   }
  // }

  // String wxxxReading(List<int> byteList) {
  //   if (byteList.length > 2) {
  //     if (byteList.first == 0x00) return (readLatin1(byteList.sublist(2)));
  //     if (byteList.first == 0x01) {
  //       return (readUtf16LeString(byteList.sublist(2)));
  //     }
  //     if (byteList.first == 0x02) {
  //       return (readUtf16BeString(byteList.sublist(2)));
  //     }
  //     return '';
  //   } else {
  //     return '';
  //   }
  // }

  void setTitle(String? title) {
    if (title != null) {
      var data = [0x03] + utf8.encode(title) + [0x00];
      _frames.firstWhere((frame) => listEquals(frame.name, 'TIT2'.codeUnits),
          orElse: () {
        _frames.add(ID3Frame('TIT2'.codeUnits, List.empty()));
        return _frames.last;
      }).data = data;
    } else {
      _frames.remove(_frames.firstWhereOrNull(
          (frame) => listEquals(frame.name, 'TIT2'.codeUnits)));
    }
    // int i = 0;
    // for (; i < _frames.length; i++) {
    //   if (listEquals(_frames[i].name, 'TIT2'.codeUnits)) {
    //     _frames[i].data = data;
    //     break;
    //   }
    // }
    // if (i == _frames.length) _frames.add(ID3Frame('TIT2'.codeUnits, data));
  }

  void setArtist(String? artist) {
    if (artist != null) {
      var data = [0x03] + utf8.encode(artist) + [0x00];
      _frames.firstWhere((frame) => listEquals(frame.name, 'TPE1'.codeUnits),
          orElse: () {
        _frames.add(ID3Frame('TPE1'.codeUnits, List.empty()));
        return _frames.last;
      }).data = data;
    } else {
      _frames.remove(_frames.firstWhereOrNull(
          (frame) => listEquals(frame.name, 'TPE1'.codeUnits)));
    }
    // int i = 0;
    // var data = [0x03] + utf8.encode(artist) + [0x00];
    // for (; i < _frames.length; i++) {
    //   if (listEquals(_frames[i].name, 'TPE1'.codeUnits)) {
    //     _frames[i].data = data;
    //     break;
    //   }
    // }
    // if (i == _frames.length) _frames.add(ID3Frame('TPE1'.codeUnits, data));
  }

  void setAlbum(String? album) {
    if (album != null) {
      var data = [0x03] + utf8.encode(album) + [0x00];
      _frames.firstWhere((frame) => listEquals(frame.name, 'TALB'.codeUnits),
          orElse: () {
        _frames.add(ID3Frame('TALB'.codeUnits, List.empty()));
        return _frames.last;
      }).data = data;
    } else {
      _frames.remove(_frames.firstWhereOrNull(
          (frame) => listEquals(frame.name, 'TALB'.codeUnits)));
    }
    // int i = 0;
    // var data = [0x03] + utf8.encode(album) + [0x00];
    // for (; i < _frames.length; i++) {
    //   if (listEquals(_frames[i].name, 'TALB'.codeUnits)) {
    //     _frames[i].data = data;
    //     break;
    //   }
    // }
    // if (i == _frames.length) _frames.add(ID3Frame('TALB'.codeUnits, data));
  }

  void setAlbumArtist(String? albumArtist) {
    if (albumArtist != null) {
      var data = [0x03] + utf8.encode(albumArtist) + [0x00];
      _frames.firstWhere((frame) => listEquals(frame.name, 'TPE2'.codeUnits),
          orElse: () {
        _frames.add(ID3Frame('TPE2'.codeUnits, List.empty()));
        return _frames.last;
      }).data = data;
    } else {
      _frames.remove(_frames.firstWhereOrNull(
          (frame) => listEquals(frame.name, 'TPE2'.codeUnits)));
    }
    // int i = 0;
    // var data = [0x03] + utf8.encode(albumArtist) + [0x00];
    // for (; i < _frames.length; i++) {
    //   if (listEquals(_frames[i].name, 'TPE2'.codeUnits)) {
    //     _frames[i].data = data;
    //     break;
    //   }
    // }
    // if (i == _frames.length) _frames.add(ID3Frame('TPE2'.codeUnits, data));
  }

  void setLyric(String? lyric) {
    if (lyric != null) {
      var data =
          [0x03] + [0x00, 0x00, 0x00] + [0x00] + utf8.encode(lyric) + [0x00];
      _frames.firstWhere((frame) => listEquals(frame.name, 'USLT'.codeUnits),
          orElse: () {
        _frames.add(ID3Frame('USLT'.codeUnits, List.empty()));
        return _frames.last;
      }).data = data;
    } else {
      _frames.remove(_frames.firstWhereOrNull(
          (frame) => listEquals(frame.name, 'USLT'.codeUnits)));
    }
    // int i = 0;
    // var data =
    //     [0x03] + [0x00, 0x00, 0x00] + [0x00] + utf8.encode(lyric) + [0x00];
    // for (; i < _frames.length; i++) {
    //   if (listEquals(_frames[i].name, 'USLT'.codeUnits)) {
    //     _frames[i].data = data;
    //     break;
    //   }
    // }
    // if (i == _frames.length) _frames.add(ID3Frame('USLT'.codeUnits, data));
  }

  void setComment(String? comment) {
    if (comment != null) {
      var data = [0x03] + utf8.encode(comment) + [0x00];
      _frames.firstWhere((frame) => listEquals(frame.name, 'COMM'.codeUnits),
          orElse: () {
        _frames.add(ID3Frame('COMM'.codeUnits, List.empty()));
        return _frames.last;
      }).data = data;
    } else {
      _frames.remove(_frames.firstWhereOrNull(
          (frame) => listEquals(frame.name, 'COMM'.codeUnits)));
    }
    // int i = 0;
    // var data =
    //     [0x03] + [0x00, 0x00, 0x00] + [0x00] + utf8.encode(comment) + [0x00];
    // for (; i < _frames.length; i++) {
    //   if (listEquals(_frames[i].name, 'COMM'.codeUnits)) {
    //     _frames[i].data = data;
    //     break;
    //   }
    // }
    // if (i == _frames.length) _frames.add(ID3Frame('COMM'.codeUnits, data));
  }

  void setCover(Uint8List? cover) {
    if (cover != null) {
      bool format = listEquals(cover.sublist(0, 2),
          [0xff, 0xd8]); // JPG starts with 0xff 0xd8, PNG starts with 0x89 0x50
      var data = [0x03];
      if (format) {
        data += 'image/'.codeUnits +
            'jpg'.codeUnits +
            [0x00, 0x00, 0x00] +
            cover +
            [0x00];
      } else {
        data += 'image/'.codeUnits +
            'png'.codeUnits +
            [0x00, 0x00, 0x00] +
            cover +
            [0x00];
      }
      _frames.firstWhere((frame) => listEquals(frame.name, 'APIC'.codeUnits),
          orElse: () {
        _frames.add(ID3Frame('APIC'.codeUnits, List.empty()));
        return _frames.last;
      }).data = data;
    } else {
      _frames.remove(_frames.firstWhereOrNull(
          (frame) => listEquals(frame.name, 'APIC'.codeUnits)));
    }
  }

  void setTrack(String? track) {
    if (track != null) {
      var data = [0x03] + utf8.encode(track) + [0x00];
      _frames.firstWhere((frame) => listEquals(frame.name, 'TRCK'.codeUnits),
          orElse: () {
        _frames.add(ID3Frame('TRCK'.codeUnits, List.empty()));
        return _frames.last;
      }).data = data;
    } else {
      _frames.remove(_frames.firstWhereOrNull(
          (frame) => listEquals(frame.name, 'TRCK'.codeUnits)));
    }
    // int i = 0;
    // var data = [0x03] + utf8.encode(track) + [0x00];
    // for (; i < _frames.length; i++) {
    //   if (listEquals(_frames[i].name, 'TRCK'.codeUnits)) {
    //     _frames[i].data = data;
    //     break;
    //   }
    // }
    // if (i == _frames.length) _frames.add(ID3Frame('TRCK'.codeUnits, data));
  }

  void setCD(String? cd) {
    if (cd != null) {
      var data = [0x03] + utf8.encode(cd) + [0x00];
      _frames.firstWhere((frame) => listEquals(frame.name, 'TPOS'.codeUnits),
          orElse: () {
        _frames.add(ID3Frame('TPOS'.codeUnits, List.empty()));
        return _frames.last;
      }).data = data;
    } else {
      _frames.remove(_frames.firstWhereOrNull(
          (frame) => listEquals(frame.name, 'TPOS'.codeUnits)));
    }
    // int i = 0;
    // var data = [0x03] + utf8.encode(cd) + [0x00];
    // for (; i < _frames.length; i++) {
    //   if (listEquals(_frames[i].name, 'TPOS'.codeUnits)) {
    //     _frames[i].data = data;
    //     break;
    //   }
    // }
    // if (i == _frames.length) _frames.add(ID3Frame('TPOS'.codeUnits, data));
  }

  void setYear(String? year) {
    if (year != null) {
      var data = [0x03] + utf8.encode(year) + [0x00];
      _frames.firstWhere((frame) => listEquals(frame.name, 'TYER'.codeUnits),
          orElse: () {
        _frames.add(ID3Frame('TYER'.codeUnits, List.empty()));
        return _frames.last;
      }).data = data;
    } else {
      _frames.remove(_frames.firstWhereOrNull(
          (frame) => listEquals(frame.name, 'TYER'.codeUnits)));
    }
    // int i = 0;
    // var data = [0x03] + utf8.encode(year) + [0x00];
    // for (; i < _frames.length; i++) {
    //   if (listEquals(_frames[i].name, 'TYER'.codeUnits)) {
    //     _frames[i].data = data;
    //     break;
    //   }
    // }
    // if (i == _frames.length) _frames.add(ID3Frame('TYER'.codeUnits, data));
  }

  void setEncoder(String? encoder) {
    if (encoder != null) {
      var data = [0x03] + utf8.encode(encoder) + [0x00];
      _frames.firstWhere((frame) => listEquals(frame.name, 'TENC'.codeUnits),
          orElse: () {
        _frames.add(ID3Frame('TENC'.codeUnits, List.empty()));
        return _frames.last;
      }).data = data;
    } else {
      _frames.remove(_frames.firstWhereOrNull(
          (frame) => listEquals(frame.name, 'TENC'.codeUnits)));
    }
    // int i = 0;
    // var data = [0x03] + utf8.encode(encoder) + [0x00];
    // for (; i < _frames.length; i++) {
    //   if (listEquals(_frames[i].name, 'TENC'.codeUnits)) {
    //     _frames[i].data = data;
    //     break;
    //   }
    // }
    // if (i == _frames.length) _frames.add(ID3Frame('TENC'.codeUnits, data));
  }
}
