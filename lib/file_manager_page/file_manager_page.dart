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
  final List<String> _pathsQueue = [];

  @override
  void initState() {
    if (Platform.isAndroid) {
      getExternalStorageDirectories().then((value) {
        _pathsQueue
            .add('${value!.first.parent.parent.parent.parent.path}/Music');
        fileManagerStore.readDir(_pathsQueue.last);
      });
    } else {
      getApplicationDocumentsDirectory().then((value) {
        _pathsQueue.add(value.parent.path);
        fileManagerStore.readDir(_pathsQueue.last);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        if (_pathsQueue.length > 1) {
          _pathsQueue.removeLast();
          fileManagerStore.readDir(_pathsQueue.last);
        } else {
          exit(0);
        }
      },
      child: Scaffold(
        floatingActionButton: Column(mainAxisSize: MainAxisSize.min, children: [
          FloatingActionButton(
              onPressed: () {
                if (_pathsQueue.length > 1) {
                  _pathsQueue.removeLast();
                  fileManagerStore.readDir(_pathsQueue.last);
                }
              },
              child: const Icon(Icons.keyboard_arrow_left)),
          const SizedBox(
            height: 5,
          ),
          FloatingActionButton(
              onPressed: (() {
                _pathsQueue.add(dirname(_pathsQueue.last));
                fileManagerStore.readDir(_pathsQueue.last);
              }),
              child: const Icon(Icons.keyboard_arrow_up)),
          const SizedBox(
            height: 5,
          ),
          FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SearchDialog(
                        pathsQueue: _pathsQueue,
                      );
                    });
              },
              child: const Icon(Icons.search)),
          const SizedBox(
            height: 5,
          ),
          FloatingActionButton(
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
          ),
          const SizedBox(
            height: 5,
          ),
          FloatingActionButton(
              onPressed: () {
                fileManagerStore.readDir(_pathsQueue.last);
              },
              child: const Icon(Icons.refresh))
        ]),
        appBar: AppBar(
          title: const Text("Music tools Flutter"),
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
                              _pathsQueue.add(fileManagerStore.elements
                                  .elementAt(index)
                                  .path);
                              fileManagerStore.readDir(_pathsQueue.last);
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

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key, required List<String> pathsQueue})
      : _pathsQueue = pathsQueue;

  final List<String> _pathsQueue;

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
                  for (final element in fileManagerStore.elements) {
                    if (basename(element.path).contains(
                        RegExp(value, caseSensitive: false))) {
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
                                widget._pathsQueue
                                    .add(_filtedElements.elementAt(index).path);
                                fileManagerStore
                                    .readDir(widget._pathsQueue.last);
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
          if (fileManagerStore.elements.elementAt(_index) is Directory) {
            _pathsQueue.add(fileManagerStore.elements.elementAt(_index).path);
            fileManagerStore.readDir(_pathsQueue.last);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditorPage(
                        fileManagerStore.elements.elementAt(_index).path)));
          }
        }),
        leading: (fileManagerStore.elements.elementAt(_index) is Directory)
            ? const Icon(
                Icons.folder,
                size: 30,
              )
            : const Icon(
                Icons.audio_file,
                size: 30,
              ),
        title: Text(
          basename(fileManagerStore.elements.elementAt(_index).path),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(fileManagerStore.elements
            .elementAt(_index)
            .statSync()
            .modified
            .toString()),
      ),
    );
  }
}
