import 'dart:io';
import 'package:path/path.dart'
    as p; // 'Context' in 'path' duplicated 'ReactiveContext' in 'mobx'
import 'package:mobx/mobx.dart';

part 'file_manager_store.g.dart';

enum SortOrder { byName, byModifiedTime }

class FileManagerStore = FileManagerStoreBase with _$FileManagerStore;

abstract class FileManagerStoreBase with Store {
  @observable
  ObservableList<String> pathsQueue = ObservableList();

  @computed
  String get currentPath => pathsQueue.isEmpty ? '' : pathsQueue.last;

  @observable
  ObservableList<FileSystemEntity> fileSystemEntities = ObservableList();

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
    }
  }

  @observable
  bool descendingOrder = true;

  @action
  void reserve() {
    descendingOrder = !descendingOrder;
    switch (sortOrder) {
      case SortOrder.byName:
        sortByName();
        break;
      case SortOrder.byModifiedTime:
        sortByModifiedTime();
        break;
    }
  }

  @action
  void readDir(String path) {
    Directory dir = Directory(path);
    fileSystemEntities.clear();
    dir.listSync().forEach((element) {
      if (element is Directory) {
        fileSystemEntities.add(element);
      } else {
        String format = p.extension(element.path);
        if ((format.toLowerCase() == '.mp3') |
            (format.toLowerCase() == '.flac') |
            (format.toLowerCase() == '.wav')) {
          fileSystemEntities.add(element);
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
    }
  }

  // @action
  // void search(String keyword){
  //   ObservableList<FileSystemEntity> newElements = ObservableList();
  //   for (final element in elements){
  //     if (basename(element.path).contains(RegExp(keyword,caseSensitive: false))) newElements.add(element);
  //   }
  //   elements = newElements;
  // }

  void sortByName() {
    ObservableList<FileSystemEntity> dirs = ObservableList();
    ObservableList<FileSystemEntity> files = ObservableList();
    for (var element in fileSystemEntities) {
      if (element is Directory) {
        dirs.add(element);
      } else {
        files.add(element);
      }
    }
    if (!descendingOrder) {
      dirs.sort((element1, element2) =>
          p.basename(element1.path).compareTo(p.basename(element2.path)));
      files.sort((element1, element2) =>
          p.basename(element1.path).compareTo(p.basename(element2.path)));
    } else {
      dirs.sort((element2, element1) =>
          p.basename(element1.path).compareTo(p.basename(element2.path)));
      files.sort((element2, element1) =>
          p.basename(element1.path).compareTo(p.basename(element2.path)));
    }
    fileSystemEntities = dirs;
    fileSystemEntities.addAll(files);
  }

  void sortByModifiedTime() {
    ObservableList<FileSystemEntity> dirs = ObservableList();
    ObservableList<FileSystemEntity> files = ObservableList();
    for (var element in fileSystemEntities) {
      if (element is Directory) {
        dirs.add(element);
      } else {
        files.add(element);
      }
    }
    if (!descendingOrder) {
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
    fileSystemEntities = dirs;
    fileSystemEntities.addAll(files);
  }
}

final FileManagerStore fileManagerStore = FileManagerStore();
