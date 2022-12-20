import 'dart:io';
import 'package:path/path.dart';
import 'package:mobx/mobx.dart';

part 'file_manager_store.g.dart';

enum SortOrder { byName, byModifiedTime }

class FileManagerStore = FileManagerStoreBase with _$FileManagerStore;

abstract class FileManagerStoreBase with Store {
  @observable
  ObservableList<FileSystemEntity> elements = ObservableList();

  @observable
  SortOrder sortOrder = SortOrder.byModifiedTime;

  @action
  void setOrder(SortOrder order) {
    sortOrder = order;
    switch (sortOrder) {
      case SortOrder.byName:
        sortByName();
        break;
      case SortOrder.byModifiedTime:
        sortByModifiedTime();
        break;
      default:
    }
  }

  @observable
  bool reserved = true;

  @action
  void reserve() {
    reserved = !reserved;
    switch (sortOrder) {
      case SortOrder.byName:
        sortByName();
        break;
      case SortOrder.byModifiedTime:
        sortByModifiedTime();
        break;
      default:
    }
  }

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
    switch (sortOrder) {
      case SortOrder.byName:
        sortByName();
        break;
      case SortOrder.byModifiedTime:
        sortByModifiedTime();
        break;
      default:
    }
  }

  void sortByName() {
    ObservableList<FileSystemEntity> dirs = ObservableList();
    ObservableList<FileSystemEntity> files = ObservableList();
    for (var element in elements) {
      if (element is Directory) {
        dirs.add(element);
      } else {
        files.add(element);
      }
    }
    if (reserved) {
      dirs.sort((element1, element2) =>
          basename(element1.path).compareTo(basename(element2.path)));
      files.sort((element1, element2) =>
          basename(element1.path).compareTo(basename(element2.path)));
    } else {
      dirs.sort((element2, element1) =>
          basename(element1.path).compareTo(basename(element2.path)));
      files.sort((element2, element1) =>
          basename(element1.path).compareTo(basename(element2.path)));
    }
    elements = dirs;
    elements.addAll(files);
  }

  void sortByModifiedTime() {
    ObservableList<FileSystemEntity> dirs = ObservableList();
    ObservableList<FileSystemEntity> files = ObservableList();
    for (var element in elements) {
      if (element is Directory) {
        dirs.add(element);
      } else {
        files.add(element);
      }
    }
    if (reserved) {
      dirs.sort((element1, element2) =>
          element1.statSync().modified.compareTo(element2.statSync().modified));
      files.sort((element1, element2) =>
          element1.statSync().modified.compareTo(element2.statSync().modified));
    } else {
      dirs.sort((element2, element1) =>
          element1.statSync().modified.compareTo(element2.statSync().modified));
      files.sort((element2, element1) =>
          element1.statSync().modified.compareTo(element2.statSync().modified));
    }
    elements = dirs;
    elements.addAll(files);
  }
}
