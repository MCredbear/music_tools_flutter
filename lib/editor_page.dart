import 'dart:io';
import 'dart:async';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(title: Text('music')),
      body: Center(),
    );
  }
}
