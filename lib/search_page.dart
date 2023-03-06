import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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

  final ScrollController scrollController = ScrollController();

  List<Widget> covers = [];

  bool isLoading = true;
  int offset = 0;
  late String _keyword;

  @override
  void initState() {
    keywordController = TextEditingController(text: widget.keyword);
    firstSearch(keywordController.text).then((value) {
      scrollController.addListener(() {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          nextSearch();
        }
      });
    });

    super.initState();
  }

  Future<void> firstSearch(String keyword) async {
    try {
      _keyword = keyword;
      offset = 0;
      var httpClient = HttpClient();
      var httpRequest = await httpClient.get('music.163.com', 80,
          '/api/cloudsearch/pc?s=${Uri.encodeFull(_keyword.substring(1))}&type=1&limit=10&offset=$offset&total=true');
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
      offset++;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: '获取失败，请检查您的网络');
    }
  }

  Future<void> nextSearch() async {
    try {
      var httpClient = HttpClient();
      var httpRequest = await httpClient.get('music.163.com', 80,
          '/api/cloudsearch/pc?s=${Uri.encodeFull(_keyword.substring(1))}&type=1&limit=10&offset=$offset&total=true');
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
        covers += covers_;
      });
      offset++;
    } catch (e) {
      offset--;
      setState(() {
        isLoading = false;
        covers = [];
      });
      Fluttertoast.showToast(msg: '获取失败，请检查您的网络');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            onSubmitted: (value) {
              firstSearch(value);
            },
            controller: keywordController,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            cursorColor: Colors.white,
            decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white))),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  firstSearch(keywordController.text);
                },
                icon: const Icon(Icons.search))
          ],
        ),
        body: ListView(
          controller: scrollController,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              children: covers,
            ),
            Padding(
                padding: const EdgeInsets.all(5),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                            Text(
                              '加载中',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 10, height: 50),
                            CircularProgressIndicator()
                          ])
                    : InkWell(
                        splashFactory: NoSplash.splashFactory,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            isLoading = true;
                          });
                          nextSearch();
                        },
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                '加载失败，点击重试',
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                        )))
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
        child: InkWell(
          onTap: () async {
            try {
              var httpClient = HttpClient();
              var httpRequest = await httpClient.getUrl(Uri.parse(imageUrl));
              var response = await httpRequest.close();
              httpClient.close();
              List<int> data = [];
              await for (var data_ in response) {
                data.addAll(data_);
              }
              Navigator.pop(context, Uint8List.fromList(data));
            } catch (e) {
              Fluttertoast.showToast(msg: '封面下载失败，请检查您的网络');
            }
          },
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
                            child:
                                Text(artist, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.album,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                            child:
                                Text(album, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
