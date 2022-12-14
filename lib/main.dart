import 'dart:io';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'editor_page.dart';

import 'file_manager_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    while (true) {
      var result = await Permission.storage.request();
      if (result.isGranted) break;
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Music tools Flutter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const FileManagerPage());
  }
}

class FileManagerPage extends StatefulWidget {
  const FileManagerPage({super.key});

  @override
  State<FileManagerPage> createState() => FileManagerPageState();
}

class FileManagerPageState extends State<FileManagerPage> {
  FileManagerStore fileManagerStore = FileManagerStore();

  List<String> pathsQueue = [
    Platform.isAndroid ? '/storage/emulated/0/' : '/home/redbear/Music'
  ];

  @override
  void initState() {
    fileManagerStore.readDir(pathsQueue.last);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music tools Flutter"),
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.sort),
              splashRadius: 24,
              itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Observer(builder: (context) {
                              return CheckboxListTile(
                                title: const Text('升序'),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: fileManagerStore.reserved,
                                onChanged: (value) =>
                                    fileManagerStore.reserve(),
                              );
                            }),
                            const Divider(height: 1)
                          ],
                        )),
                    PopupMenuItem(
                        padding: EdgeInsets.zero,
                        child: Observer(builder: (context) {
                          return CheckboxListTile(
                            title: const Text('按名称排序'),
                            checkboxShape: const CircleBorder(),
                            controlAffinity: ListTileControlAffinity.leading,
                            value:
                                fileManagerStore.sortOrder == SortOrder.byName,
                            onChanged: (value) =>
                                fileManagerStore.setOrder(SortOrder.byName),
                          );
                        })),
                    PopupMenuItem(
                        padding: EdgeInsets.zero,
                        child: Observer(builder: (context) {
                          return CheckboxListTile(
                            title: const Text('按修改时间排序'),
                            checkboxShape: const CircleBorder(),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: fileManagerStore.sortOrder ==
                                SortOrder.byModifiedTime,
                            onChanged: (value) => fileManagerStore
                                .setOrder(SortOrder.byModifiedTime),
                          );
                        })),
                  ]),
          IconButton(
              splashRadius: 24,
              onPressed: (() {
                if (pathsQueue.length > 1) pathsQueue.removeLast();
                fileManagerStore.readDir(pathsQueue.last);
              }),
              icon: const Icon(Icons.keyboard_arrow_left_sharp)),
          IconButton(
              splashRadius: 24,
              onPressed: (() {
                fileManagerStore.readDir(pathsQueue.last);
              }),
              icon: const Icon(Icons.refresh)),
          IconButton(
              splashRadius: 24,
              onPressed: (() {
                pathsQueue.add(dirname(pathsQueue.last));
                fileManagerStore.readDir(pathsQueue.last);
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
                            pathsQueue.add(fileManagerStore.elements
                                .elementAt(index)
                                .path);
                            fileManagerStore.readDir(pathsQueue.last);
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditorPage(
                                        fileManagerStore.elements
                                            .elementAt(index)
                                            .path)));
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
