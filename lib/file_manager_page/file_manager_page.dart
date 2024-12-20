import 'dart:io';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

import '../editor_page.dart';

import 'file_manager_store.dart';

class FileManagerPage extends StatefulWidget {
  const FileManagerPage(this.initalPath, {super.key});

  final String initalPath;

  @override
  State<FileManagerPage> createState() => FileManagerPageState();
}

class FileManagerPageState extends State<FileManagerPage> {
  @override
  void initState() {
    super.initState();
    fileManagerStore.pathsQueue.clear();
    fileManagerStore.pathsQueue.add(widget.initalPath);
    fileManagerStore.readDir(fileManagerStore.pathsQueue.last);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (context) => PopScope(
              canPop: !(fileManagerStore.pathsQueue.length > 1),
              onPopInvokedWithResult: (_, __) {
                if (fileManagerStore.pathsQueue.length > 1) {
                  fileManagerStore.pathsQueue.removeLast();
                  fileManagerStore.readDir(fileManagerStore.pathsQueue.last);
                }
              },
              child: Scaffold(
                floatingActionButton:
                    Column(mainAxisSize: MainAxisSize.min, children: [
                  FloatingActionButton(
                      heroTag: 'previous',
                      onPressed: () {
                        if (fileManagerStore.pathsQueue.length > 1) {
                          fileManagerStore.pathsQueue.removeLast();
                          fileManagerStore
                              .readDir(fileManagerStore.pathsQueue.last);
                        }
                      },
                      child: const Icon(Icons.keyboard_arrow_left)),
                  const SizedBox(
                    height: 5,
                  ),
                  FloatingActionButton(
                      heroTag: 'parent',
                      onPressed: (() {
                        fileManagerStore.pathsQueue
                            .add(dirname(fileManagerStore.pathsQueue.last));
                        fileManagerStore
                            .readDir(fileManagerStore.pathsQueue.last);
                      }),
                      child: const Icon(Icons.keyboard_arrow_up)),
                  const SizedBox(
                    height: 5,
                  ),
                  FloatingActionButton(
                      heroTag: 'search',
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => const SearchDialog());
                      },
                      child: const Icon(Icons.search)),
                  const SizedBox(
                    height: 5,
                  ),
                  FloatingActionButton(
                    heroTag: 'sort',
                    onPressed: () {},
                    child: PopupMenuButton(
                        tooltip: '',
                        icon: const Icon(Icons.sort),
                        splashRadius: 28,
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
                                          value:
                                              fileManagerStore.descendingOrder,
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
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: fileManagerStore.sortOrder ==
                                          SortOrder.byName,
                                      onChanged: (value) => fileManagerStore
                                          .setOrder(SortOrder.byName),
                                    );
                                  })),
                              PopupMenuItem(
                                  padding: EdgeInsets.zero,
                                  child: Observer(builder: (context) {
                                    return CheckboxListTile(
                                      title: const Text('按修改时间排序'),
                                      checkboxShape: const CircleBorder(),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: fileManagerStore.sortOrder ==
                                          SortOrder.byModifiedTime,
                                      onChanged: (value) => fileManagerStore
                                          .setOrder(SortOrder.byModifiedTime),
                                    );
                                  })),
                            ]),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FloatingActionButton(
                      heroTag: 'refresh',
                      onPressed: () {
                        fileManagerStore
                            .readDir(fileManagerStore.pathsQueue.last);
                      },
                      child: const Icon(Icons.refresh))
                ]),
                appBar: AppBar(
                    // TODO: 目前能让文本把左边显示成省略号，但是右边直接被截断了，不知道怎么修
                    title: Observer(
                  builder: (context) => Text(
                    fileManagerStore.pathsQueue.last,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                )),
                body: Center(
                    child: Observer(
                        builder: (_) => ListView.builder(
                              itemCount:
                                  fileManagerStore.fileSystemEntities.length,
                              itemBuilder: (context, index) => SizedBox(
                                height: 60,
                                child: ListTile(
                                  onTap: (() {
                                    if (fileManagerStore.fileSystemEntities
                                        .elementAt(index) is Directory) {
                                      fileManagerStore.pathsQueue.add(
                                          fileManagerStore.fileSystemEntities
                                              .elementAt(index)
                                              .path);
                                      fileManagerStore.readDir(
                                          fileManagerStore.pathsQueue.last);
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EditorPage(
                                                  fileManagerStore
                                                      .fileSystemEntities
                                                      .elementAt(index)
                                                      .path)));
                                    }
                                  }),
                                  leading: (fileManagerStore.fileSystemEntities
                                          .elementAt(index) is Directory)
                                      ? const Icon(
                                          Icons.folder,
                                          size: 30,
                                        )
                                      : const Icon(
                                          Icons.audio_file,
                                          size: 30,
                                        ),
                                  title: Text(
                                    basename(fileManagerStore.fileSystemEntities
                                        .elementAt(index)
                                        .path),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(fileManagerStore
                                      .fileSystemEntities
                                      .elementAt(index)
                                      .statSync()
                                      .modified
                                      .toString()),
                                ),
                              ),
                            ))),
              ),
            ));
  }
}

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final _searchController = TextEditingController();

  List<FileSystemEntity> _filtedElements = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('搜索', textScaler: TextScaler.linear(2)),
        content: SizedBox(
          width: 400,
          height: 800,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  List<FileSystemEntity> filtedElements = [];
                  for (final element in fileManagerStore.fileSystemEntities) {
                    if (basename(element.path)
                        .contains(RegExp(value, caseSensitive: false))) {
                      filtedElements.add(element);
                    }
                  }
                  setState(() {
                    _filtedElements = filtedElements;
                  });
                },
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: _filtedElements.length,
                    itemBuilder: (context, index) => SizedBox(
                          height: 60,
                          child: ListTile(
                            onTap: (() {
                              if (_filtedElements.elementAt(index)
                                  is Directory) {
                                Navigator.pop(context);
                                setState(() {
                                  fileManagerStore.pathsQueue.add(
                                      _filtedElements.elementAt(index).path);
                                });
                                fileManagerStore
                                    .readDir(fileManagerStore.pathsQueue.last);
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditorPage(
                                            _filtedElements
                                                .elementAt(index)
                                                .path)));
                              }
                            }),
                            leading:
                                (_filtedElements.elementAt(index) is Directory)
                                    ? const Icon(
                                        Icons.folder,
                                        size: 30,
                                      )
                                    : const Icon(
                                        Icons.audio_file,
                                        size: 30,
                                      ),
                            title: Text(
                              basename(_filtedElements.elementAt(index).path),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(_filtedElements
                                .elementAt(index)
                                .statSync()
                                .modified
                                .toString()),
                          ),
                        )),
              )
            ],
          ),
        ));
  }
}

class FileTile extends StatelessWidget {
  const FileTile(
      {super.key, required List<String> pathsQueue, required int index})
      : _pathsQueue = pathsQueue,
        _index = index;

  final List<String> _pathsQueue;
  final int _index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListTile(
        onTap: (() {
          if (fileManagerStore.fileSystemEntities.elementAt(_index)
              is Directory) {
            _pathsQueue.add(
                fileManagerStore.fileSystemEntities.elementAt(_index).path);
            fileManagerStore.readDir(_pathsQueue.last);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditorPage(fileManagerStore
                        .fileSystemEntities
                        .elementAt(_index)
                        .path)));
          }
        }),
        leading:
            (fileManagerStore.fileSystemEntities.elementAt(_index) is Directory)
                ? const Icon(
                    Icons.folder,
                    size: 30,
                  )
                : const Icon(
                    Icons.audio_file,
                    size: 30,
                  ),
        title: Text(
          basename(fileManagerStore.fileSystemEntities.elementAt(_index).path),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(fileManagerStore.fileSystemEntities
            .elementAt(_index)
            .statSync()
            .modified
            .toString()),
      ),
    );
  }
}
