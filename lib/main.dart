import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:music_tools_flutter/file_manager_page/file_manager_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    Permission.manageExternalStorage.status.then((value) {
      if (value == PermissionStatus.granted) {
        setState(() {
          _isPermissionGranted = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Music tools Flutter',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
        home: _isPermissionGranted
            ? const FileManagerPage()
            : Scaffold(
                appBar: AppBar(
                  title: const Text('获取文件访问权限'),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              if (Platform.isAndroid) {
                                requestPermission(context);
                              }
                            },
                            child: const Text(
                              '点击获取本应用所需的权限',
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ),
                  ],
                ),
              ));
  }

  void requestPermission(BuildContext context) {
    Permission.manageExternalStorage.onGrantedCallback(() {
      setState(() {
        _isPermissionGranted = true;
      });
    }).onDeniedCallback(() {
      setState(() {
        _isPermissionGranted = false;
      });
    }).onPermanentlyDeniedCallback(() {
      requestPermissionManually(context).then((value) {
        requestPermission(context);
      });
    }).onRestrictedCallback(() {
      requestPermissionManually(context).then((value) {
        requestPermission(context);
      });
    }).onLimitedCallback(() {
      requestPermissionManually(context).then((value) {
        requestPermission(context);
      });
    }).onProvisionalCallback(() {
      requestPermissionManually(context).then((value) {
        requestPermission(context);
      });
    }).request();
  }

  Future<dynamic> requestPermissionManually(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('获取权限失败'),
            content: const Text('请手动为应用获取文件访问权限'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消')),
              TextButton(
                  onPressed: () {
                    openAppSettings();
                  },
                  child: const Text('确定')),
            ],
          );
        });
  }
}
