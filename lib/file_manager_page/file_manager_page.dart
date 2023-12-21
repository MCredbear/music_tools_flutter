import 'dart:io';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import '../editor_page.dart';

import 'file_manager_store.dart';

class FileManagerPage extends StatefulWidget {
  const FileManagerPage({super.key});

  @override
  State<FileManagerPage> createState() => FileManagerPageState();
}

class FileManagerPageState extends State<FileManagerPage> {
  FileManagerStore fileManagerStore = FileManagerStore();

  List<String> pathsQueue = [];

  @override
  void initState() {
    if (Platform.isAndroid) {
      getExternalStorageDirectories().then((value) {
        pathsQueue
            .add('${value!.first.parent.parent.parent.parent.path}/Music');
        fileManagerStore.readDir(pathsQueue.last);
      });
    } else {
      getApplicationDocumentsDirectory().then((value) {
        pathsQueue.add(value.parent.path);
        fileManagerStore.readDir(pathsQueue.last);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        if (pathsQueue.length > 1) {
          pathsQueue.removeLast();
          fileManagerStore.readDir(pathsQueue.last);
        } else {
          exit(0);
        }
      },
      child: Scaffold(
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
                                  title: const Text('降序'),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  value: fileManagerStore.descendingOrder,
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
                              value: fileManagerStore.sortOrder ==
                                  SortOrder.byName,
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
                onPressed: () {
                  if (pathsQueue.length > 1) {
                    pathsQueue.removeLast();
                    fileManagerStore.readDir(pathsQueue.last);
                  }
                },
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
                            basename(fileManagerStore.elements
                                .elementAt(index)
                                .path),
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
      ),
    );
  }
}
