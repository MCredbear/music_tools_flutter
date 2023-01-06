import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CoverSearchPage extends StatefulWidget {
  const CoverSearchPage(this.keyword, {super.key});

  final String keyword;

  @override
  State<CoverSearchPage> createState() => _CoverSearchPageState();
}

class _CoverSearchPageState extends State<CoverSearchPage> {
  late TextEditingController keywordController;

  @override
  void initState() {
    keywordController = TextEditingController(text: widget.keyword);
    search(keywordController.text);
    super.initState();
  }

  Future<void> search(String keyword) async {
    try {
      var httpClient = HttpClient();
      var httpRequest = await httpClient.get('music.163.com', 80,
          '/api/cloudsearch/pc?s=${Uri.encodeFull(keyword.substring(1))}&type=1&limit=10&offset=$offset&total=true');
      var response = await httpRequest.close();
      httpClient.close();
      var dataStream = response.transform(utf8.decoder);
      var data = '';
      await for (var data_ in dataStream) {
        data += data_;
      }
      httpClient.close();
      var json = jsonDecode(data);
      var songs = json['result']['songs'];
      var covers_ = <Widget>[];
      for (var song in songs) {
        covers_.add(ImageCard(song['al']['picUrl'] ?? '', song['name'] ?? '',
            song['ar'][0]['name'] ?? '', song['al']['name'] ?? ''));
      }
      setState(() {
        covers = covers_;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: '获取失败，请检查您的网络');
    }
  }

  List<Widget> covers = [];

  int offset = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            onSubmitted: (value) {
              search(value);
            },
            controller: keywordController,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            cursorColor: Colors.white,
            decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black38)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white))),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  search(keywordController.text);
                },
                icon: const Icon(Icons.search))
          ],
        ),
        body: ListView(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              children: covers,
            ),
          ],
        ));
  }
}

class ImageCard extends StatelessWidget {
  const ImageCard(
    this.imageUrl,
    this.song,
    this.artist,
    this.album, {
    super.key,
  });

  final String imageUrl;
  final String song;
  final String artist;
  final String album;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 350),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.audiotrack,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(song, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.mic,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(artist, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.audiotrack,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(album, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
