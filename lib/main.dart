import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:music_tools_flutter/file_manager_page/file_manager_page.dart';
import 'package:permission_handler/permission_handler.dart';

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
        if (context.mounted) requestPermission(context);
      });
    }).onRestrictedCallback(() {
      requestPermissionManually(context).then((value) {
        if (context.mounted) requestPermission(context);
      });
    }).onLimitedCallback(() {
      requestPermissionManually(context).then((value) {
        if (context.mounted) requestPermission(context);
      });
    }).onProvisionalCallback(() {
      requestPermissionManually(context).then((value) {
        if (context.mounted) requestPermission(context);
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

  @override
  Widget build(BuildContext context) {
    return StyledToast(
      locale: const Locale('zh', 'CN'),
      child: MaterialApp(
        title: 'Music tools Flutter',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
        home: _isPermissionGranted
            ? const PickPage()
            : Center(
                child: ElevatedButton(
                    onPressed: () {
                      if (Platform.isAndroid) {
                        requestPermission(context);
                      }
                    },
                    child: const Text(
                      '点击获取本应用所需的权限',
                      textAlign: TextAlign.center,
                    )),
              ),
      ),
    );
  }
}

class PickPage extends StatelessWidget {
  const PickPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music tools Flutter'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              final result = await FilePicker.platform.getDirectoryPath();

              if (result != null) {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileManagerPage(result),
                    ),
                  );
                }
              }
            },
            child: const Text('选择音频文件夹')),
      ),
    );
  }
}
