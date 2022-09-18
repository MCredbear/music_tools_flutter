import 'dart:io';
import 'dart:async';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'editor_page.dart';

import 'file_manager_store.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Music tools Flutter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FileManagerPage());
  }
}

class FileManagerPage extends StatefulWidget {
  @override
  State<FileManagerPage> createState() => FileManagerPageState();
}

class FileManagerPageState extends State<FileManagerPage> {
  FileManagerStore fileManagerStore = FileManagerStore();

  String _path = '/home/redbear/Music';

  @override
  void initState() {
    fileManagerStore.readDir(_path);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music tools Flutter"),
        actions: [
          IconButton(
              splashRadius: 24,
              onPressed: (() {
                fileManagerStore.readDir(_path);
              }),
              icon: const Icon(Icons.refresh)),
          IconButton(
              splashRadius: 24,
              onPressed: (() {
                _path = dirname(_path);
                fileManagerStore.readDir(_path);
              }),
              icon: const Icon(Icons.arrow_upward))
        ],
      ),
      body: Center(
          child: Observer(
              builder: (_) => ListView.builder(
                    itemCount: fileManagerStore.elements.length,
                    itemBuilder: (context, index) => SizedBox(
                      height: 60,
                      child: ListTile(
                        onTap: (() {
                          if (fileManagerStore.elements.elementAt(index)
                              is Directory) {
                            _path =
                                fileManagerStore.elements.elementAt(index).path;
                            fileManagerStore.readDir(_path);
                          } else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return EditorPage(fileManagerStore.elements
                                  .elementAt(index)
                                  .path);
                            }));
                          }
                        }),
                        leading: (fileManagerStore.elements.elementAt(index)
                                is Directory)
                            ? const Icon(
                                Icons.folder,
                                size: 30,
                              )
                            : const Icon(
                                Icons.audio_file,
                                size: 30,
                              ),
                        title: Text(
                          basename(
                              fileManagerStore.elements.elementAt(index).path),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(fileManagerStore.elements
                            .elementAt(index)
                            .statSync()
                            .modified
                            .toString()),
                      ),
                    ),
                  ))),
    );
  }
}
