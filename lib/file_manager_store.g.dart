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

  late final _$FileManagerStoreBaseActionController =
      ActionController(name: 'FileManagerStoreBase');

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
elements: ${elements}
    ''';
  }
}
