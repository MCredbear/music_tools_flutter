import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class LyricSearchPage extends StatefulWidget {
  const LyricSearchPage(this.keyword, {super.key});

  final String keyword;

  @override
  State<LyricSearchPage> createState() => _LyricSearchPageState();
}

class _LyricSearchPageState extends State<LyricSearchPage> {
  late TextEditingController _keywordController;

  final ScrollController scrollController = ScrollController();

  final List<Widget> _lyricCards = [];

  bool _isLoading = true;
  bool _noMoreSong = false;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController(text: widget.keyword);
    search(_keywordController.text, _offset).then((value) {
      scrollController.addListener(() {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          _offset += 1;
          search(_keywordController.text, _offset);
        }
      });
    });
  }

  Future<void> search(String keyword, int offset) async {
    try {
      final response = await http.get(Uri.parse(
          'https://music.redbear.moe/api/cloudsearch/pc?s=${Uri.encodeFull(keyword.substring(1))}&type=1&limit=10&offset=$offset&total=true'));
      final json = jsonDecode(response.body);
      final songCount = json['result']['songCount'];
      if (songCount == 0) {
        setState(() {
          if (offset == 0) _lyricCards.clear();
          _noMoreSong = true;
        });
        return;
      } else {
        setState(() {
          _noMoreSong = false;
        });
      }
      final songs = json['result']['songs'];
      final List<Widget> newLyricCards = [];
      for (final song in songs) {
        final int id = song['id'];
        final String name = song['name'];
        final String artist = song['ar'][0]['name'];
        final String album = song['al']['name'];
        try {
          final response = await http.get(Uri.parse(
              'https://music.redbear.moe/api/song/lyric?_nmclfl=1&id=$id&tv=-1&lv=-1&rv=-1&kv=-1'));
          final json = jsonDecode(response.body);
          final bool? isPureMusic = json['pureMusic'];
          if (isPureMusic != true) {
            final String originalLyric = json['lrc']?['lyric'] ?? '';
            final String translatedLyric = json['tlyric']?['lyric'] ?? '';
            final String romanicLyric = json['romalrc']?['lyric'] ?? '';
            final String lyric =
                '$originalLyric${translatedLyric.isNotEmpty ? '\n$translatedLyric' : ''}${romanicLyric.isNotEmpty ? '\n$romanicLyric' : ''}';
            newLyricCards.add(LyricCard(name, artist, album, lyric));
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          showToast('获取失败，请检查您的网络');
        }
      }
      setState(() {
        if (offset == 0) _lyricCards.clear();
        _lyricCards.addAll(newLyricCards);
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
          controller: scrollController,
          children: [
            Column(
              children: _lyricCards,
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
                              '没有更多歌词',
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

class LyricCard extends StatefulWidget {
  const LyricCard(
    this.song,
    this.artist,
    this.album,
    this.lyric, {
    super.key,
  });

  final String song;
  final String artist;
  final String album;
  final String lyric;

  @override
  State<LyricCard> createState() => _LyricCardState();
}

class _LyricCardState extends State<LyricCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: expanded ? null : const BoxConstraints(maxHeight: 350),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(
                          Icons.audiotrack,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.song,
                            softWrap: true,
                            maxLines: null,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.mic,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.artist,
                            softWrap: true,
                            maxLines: null,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.album,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.album,
                            softWrap: true,
                            maxLines: null,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.lyric,
                      softWrap: true,
                    )
                  ],
                ),
                Positioned(
                    top: 10,
                    right: 10,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.pop(context, widget.lyric);
                      },
                      child: const Icon(Icons.arrow_forward),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
