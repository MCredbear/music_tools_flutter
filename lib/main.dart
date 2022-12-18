import 'dart:io';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

import 'editor_page.dart';

import 'file_manager_store.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isAndroid) {
  //   while (true) {
  //     var result = await Permission.storage.request();
  //     if (result.isGranted) break;
  //   }
  // }
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

  late String _path = Platform.isAndroid ? '/sdcard' : '/home/redbear/Music';

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
