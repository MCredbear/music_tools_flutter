// ignore_for_file: curly_braces_in_flow_control_structures

library taglib;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

part 'mp3.dart';
part 'flac.dart';

class AudioFile {
  AudioFile(this.path) {
    if (extension(path).lastIndexOf(RegExp('mp3', caseSensitive: false)) != -1)
      readMp3FIle(this);
    if (extension(path).lastIndexOf(RegExp('flac', caseSensitive: false)) != -1)
      readFlacFIle(this);
  }

  String path;
  late String title, artist, album, lyric;
}

Future<void> readMp3FIle(AudioFile audioFile) async {
  File file = File(audioFile.path);
  file.open(mode: FileMode.read);
  var dataStream = file.openRead(0, 10);
  String head = '';
  await for (var char in const Utf8Decoder().bind(dataStream)) head += char;
  if (!head.startsWith('ID3\x03')) {
    audioFile.title = '';
    audioFile.artist = '';
    audioFile.album = '';
    audioFile.lyric = '';
  } else {
    int totalSize = 0;
    for (int i = 0; i < 4; i++)
      totalSize += head[i + 6].codeUnitAt(0) * headTimes[i];
    if (totalSize != 0) {
      dataStream = file.openRead(10, totalSize);
      List<int> tagData = await dataStream.first;
      for (int i = 0; i < tagData.length - 4; i++) {
        if (matchTag(tagData.sublist(i, i + 4))) {
          print(i);
          print(String.fromCharCodes(tagData.sublist(i, i + 4)));
          int tagSize = 0;
          for (int j = 0; j < 4; j++)
            tagSize += tagData[i + 4 + j] * tagTimes[j];
          print(tagSize);
        }
      }
    }
  }
}

bool matchTag(List<int> byteList) {
  for (List<int> tag in tagList) {
    if (listEquals(tag, byteList)) return true;
  }
  return false;
}

const List<int> headTimes = [0x200000, 0x4000, 0x80, 1];
const List<int> tagTimes = [0x1000000, 0x10000, 0x100, 1];

List<List<int>> tagList = [
  'AENC'.codeUnits, //Audio encryption
  'APIC'.codeUnits, //Attached picture
  'COMM'.codeUnits, //Comments
  'COMR'.codeUnits, //Commercial frame
  'ENCR'.codeUnits, //Encryption method registration
  'EQUA'.codeUnits, //Equalization
  'ETCO'.codeUnits, //Event timing codes
  'GEOB'.codeUnits, //General encapsulated object
  'GRID'.codeUnits, //Group identification registration
  'IPLS'.codeUnits, //Involved people list
  'LINK'.codeUnits, //Linked information
  'MCDI'.codeUnits, //Music CD identifier
  'MLLT'.codeUnits, //MPEG location lookup table
  'OWNE'.codeUnits, //Ownership frame
  'PRIV'.codeUnits, //Private frame
  'PCNT'.codeUnits, //Play counter
  'POPM'.codeUnits, //Popularimeter
  'POSS'.codeUnits, //Position synchronisation frame
  'RBUF'.codeUnits, //Recommended buffer size
  'RVAD'.codeUnits, //Relative volume adjustment
  'RVRB'.codeUnits, //Reverb
  'SYLT'.codeUnits, //Synchronized lyric/text
  'SYTC'.codeUnits, //Synchronized tempo codes
  'TALB'.codeUnits, //Album/Movie/Show title
  'TBPM'.codeUnits, //BPM (beats per minute)
  'TCOM'.codeUnits, //Composer
  'TCON'.codeUnits, //Content type
  'TCOP'.codeUnits, //Copyright message
  'TDAT'.codeUnits, //Date
  'TDLY'.codeUnits, //Playlist delay
  'TENC'.codeUnits, //Encoded by
  'TEXT'.codeUnits, //Lyricist/Text writer
  'TFLT'.codeUnits, //File type
  'TIME'.codeUnits, //Time
  'TIT1'.codeUnits, //Content group description
  'TIT2'.codeUnits, //Title/songname/content description
  'TIT3'.codeUnits, //Subtitle/Description refinement
  'TKEY'.codeUnits, //Initial key
  'TLAN'.codeUnits, //Language(s)
  'TLEN'.codeUnits, //Length
  'TMED'.codeUnits, //Media type
  'TOAL'.codeUnits, //Original album/movie/show title
  'TOFN'.codeUnits, //Original filename
  'TOLY'.codeUnits, //Original lyricist(s)/text writer(s)
  'TOPE'.codeUnits, //Original artist(s)/performer(s)
  'TORY'.codeUnits, //Original release year
  'TOWN'.codeUnits, //File owner/licensee
  'TPE1'.codeUnits, //Lead performer(s)/Soloist(s)
  'TPE2'.codeUnits, //Band/orchestra/accompaniment
  'TPE3'.codeUnits, //Conductor/performer refinement
  'TPE4'.codeUnits, //Interpreted, remixed, or otherwise modified by
  'TPOS'.codeUnits, //Part of a set
  'TPUB'.codeUnits, //Publisher
  'TRCK'.codeUnits, //Track number/Position in set
  'TRDA'.codeUnits, //Recording dates
  'TRSN'.codeUnits, //Internet radio station name
  'TRSO'.codeUnits, //Internet radio station owner
  'TSIZ'.codeUnits, //Size
  'TSRC'.codeUnits, //ISRC (international standard recording code)
  'TSSE'.codeUnits, //Software/Hardware and settings used for encoding
  'TYER'.codeUnits, //Year
  'TXXX'.codeUnits, //User defined text information frame
  'UFID'.codeUnits, //Unique file identifier
  'USER'.codeUnits, //Terms of use
  'USLT'.codeUnits, //Unsychronized lyric/text transcription
  'WCOM'.codeUnits, //Commercial information
  'WCOP'.codeUnits, //Copyright/Legal information
  'WOAF'.codeUnits, //Official audio file webpage
  'WOAR'.codeUnits, //Official artist/performer webpage
  'WOAS'.codeUnits, //Official audio source webpage
  'WORS'.codeUnits, //Official internet radio station homepage
  'WPAY'.codeUnits, //Payment
  'WPUB'.codeUnits, //Publishers official webpage
  'WXXX'.codeUnits, //User defined URL link frame
];
