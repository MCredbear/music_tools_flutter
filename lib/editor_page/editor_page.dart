import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_tools_flutter/search_cover_page.dart';
import 'package:music_tools_flutter/search_lyric_page.dart';
import 'package:path/path.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';

import 'package:taglib_dart/taglib_dart.dart';
import 'save_file_non_web.dart' if (dart.library.js_util) 'save_file_web.dart';

class EditorPage extends StatefulWidget {
  const EditorPage(this.xFile, {super.key});

  final XFile xFile;

  @override
  State<EditorPage> createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  late final AudioFile _audioFile;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    widget.xFile.readAsBytes().then((bytes) {
      _audioFile = AudioFile(
          bytes,
          switch (extension(widget.xFile.name).toLowerCase()) {
            '.mp3' => Format.mp3,
            '.flac' => Format.flac,
            _ => Format.unknow
          });
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
  }

  void downloadCover(BuildContext context) async {
    Uint8List? data = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CoverSearchPage((_artistController
                        .text.isNotEmpty &&
                    _albumController.text.isNotEmpty &&
                    _titleController.text.isNotEmpty)
                ? '${_artistController.text} ${_albumController.text} ${_titleController.text}'
                : basenameWithoutExtension(widget.xFile.name))));
    if (data != null) {
      setState(() {
        _cover = data;
      });
    }
  }

  void importCover(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final file = File(result.files.first.path!);
      setState(() {
        _cover = file.readAsBytesSync();
      });
    }
  }

  void exportCover(BuildContext context) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await FilePicker.platform.saveFile(type: FileType.image, bytes: _cover!);
    } else {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        final file = File(result);
        file.writeAsBytesSync(_cover!);
      }
    }
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
    return PopScope(
      canPop: !saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.xFile.name,
            maxLines: 2,
            textScaler: const TextScaler.linear(0.8),
          ),
          actions: [
            IconButton(
                splashRadius: 24,
                onPressed: saving ? () {} : save,
                icon: saving
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Icon(Icons.save)),
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
                              onPressed: () => downloadCover(context),
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
                              onPressed: () => importCover(context),
                              color: Colors.blue,
                              child: const Text(
                                '导入封面',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          (_cover != null)
                              ? SizedBox(
                                  height: 40,
                                  child: MaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          _cover = null;
                                        });
                                      },
                                      color: Colors.blue,
                                      child: const Text(
                                        '移除封面',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                )
                              : Container(),
                          (_cover != null)
                              ? SizedBox(
                                  height: 40,
                                  child: MaterialButton(
                                      onPressed: () => exportCover(context),
                                      color: Colors.blue,
                                      child: const Text(
                                        '导出封面',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                )
                              : Container(),
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
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 25),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        '音轨',
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 25),
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
                                    (_artistController.text.isNotEmpty &&
                                            _albumController.text.isNotEmpty &&
                                            _titleController.text.isNotEmpty)
                                        ? '${_artistController.text} ${_albumController.text} ${_titleController.text}'
                                        : basenameWithoutExtension(
                                            widget.xFile.name))));
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
      ),
    );
  }

  Future<void> save() async {
    setState(() {
      saving = true;
    });
    try {
      await compute(saveAudioFile, {
        'audioFile': _audioFile,
        'xFile': widget.xFile,
        'title':
            _titleController.text.isNotEmpty ? _titleController.text : null,
        'album':
            _albumController.text.isNotEmpty ? _albumController.text : null,
        'artist':
            _artistController.text.isNotEmpty ? _artistController.text : null,
        'albumArtist': _albumArtistController.text.isNotEmpty
            ? _albumArtistController.text
            : null,
        'cd': _cdController.text.isNotEmpty ? _cdController.text : null,
        'track':
            _trackController.text.isNotEmpty ? _trackController.text : null,
        'year': _yearController.text.isNotEmpty ? _yearController.text : null,
        'lyric':
            _lyricController.text.isNotEmpty ? _lyricController.text : null,
        'comment':
            _commentController.text.isNotEmpty ? _commentController.text : null,
        'cover': _cover,
      });
      showToast('保存成功');
    } catch (e) {
      if (e.runtimeType.toString() == 'JSRangeError') {
        showToast('保存失败: 文件过大，请使用本地客户端处理',
            duration: const Duration(seconds: 5));
      } else {
        showToast('保存失败: ${e.toString()}',
            duration: const Duration(seconds: 5));
      }
    }
    setState(() {
      saving = false;
    });
  }
}
