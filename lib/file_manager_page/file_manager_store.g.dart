// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_manager_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FileManagerStore on FileManagerStoreBase, Store {
  Computed<String>? _$currentPathComputed;

  @override
  String get currentPath =>
      (_$currentPathComputed ??= Computed<String>(() => super.currentPath,
              name: 'FileManagerStoreBase.currentPath'))
          .value;

  late final _$pathsQueueAtom =
      Atom(name: 'FileManagerStoreBase.pathsQueue', context: context);

  @override
  ObservableList<String> get pathsQueue {
    _$pathsQueueAtom.reportRead();
    return super.pathsQueue;
  }

  @override
  set pathsQueue(ObservableList<String> value) {
    _$pathsQueueAtom.reportWrite(value, super.pathsQueue, () {
      super.pathsQueue = value;
    });
  }

  late final _$elementsAtom =
      Atom(name: 'FileManagerStoreBase.elements', context: context);

  @override
  ObservableList<FileSystemEntity> get fileSystemEntities {
    _$elementsAtom.reportRead();
    return super.fileSystemEntities;
  }

  @override
  set fileSystemEntities(ObservableList<FileSystemEntity> value) {
    _$elementsAtom.reportWrite(value, super.fileSystemEntities, () {
      super.fileSystemEntities = value;
    });
  }

  late final _$sortOrderAtom =
      Atom(name: 'FileManagerStoreBase.sortOrder', context: context);

  @override
  SortOrder get sortOrder {
    _$sortOrderAtom.reportRead();
    return super.sortOrder;
  }

  @override
  set sortOrder(SortOrder value) {
    _$sortOrderAtom.reportWrite(value, super.sortOrder, () {
      super.sortOrder = value;
    });
  }

  late final _$descendingOrderAtom =
      Atom(name: 'FileManagerStoreBase.descendingOrder', context: context);

  @override
  bool get descendingOrder {
    _$descendingOrderAtom.reportRead();
    return super.descendingOrder;
  }

  @override
  set descendingOrder(bool value) {
    _$descendingOrderAtom.reportWrite(value, super.descendingOrder, () {
      super.descendingOrder = value;
    });
  }

  late final _$FileManagerStoreBaseActionController =
      ActionController(name: 'FileManagerStoreBase', context: context);

  @override
  void setOrder(SortOrder order) {
    final _$actionInfo = _$FileManagerStoreBaseActionController.startAction(
        name: 'FileManagerStoreBase.setOrder');
    try {
      return super.setOrder(order);
    } finally {
      _$FileManagerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reserve() {
    final _$actionInfo = _$FileManagerStoreBaseActionController.startAction(
        name: 'FileManagerStoreBase.reserve');
    try {
      return super.reserve();
    } finally {
      _$FileManagerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void readDir(String path) {
    final _$actionInfo = _$FileManagerStoreBaseActionController.startAction(
        name: 'FileManagerStoreBase.readDir');
    try {
      return super.readDir(path);
    } finally {
      _$FileManagerStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pathsQueue: ${pathsQueue},
elements: ${fileSystemEntities},
sortOrder: ${sortOrder},
descendingOrder: ${descendingOrder},
currentPath: ${currentPath}
    ''';
  }
}
