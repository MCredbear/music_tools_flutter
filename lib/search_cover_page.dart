import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class CoverSearchPage extends StatefulWidget {
  const CoverSearchPage(this.keyword, {super.key});

  final String keyword;

  @override
  State<CoverSearchPage> createState() => _CoverSearchPageState();
}

class _CoverSearchPageState extends State<CoverSearchPage> {
  late TextEditingController _keywordController;

  final ScrollController _scrollController = ScrollController();

  final List<Widget> _coverCards = [];

  bool _isLoading = true;
  bool _noMoreSong = false;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController(text: widget.keyword);
    search(_keywordController.text, _offset).then((value) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _offset += 1;
          search(_keywordController.text, _offset);
        }
      });
    });
  }

  Future<void> search(String keyword, int offset) async {
    try {
      final httpClient = HttpClient();
      final httpRequest = await httpClient.get('music.163.com', 80,
          '/api/cloudsearch/pc?s=${Uri.encodeFull(keyword.substring(1))}&type=1&limit=10&offset=$offset&total=true');
      final response = await httpRequest.close();
      httpClient.close();
      final dataStream = response.transform(utf8.decoder);
      var jsonData = '';
      await for (final data in dataStream) {
        jsonData += data;
      }
      httpClient.close();
      final json = jsonDecode(jsonData);
      final int songCount = json['result']['songCount'];
      if (songCount == 0) {
        setState(() {
          if (offset == 0) _coverCards.clear();
          _noMoreSong = true;
        });
        return;
      } else {
        setState(() {
          _noMoreSong = false;
        });
      }
      final songs = json['result']['songs'];
      final newCovers = <Widget>[];
      for (final song in songs) {
        String? imageUrl = song['al']['picUrl'];
        if (imageUrl != null) {
          imageUrl = imageUrl.replaceFirst('http:', 'https:');
          newCovers.add(ImageCard(imageUrl, song['name'] ?? '',
              song['ar'][0]['name'] ?? '', song['al']['name'] ?? ''));
        }
      }
      setState(() {
        if (offset == 0) _coverCards.clear();
        _coverCards.addAll(newCovers);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showToast('获取失败，请检查您的网络');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            onSubmitted: (keyword) {
              _offset = 0;
              search(keyword, _offset);
            },
            controller: _keywordController,
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
                  _offset = 0;
                  search(_keywordController.text, _offset);
                },
                icon: const Icon(Icons.search))
          ],
        ),
        body: ListView(
          controller: _scrollController,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              children: _coverCards,
            ),
            Padding(
                padding: const EdgeInsets.all(5),
                child: _noMoreSong
                    ? const SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '没有更多封面',
                              style: TextStyle(fontSize: 18),
                            )
                          ],
                        ),
                      )
                    : (_isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                _isLoading = true;
                              });
                              search(_keywordController.text, _offset);
                            },
                            child: const SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '加载失败，点击重试',
                                    style: TextStyle(fontSize: 18),
                                  )
                                ],
                              ),
                            ))))
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
              if (!context.mounted) return;
              Navigator.pop(context, Uint8List.fromList(data));
            } catch (e) {
              showToast('封面下载失败，请检查您的网络');
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
