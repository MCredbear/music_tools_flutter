part of 'taglib.dart';

class ID3Frame {
  ID3Frame(this.name, this.data);
  List<int> name;
  List<int> data;
}

class Mp3File {
  Mp3File(this.audioFile);

  AudioFile audioFile;

  List<ID3Frame> frames = [];

  Future<bool> read(AudioFile audioFile) async {
    frames.clear();
    File file = File(audioFile._path);
    var randomAccessFile = file.openSync();
    List<int> head = randomAccessFile.readSync(10);
    if ((head[0] != 'I'.codeUnitAt(0)) |
        (head[1] != 'D'.codeUnitAt(0)) |
        (head[2] != '3'.codeUnitAt(0))) {
      return false;
    } else {
      int version = head[3];
      int tagSize = 0;

      tagSize += head[6] * 0x200000;
      tagSize += head[7] * 0x4000;
      tagSize += head[8] * 0x80;
      tagSize += head[9];

      if (tagSize != 0) {
        List<int> tagData = randomAccessFile.readSync(tagSize);
        int i = 0;
        while (i < tagData.length - 10) {
          if (tagData[i] == 0) break;
          int frameSize = 0;
          if (version == 3) {
            frameSize += tagData[i + 4] * 0x1000000;
            frameSize += tagData[i + 4 + 1] * 0x10000;
            frameSize += tagData[i + 4 + 2] * 0x100;
            frameSize += tagData[i + 4 + 3];
          } else {
            frameSize += tagData[i + 4] * 0x200000;
            frameSize += tagData[i + 4 + 1] * 0x4000;
            frameSize += tagData[i + 4 + 2] * 0x80;
            frameSize += tagData[i + 4 + 3];
          }
          frames.add(ID3Frame(tagData.sublist(i, i + 4),
              tagData.sublist(i + 10, i + 10 + frameSize)));
          i += frameSize + 10;
        }
      }
      return true;
    }
  }

  Future<bool> save(AudioFile audioFile) async {
    List<int> head = 'ID3'.codeUnits + [0x03, 0x00, 0x00];
    List<int> tagData = [];
    for (var element in frames) {
      List<int> frameData = [];
      frameData.addAll(element.name);
      int frameSize = element.data.length;
      frameData.add(frameSize ~/ 0x1000000);
      frameSize %= 0x1000000;
      frameData.add(frameSize ~/ 0x10000);
      frameSize %= 0x10000;
      frameData.add(frameSize ~/ 0x100);
      frameSize %= 0x100;
      frameData.add(frameSize);
      frameData += [0x00, 0x00];
      frameData += element.data;
      tagData.addAll(frameData);
    }
    int tagSize = tagData.length;
    head.add(tagSize ~/ 0x200000);
    tagSize %= 0x200000;
    head.add(tagSize ~/ 0x4000);
    tagSize %= 0x4000;
    head.add(tagSize ~/ 0x80);
    tagSize %= 0x80;
    head.add(tagSize);
    File file = File(audioFile._path);
    DateTime fileTime = file.lastModifiedSync();
    List<int> totalData = file.readAsBytesSync();
    if ((totalData[0] == 'I'.codeUnitAt(0)) &
        (totalData[1] == 'D'.codeUnitAt(0)) &
        (totalData[2] == '3'.codeUnitAt(0))) {
      int preTagSize = 0;
      preTagSize += totalData[6] * 0x200000;
      preTagSize += totalData[7] * 0x4000;
      preTagSize += totalData[8] * 0x80;
      preTagSize += totalData[9];
      if (preTagSize != 0) {
        totalData = totalData.sublist(10 + preTagSize);
      }
    }
    totalData = head + tagData + totalData;
    file.writeAsBytesSync(totalData, flush: true);
    file.setLastModifiedSync(fileTime);
    return true;
  }

  String getTitle() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TIT2'.codeUnits)) {
        return defaultReading(frames[i].data);
      }
    }
    return '';
  }

  String getArtist() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TPE1'.codeUnits)) {
        return defaultReading(frames[i].data);
      }
    }
    return '';
  }

  String getAlbum() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TALB'.codeUnits)) {
        return defaultReading(frames[i].data);
      }
    }
    return '';
  }

  String getAlbumArtist() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TPE2'.codeUnits)) {
        return defaultReading(frames[i].data);
      }
    }
    return '';
  }

  String getLyric() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'USLT'.codeUnits)) {
        switch (frames[i].data.first) {
          case 0x00:
            return readLatin1(frames[i].data.sublist(10));
          case 0x01:
            return readUtf16LeString(frames[i].data.sublist(8));
          case 0x02:
            return readUtf16BeString(frames[i].data.sublist(8));
          case 0x03:
            return readUtf8String(frames[i].data.sublist(5));
        }
      }
    }
    return '';
  }

  String getComment() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'COMM'.codeUnits)) {
        switch (frames[i].data.first) {
          case 0x00:
            return readLatin1(frames[i].data.sublist(5));
          case 0x01:
            return readUtf16LeString(frames[i].data.sublist(8));
          case 0x02:
            return readUtf16BeString(frames[i].data.sublist(8));
          case 0x03:
            return readUtf8String(frames[i].data.sublist(5));
        }
      }
    }
    return '';
  }

  Uint8List getCover() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'APIC'.codeUnits)) {
        int mimeEnd = frames[i].data.indexOf(0, 1);
        int descriptionEnd = frames[i].data.indexOf(0, mimeEnd + 2);
        if ((frames[i].data[0] == 0x01) | (frames[i].data[0] == 0x02)) {
          descriptionEnd += 1;
        }
        return Uint8List.fromList(frames[i].data.sublist(descriptionEnd + 1));
      }
    }
    return Uint8List(0);
  }

  String getTrack() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TRCK'.codeUnits)) {
        return defaultReading(frames[i].data);
      }
    }
    return '';
  }

  String getCD() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TPOS'.codeUnits)) {
        return defaultReading(frames[i].data);
      }
    }
    return '';
  }

  String getYear() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TYER'.codeUnits)) {
        return defaultReading(frames[i].data);
      }
    }
    return '';
  }

  String getEncoder() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TENC'.codeUnits)) {
        return defaultReading(frames[i].data);
      }
    }
    return '';
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

  void setTitle(String title) {
    int i = 0;
    var data = [0x03] + utf8.encode(title) + [0x00];
    for (; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TIT2'.codeUnits)) {
        frames[i].data = data;
        break;
      }
    }
    if (i == frames.length) frames.add(ID3Frame('TIT2'.codeUnits, data));
  }

  void setArtist(String artist) {
    int i = 0;
    var data = [0x03] + utf8.encode(artist) + [0x00];
    for (; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TPE1'.codeUnits)) {
        frames[i].data = data;
        break;
      }
    }
    if (i == frames.length) frames.add(ID3Frame('TPE1'.codeUnits, data));
  }

  void setAlbum(String album) {
    int i = 0;
    var data = [0x03] + utf8.encode(album) + [0x00];
    for (; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TALB'.codeUnits)) {
        frames[i].data = data;
        break;
      }
    }
    if (i == frames.length) frames.add(ID3Frame('TALB'.codeUnits, data));
  }

  void setAlbumArtist(String albumArtist) {
    int i = 0;
    var data = [0x03] + utf8.encode(albumArtist) + [0x00];
    for (; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TPE2'.codeUnits)) {
        frames[i].data = data;
        break;
      }
    }
    if (i == frames.length) frames.add(ID3Frame('TPE2'.codeUnits, data));
  }

  void setLyric(String lyric) {
    int i = 0;
    var data =
        [0x03] + [0x00, 0x00, 0x00] + [0x00] + utf8.encode(lyric) + [0x00];
    for (; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'USLT'.codeUnits)) {
        frames[i].data = data;
        break;
      }
    }
    if (i == frames.length) frames.add(ID3Frame('USLT'.codeUnits, data));
  }

  void setComment(String comment) {
    int i = 0;
    var data =
        [0x03] + [0x00, 0x00, 0x00] + [0x00] + utf8.encode(comment) + [0x00];
    for (; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'COMM'.codeUnits)) {
        frames[i].data = data;
        break;
      }
    }
    if (i == frames.length) frames.add(ID3Frame('COMM'.codeUnits, data));
  }

  void setCover(Uint8List cover) {
    bool format = listEquals(cover.sublist(0, 2),
        [0xff, 0xd8]); // JPG starts with 0xff 0xd8, PNG starts with 0x89 0x50
    int i = 0;
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
    for (; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'APIC'.codeUnits)) {
        frames[i].data = data;
        break;
      }
    }
    if (i == frames.length) frames.add(ID3Frame('APIC'.codeUnits, data));
  }

  void setTrack(String track) {
    int i = 0;
    var data = [0x03] + utf8.encode(track) + [0x00];
    for (; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TRCK'.codeUnits)) {
        frames[i].data = data;
        break;
      }
    }
    if (i == frames.length) frames.add(ID3Frame('TRCK'.codeUnits, data));
  }

  void setCD(String cd) {
    int i = 0;
    var data = [0x03] + utf8.encode(cd) + [0x00];
    for (; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TPOS'.codeUnits)) {
        frames[i].data = data;
        break;
      }
    }
    if (i == frames.length) frames.add(ID3Frame('TPOS'.codeUnits, data));
  }

  void setYear(String year) {
    int i = 0;
    var data = [0x03] + utf8.encode(year) + [0x00];
    for (; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TYER'.codeUnits)) {
        frames[i].data = data;
        break;
      }
    }
    if (i == frames.length) frames.add(ID3Frame('TYER'.codeUnits, data));
  }

  void setEncoder(String encoder) {
    int i = 0;
    var data = [0x03] + utf8.encode(encoder) + [0x00];
    for (; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'TENC'.codeUnits)) {
        frames[i].data = data;
        break;
      }
    }
    if (i == frames.length) frames.add(ID3Frame('TENC'.codeUnits, data));
  }
}
