import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:music_tools_flutter/search_cover_page.dart';
import 'package:music_tools_flutter/search_lyric_page.dart';
import 'package:path/path.dart';

import 'taglib/taglib.dart';

class EditorPage extends StatefulWidget {
  const EditorPage(this.path, {super.key});

  final String path;

  @override
  State<EditorPage> createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  late final AudioFile _audioFile;

  @override
  void initState() {
    _audioFile = AudioFile(widget.path);
    _audioFile.read().then((value) {
      setState(() {
        _titleController.text = _audioFile.getTitle() ?? '';
        _artistController.text = _audioFile.getArtist() ?? '';
        _albumController.text = _audioFile.getAlbum() ?? '';
        _albumArtistController.text = _audioFile.getAlbumArtist() ?? '';
        _cdController.text = _audioFile.getCD() ?? '';
        _trackController.text = _audioFile.getTrack() ?? '';
        _yearController.text = _audioFile.getYear() ?? '';
        _lyricController.text = _audioFile.getLyric() ?? '';
        _commentController.text = _audioFile.getComment() ?? '';
        _cover = _audioFile.getCover();
      });
    });
    super.initState();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _albumController = TextEditingController();
  final TextEditingController _albumArtistController = TextEditingController();
  final TextEditingController _cdController = TextEditingController();
  final TextEditingController _trackController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _lyricController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  Uint8List? _cover;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          basename(widget.path),
          maxLines: 2,
          textScaler: const TextScaler.linear(0.8),
        ),
        actions: [
          IconButton(
              splashRadius: 24,
              onPressed: (() {
                _audioFile.setTitle(_titleController.text.isNotEmpty
                    ? _titleController.text
                    : null);
                _audioFile.setAlbum(_albumController.text.isNotEmpty
                    ? _albumController.text
                    : null);
                _audioFile.setArtist(_artistController.text.isNotEmpty
                    ? _artistController.text
                    : null);
                _audioFile.setAlbumArtist(_albumArtistController.text.isNotEmpty
                    ? _albumArtistController.text
                    : null);
                _audioFile.setCD(
                    _cdController.text.isNotEmpty ? _cdController.text : null);
                _audioFile.setTrack(_trackController.text.isNotEmpty
                    ? _trackController.text
                    : null);
                _audioFile.setLyric(_lyricController.text.isNotEmpty
                    ? _lyricController.text
                    : null);
                _audioFile.setComment(_commentController.text.isNotEmpty
                    ? _commentController.text
                    : null);
                _audioFile.setCover(_cover);
                _audioFile.save();
              }),
              icon: const Icon(Icons.save)),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      child: (_cover != null)
                          ? Card(
                              clipBehavior: Clip.antiAlias,
                              margin: const EdgeInsets.all(0),
                              elevation: 8,
                              child: Image(
                                  image: MemoryImage(_cover!),
                                  fit: BoxFit.contain))
                          : const Text(
                              '无封面',
                              textAlign: TextAlign.center,
                              textScaler: TextScaler.linear(4),
                            )),
                  const SizedBox(width: 20),
                  Container(
                    constraints: const BoxConstraints(
                        maxHeight: 250,
                        minHeight: 200,
                        maxWidth: 100,
                        minWidth: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 40,
                          child: MaterialButton(
                            onPressed: () async {
                              Uint8List? data = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CoverSearchPage(
                                          _titleController.text.isNotEmpty
                                              ? _titleController.text
                                              : basenameWithoutExtension(
                                                  widget.path))));
                              if (data != null) {
                                setState(() {
                                  _cover = data;
                                });
                              }
                            },
                            color: Colors.blue,
                            child: const Text(
                              '下载封面',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: MaterialButton(
                            onPressed: () {},
                            color: Colors.blue,
                            child: const Text(
                              '导入封面',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: MaterialButton(
                              onPressed: () {
                                setState(() {
                                  _cover = Uint8List(0);
                                });
                              },
                              color: Colors.blue,
                              child: const Text(
                                '移除封面',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                        SizedBox(
                          height: 40,
                          child: MaterialButton(
                              onPressed: () {},
                              color: Colors.blue,
                              child: const Text(
                                '导出封面',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                '歌曲名',
                style: TextStyle(color: Colors.blueAccent, fontSize: 25),
              ),
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Text(
                '歌手',
                style: TextStyle(color: Colors.blueAccent, fontSize: 25),
              ),
              TextField(
                controller: _artistController,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Text(
                '专辑',
                style: TextStyle(color: Colors.blueAccent, fontSize: 25),
              ),
              TextField(
                controller: _albumController,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Text(
                '专辑作者',
                style: TextStyle(color: Colors.blueAccent, fontSize: 25),
              ),
              TextField(
                controller: _albumArtistController,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      '磁盘号',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 25),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      '音轨',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 25),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cdController,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _trackController,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                '年份',
                style: TextStyle(color: Colors.blueAccent, fontSize: 25),
              ),
              TextField(
                controller: _yearController,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '歌词',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 25),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      String? data = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LyricSearchPage(
                                  _titleController.text.isNotEmpty
                                      ? _titleController.text
                                      : basenameWithoutExtension(
                                          widget.path))));
                      if (data != null) {
                        setState(() {
                          _lyricController.text = data;
                        });
                      }
                    },
                    color: Colors.blue,
                    child: const Text(
                      '搜索歌词',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
              TextField(
                controller: _lyricController,
                maxLines: null,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Text(
                '评论',
                style: TextStyle(color: Colors.blueAccent, fontSize: 25),
              ),
              TextField(
                controller: _commentController,
                maxLines: null,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}
