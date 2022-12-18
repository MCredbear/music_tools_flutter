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
        if (frames[i].data.first == 0x00) {
          return (readLatin1(frames[i].data.sublist(10)));
        }
        if (frames[i].data.first == 0x01) {
          return (readUtf16LeString(frames[i].data.sublist(8)));
        }
        if (frames[i].data.first == 0x02) {
          return (readUtf16BeString(frames[i].data.sublist(8)));
        }
      }
    }
    return '';
  }

  String getComment() {
    for (int i = 0; i < frames.length; i++) {
      if (listEquals(frames[i].name, 'COMM'.codeUnits)) {
        if (frames[i].data.first == 0x00) {
          return (readLatin1(frames[i].data.sublist(5)));
        }
        if (frames[i].data.first == 0x01) {
          return (readUtf16LeString(frames[i].data.sublist(5)));
        }
        if (frames[i].data.first == 0x02) {
          return (readUtf16BeString(frames[i].data.sublist(5)));
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
    return utf8.decode(byteList.sublist(0, byteList.length - 1));
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
}
