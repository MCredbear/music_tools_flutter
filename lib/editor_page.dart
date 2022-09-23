import 'dart:io';
import 'dart:async';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import 'taglib/taglib.dart';

class EditorPage extends StatefulWidget {
  EditorPage(this.path, {super.key});
  String path;
  @override
  State<EditorPage> createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  late AudioFile audioFile;
  @override
  void initState() {
    print(widget.path);
    audioFile = AudioFile(widget.path);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Observer(builder: ((_) => Text(audioFile.title)))),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 8,
                            child: Card(
                              elevation: 8,
                              child: Observer(
                                builder: (_) => Image(
                                    image: MemoryImage(
                                        audioFile.cover.isNotEmpty
                                            ? audioFile.cover
                                            : kTransparentImage)),
                              ),
                            )),
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                          flex: 8,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MaterialButton(
                                onPressed: () {},
                                color: Colors.blue,
                                child: const Text('选择封面'),
                              ),
                              MaterialButton(
                                  onPressed: () {},
                                  color: Colors.blue,
                                  child: const Text('移除封面')),
                              MaterialButton(
                                  onPressed: () {},
                                  color: Colors.blue,
                                  child: const Text('导出封面')),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    '歌曲名',
                    textScaleFactor: 1.4,
                  ),
                  TextField(
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '歌手',
                    textScaleFactor: 1.4,
                  ),
                  TextField(),
                  Text(
                    '专辑',
                    textScaleFactor: 1.4,
                  ),
                  TextField(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
