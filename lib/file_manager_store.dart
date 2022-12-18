import 'dart:io';
import 'package:path/path.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';

part 'file_manager_store.g.dart';

class FileManagerStore = FileManagerStoreBase with _$FileManagerStore;

abstract class FileManagerStoreBase with Store {
  @observable
  ObservableList<FileSystemEntity> elements = ObservableList();

  @action
  void readDir(String path) {
    Directory dir = Directory(path);
    elements.clear();
    dir.listSync().forEach((element) {
      if (element is Directory) {
        elements.add(element);
      } else {
        String format = extension(element.path);
        if ((format.lastIndexOf(RegExp('mp3', caseSensitive: false)) != -1) |
            (format.lastIndexOf(RegExp('flac', caseSensitive: false)) != -1) |
            (format.lastIndexOf(RegExp('wav', caseSensitive: false)) != -1)) {
          elements.add(element);
        }
      }
    });
  }
}
