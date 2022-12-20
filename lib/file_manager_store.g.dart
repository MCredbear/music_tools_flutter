// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_manager_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FileManagerStore on FileManagerStoreBase, Store {
  late final _$elementsAtom = Atom(name: 'FileManagerStoreBase.elements');

  @override
  ObservableList<FileSystemEntity> get elements {
    _$elementsAtom.reportRead();
    return super.elements;
  }

  @override
  set elements(ObservableList<FileSystemEntity> value) {
    _$elementsAtom.reportWrite(value, super.elements, () {
      super.elements = value;
    });
  }

  late final _$sortOrderAtom = Atom(name: 'FileManagerStoreBase.sortOrder');

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

  late final _$reservedAtom = Atom(name: 'FileManagerStoreBase.reserved');

  @override
  bool get reserved {
    _$reservedAtom.reportRead();
    return super.reserved;
  }

  @override
  set reserved(bool value) {
    _$reservedAtom.reportWrite(value, super.reserved, () {
      super.reserved = value;
    });
  }

  late final _$FileManagerStoreBaseActionController =
      ActionController(name: 'FileManagerStoreBase');

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
elements: ${elements},
sortOrder: ${sortOrder},
reserved: ${reserved}
    ''';
  }
}
