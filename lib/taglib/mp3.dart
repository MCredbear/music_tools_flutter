part of 'taglib.dart';

const List<int> headTimes = [0x200000, 0x4000, 0x80, 1];
const List<int> tagTimes = [0x1000000, 0x10000, 0x100, 1];

Future<void> readMp3FIle(AudioFileBase audioFileBase) async {
  // 中国流媒体平台上用不到的标签我就不实现了
  Map<String, Function(List<int>)> tagReadingMap = {
    // 'AENC': defaultReading, //Audio encryption
    'APIC': (List<int> byteList) {
      byteList = byteList.sublist(13);
      Uint8List uint8list = Uint8List(byteList.length);
      for (int i = 0; i < byteList.length; i++) {
        uint8list[i] = byteList[i];
      }
      audioFileBase.setCovre(uint8list);
    }, //Attached picture TOO LARGE
    'COMM': (List<int> byteList) {
      audioFileBase.setComment(commReading(byteList));
    }, //Comments
    // 'COMR': defaultReading, //Commercial frame
    // 'ENCR': defaultReading, //Encryption method registration
    // 'EQUA': defaultReading, //Equalization
    // 'ETCO': defaultReading, //Event timing codes
    // 'GEOB': defaultReading, //General encapsulated object
    // 'GRID': defaultReading, //Group identification registration
    // 'IPLS': defaultReading, //Involved people list
    // 'LINK': defaultReading, //Linked information
    // 'MCDI': defaultReading, //Music CD identifier
    // 'MLLT': defaultReading, //MPEG location lookup table
    // 'OWNE': defaultReading, //Ownership frame
    // 'PRIV': defaultReading, //Private frame
    // 'PCNT': defaultReading, //Play counter
    // 'POPM': defaultReading, //Popularimeter
    // 'POSS': defaultReading, //Position synchronisation frame
    // 'RBUF': defaultReading, //Recommended buffer size
    // 'RVAD': defaultReading, //Relative volume adjustment
    // 'RVRB': defaultReading, //Reverb
    // 'SYLT': defaultReading, //Synchronized lyric/text
    // 'SYTC': defaultReading, //Synchronized tempo codes
    'TALB': (List<int> byteList) {
      audioFileBase.setAlbum(defaultReading(byteList));
    }, //Album/Movie/Show title
    // 'TBPM': defaultReading, //BPM (beats per minute)
    // 'TCOM': defaultReading, //Composer
    // 'TCON': defaultReading, //Content type
    // 'TCOP': defaultReading, //Copyright message
    // 'TDAT': defaultReading, //Date
    // 'TDLY': defaultReading, //Playlist delay
    // 'TENC': defaultReading, //Encoded by
    // 'TEXT': defaultReading, //Lyricist/Text writer
    // 'TFLT': defaultReading, //File type
    // 'TIME': defaultReading, //Time
    // 'TIT1': defaultReading, //Content group description
    'TIT2': (List<int> byteList) {
      audioFileBase.setTitle(defaultReading(byteList));
    }, //Title/songname/content description
    // 'TIT3': defaultReading, //Subtitle/Description refinement
    // 'TKEY': defaultReading, //Initial key
    // 'TLAN': defaultReading, //Language(s)
    // 'TLEN': defaultReading, //Length
    // 'TMED': defaultReading, //Media type
    // 'TOAL': defaultReading, //Original album/movie/show title
    // 'TOFN': defaultReading, //Original filename
    // 'TOLY': defaultReading, //Original lyricist(s)/text writer(s)
    // 'TOPE': defaultReading, //Original artist(s)/performer(s)
    // 'TORY': defaultReading, //Original release year
    // 'TOWN': defaultReading, //File owner/licensee
    'TPE1': (List<int> byteList) {
      audioFileBase.setArtist(defaultReading(byteList));
    }, //Lead performer(s)/Soloist(s)
    'TPE2': (List<int> byteList) {
      audioFileBase.setAlbumArtist(defaultReading(byteList));
    }, //Band/orchestra/accompaniment
    // 'TPE3': defaultReading, //Conductor/performer refinement
    // 'TPE4': defaultReading, //Interpreted, remixed, or otherwise modified by
    'TPOS': (List<int> byteList) {
      audioFileBase.setCD(defaultReading(byteList));
    }, //Part of a set
    // 'TPUB': defaultReading, //Publisher
    'TRCK': (List<int> byteList) {
      audioFileBase.setTrack(defaultReading(byteList));
    }, //Track number/Position in set
    // 'TRDA': defaultReading, //Recording dates
    // 'TRSN': defaultReading, //Internet radio station name
    // 'TRSO': defaultReading, //Internet radio station owner
    // 'TSIZ': defaultReading, //Size
    // 'TSRC': defaultReading, //ISRC (international standard recording code)
    'TSSE': (List<int> byteList) {
      audioFileBase.setEncoder(defaultReading(byteList));
    }, //Software/Hardware and settings used for encoding
    'TYER': (List<int> byteList) {
      audioFileBase.setYear(defaultReading(byteList));
    }, //Year
    // 'TXXX': txxxReading, //User defined text information frame
    // 'UFID': defaultReading, //Unique file identifier
    // 'USER': defaultReading, //Terms of use
    'USLT': (List<int> byteList) {
      audioFileBase.setLyric(usltReading(byteList));
    }, //Unsychronized lyric/text transcription
    // 'WCOM': defaultReading, //Commercial information
    // 'WCOP': defaultReading, //Copyright/Legal information
    // 'WOAF': defaultReading, //Official audio file webpage
    // 'WOAR': defaultReading, //Official artist/performer webpage
    // 'WOAS': defaultReading, //Official audio source webpage
    // 'WORS': defaultReading, //Official internet radio station homepage
    // 'WPAY': defaultReading, //Payment
    // 'WPUB': defaultReading, //Publishers official webpage
    // 'WXXX': wxxxReading, //User defined URL link frame
  };

  File file = File(audioFileBase.path);
  file.open(mode: FileMode.read);
  var dataStream = file.openRead(0, 10);
  String head = '';
  await for (var char in const Utf8Decoder().bind(dataStream)) {
    head += char;
  }
  if (!(head.startsWith('ID3\x03') | head.startsWith('ID3\x04'))) {
    audioFileBase.title = '';
    audioFileBase.artist = '';
    audioFileBase.album = '';
    audioFileBase.lyric = '';
    audioFileBase.comment = '';
  } else {
    int totalSize = 0;
    for (int i = 0; i < 4; i++) {
      totalSize += head[i + 6].codeUnitAt(0) * headTimes[i];
    }
    if (totalSize != 0) {
      dataStream = file.openRead(10, totalSize);
      List<int> tagData = [];
      await for (var buff in dataStream) {
        tagData += buff;
      }
      for (int i = 0; i < tagData.length - 10; i++) {
        if (tagReadingMap
            .containsKey(String.fromCharCodes(tagData.sublist(i, i + 4)))) {
          int tagSize = 0;
          for (int j = 0; j < 4; j++) {
            tagSize += tagData[i + 4 + j] * tagTimes[j];
          }
          //65536
          //tagData.sublist(i + 10, i + 10 + tagSize)
          // List<int> subList = [];
          // for (int j = i + 10; j < i + 10 + tagSize; j++)
          //   subList.add(tagData[j]);
          tagReadingMap[String.fromCharCodes(tagData.sublist(i, i + 4))]!
              .call(tagData.sublist(i + 10, i + 10 + tagSize));
          i += tagSize + 9;
        }
      }
    }
  }
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

String defaultReading(List<int> byteList) {
  if (byteList.length > 1) {
    if (byteList.first == 0x00) return (readLatin1(byteList.sublist(1)));
    if (byteList.first == 0x01) return (readUtf16LeString(byteList.sublist(1)));
    if (byteList.first == 0x02) return (readUtf16BeString(byteList.sublist(1)));
    return '';
  } else {
    return '';
  }
}

String usltReading(List<int> byteList) {
  if (byteList.length > 2) {
    if (byteList.first == 0x00) return (readLatin1(byteList.sublist(10)));
    if (byteList.first == 0x01) return (readUtf16LeString(byteList.sublist(8)));
    if (byteList.first == 0x02) return (readUtf16BeString(byteList.sublist(8)));
    return '';
  } else {
    return '';
  }
}

String commReading(List<int> byteList) {
  if (byteList.length > 2) {
    if (byteList.first == 0x00) return (readLatin1(byteList.sublist(5)));
    if (byteList.first == 0x01) return (readUtf16LeString(byteList.sublist(5)));
    if (byteList.first == 0x02) return (readUtf16BeString(byteList.sublist(5)));
    return '';
  } else {
    return '';
  }
}

String txxxReading(List<int> byteList) {
  if (byteList.length > 2) {
    if (byteList.first == 0x00) return (readLatin1(byteList.sublist(2)));
    if (byteList.first == 0x01) return (readUtf16LeString(byteList.sublist(2)));
    if (byteList.first == 0x02) return (readUtf16BeString(byteList.sublist(2)));
    return '';
  } else {
    return '';
  }
}

String wxxxReading(List<int> byteList) {
  if (byteList.length > 2) {
    if (byteList.first == 0x00) return (readLatin1(byteList.sublist(2)));
    if (byteList.first == 0x01) return (readUtf16LeString(byteList.sublist(2)));
    if (byteList.first == 0x02) return (readUtf16BeString(byteList.sublist(2)));
    return '';
  } else {
    return '';
  }
}
