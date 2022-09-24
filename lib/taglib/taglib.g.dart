// GENERATED CODE - DO NOT MODIFY BY HAND

part of taglib;

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AudioFile on AudioFileBase, Store {
  late final _$titleAtom = Atom(name: 'AudioFileBase.title');

  @override
  String get title {
    _$titleAtom.reportRead();
    return super.title;
  }

  @override
  set title(String value) {
    _$titleAtom.reportWrite(value, super.title, () {
      super.title = value;
    });
  }

  late final _$artistAtom = Atom(name: 'AudioFileBase.artist');

  @override
  String get artist {
    _$artistAtom.reportRead();
    return super.artist;
  }

  @override
  set artist(String value) {
    _$artistAtom.reportWrite(value, super.artist, () {
      super.artist = value;
    });
  }

  late final _$albumAtom = Atom(name: 'AudioFileBase.album');

  @override
  String get album {
    _$albumAtom.reportRead();
    return super.album;
  }

  @override
  set album(String value) {
    _$albumAtom.reportWrite(value, super.album, () {
      super.album = value;
    });
  }

  late final _$lyricAtom = Atom(name: 'AudioFileBase.lyric');

  @override
  String get lyric {
    _$lyricAtom.reportRead();
    return super.lyric;
  }

  @override
  set lyric(String value) {
    _$lyricAtom.reportWrite(value, super.lyric, () {
      super.lyric = value;
    });
  }

  late final _$commentAtom = Atom(name: 'AudioFileBase.comment');

  @override
  String get comment {
    _$commentAtom.reportRead();
    return super.comment;
  }

  @override
  set comment(String value) {
    _$commentAtom.reportWrite(value, super.comment, () {
      super.comment = value;
    });
  }

  late final _$trackAtom = Atom(name: 'AudioFileBase.track');

  @override
  String get track {
    _$trackAtom.reportRead();
    return super.track;
  }

  @override
  set track(String value) {
    _$trackAtom.reportWrite(value, super.track, () {
      super.track = value;
    });
  }

  late final _$cdAtom = Atom(name: 'AudioFileBase.cd');

  @override
  String get cd {
    _$cdAtom.reportRead();
    return super.cd;
  }

  @override
  set cd(String value) {
    _$cdAtom.reportWrite(value, super.cd, () {
      super.cd = value;
    });
  }

  late final _$yearAtom = Atom(name: 'AudioFileBase.year');

  @override
  String get year {
    _$yearAtom.reportRead();
    return super.year;
  }

  @override
  set year(String value) {
    _$yearAtom.reportWrite(value, super.year, () {
      super.year = value;
    });
  }

  late final _$encoderAtom = Atom(name: 'AudioFileBase.encoder');

  @override
  String get encoder {
    _$encoderAtom.reportRead();
    return super.encoder;
  }

  @override
  set encoder(String value) {
    _$encoderAtom.reportWrite(value, super.encoder, () {
      super.encoder = value;
    });
  }

  late final _$coverAtom = Atom(name: 'AudioFileBase.cover');

  @override
  Uint8List get cover {
    _$coverAtom.reportRead();
    return super.cover;
  }

  @override
  set cover(Uint8List value) {
    _$coverAtom.reportWrite(value, super.cover, () {
      super.cover = value;
    });
  }

  late final _$AudioFileBaseActionController =
      ActionController(name: 'AudioFileBase');

  @override
  void setTitle(String title) {
    final _$actionInfo = _$AudioFileBaseActionController.startAction(
        name: 'AudioFileBase.setTitle');
    try {
      return super.setTitle(title);
    } finally {
      _$AudioFileBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setArtist(String artist) {
    final _$actionInfo = _$AudioFileBaseActionController.startAction(
        name: 'AudioFileBase.setArtist');
    try {
      return super.setArtist(artist);
    } finally {
      _$AudioFileBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAlbum(String album) {
    final _$actionInfo = _$AudioFileBaseActionController.startAction(
        name: 'AudioFileBase.setAlbum');
    try {
      return super.setAlbum(album);
    } finally {
      _$AudioFileBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAlbumArtist(String albumArtist) {
    final _$actionInfo = _$AudioFileBaseActionController.startAction(
        name: 'AudioFileBase.setAlbumArtist');
    try {
      return super.setAlbumArtist(albumArtist);
    } finally {
      _$AudioFileBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLyric(String lyric) {
    final _$actionInfo = _$AudioFileBaseActionController.startAction(
        name: 'AudioFileBase.setLyric');
    try {
      return super.setLyric(lyric);
    } finally {
      _$AudioFileBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setComment(String comment) {
    final _$actionInfo = _$AudioFileBaseActionController.startAction(
        name: 'AudioFileBase.setComment');
    try {
      return super.setComment(comment);
    } finally {
      _$AudioFileBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTrack(String track) {
    final _$actionInfo = _$AudioFileBaseActionController.startAction(
        name: 'AudioFileBase.setTrack');
    try {
      return super.setTrack(track);
    } finally {
      _$AudioFileBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCD(String cd) {
    final _$actionInfo = _$AudioFileBaseActionController.startAction(
        name: 'AudioFileBase.setCD');
    try {
      return super.setCD(cd);
    } finally {
      _$AudioFileBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setYear(String year) {
    final _$actionInfo = _$AudioFileBaseActionController.startAction(
        name: 'AudioFileBase.setYear');
    try {
      return super.setYear(year);
    } finally {
      _$AudioFileBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEncoder(String encoder) {
    final _$actionInfo = _$AudioFileBaseActionController.startAction(
        name: 'AudioFileBase.setEncoder');
    try {
      return super.setEncoder(encoder);
    } finally {
      _$AudioFileBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCovre(Uint8List cover) {
    final _$actionInfo = _$AudioFileBaseActionController.startAction(
        name: 'AudioFileBase.setCovre');
    try {
      return super.setCovre(cover);
    } finally {
      _$AudioFileBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
title: ${title},
artist: ${artist},
album: ${album},
lyric: ${lyric},
comment: ${comment},
track: ${track},
cd: ${cd},
year: ${year},
encoder: ${encoder},
cover: ${cover}
    ''';
  }
}
