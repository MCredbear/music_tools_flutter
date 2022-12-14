import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:music_tools_flutter/search_page.dart';
import 'package:path/path.dart';
import 'package:transparent_image/transparent_image.dart';

import 'taglib/taglib.dart';

class EditorPage extends StatefulWidget {
  const EditorPage(this.path, {super.key});
  final String path;
  @override
  State<EditorPage> createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  late AudioFile audioFile;
  @override
  void initState() {
    audioFile = AudioFile(widget.path);
    audioFile.read().then((value) {
      titleController.text = audioFile.getTitle();
      artistController.text = audioFile.getArtist();
      albumController.text = audioFile.getAlbum();
      albumArtistController.text = audioFile.getAlbumArtist();
      cdController.text = audioFile.getCD();
      trackController.text = audioFile.getTrack();
      yearController.text = audioFile.getYear();
      lyricController.text = audioFile.getLyric();
      commentController.text = audioFile.getComment();
      setState(() {
        cover = audioFile.getCover();
      });
    });
    super.initState();
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController artistController = TextEditingController();
  TextEditingController albumController = TextEditingController();
  TextEditingController albumArtistController = TextEditingController();
  TextEditingController cdController = TextEditingController();
  TextEditingController trackController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController lyricController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  Uint8List cover = Uint8List(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          basename(widget.path),
          maxLines: 2,
          textScaleFactor: 0.8,
        ),
        actions: [
          IconButton(
              splashRadius: 24,
              onPressed: (() {
                audioFile.setTitle(titleController.text);
                audioFile.setAlbum(albumController.text);
                audioFile.setArtist(artistController.text);
                audioFile.setAlbumArtist(albumArtistController.text);
                audioFile.setCD(cdController.text);
                audioFile.setTrack(trackController.text);
                audioFile.setLyric(lyricController.text);
                audioFile.setComment(commentController.text);
                audioFile.save();
              }),
              icon: const Icon(Icons.save)),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.all(0),
                      elevation: 8,
                      child: Image(
                          image: MemoryImage(
                              cover.isNotEmpty ? cover : kTransparentImage),
                          fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    constraints: const BoxConstraints(
                        maxHeight: 250,
                        minHeight: 200,
                        maxWidth: 100,
                        minWidth: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 40,
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CoverSearchPage(
                                          titleController.text)));
                            },
                            color: Colors.blue,
                            child: const Text(
                              '????????????',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: MaterialButton(
                            onPressed: () {},
                            color: Colors.blue,
                            child: const Text(
                              '????????????',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: MaterialButton(
                              onPressed: () {},
                              color: Colors.blue,
                              child: const Text(
                                '????????????',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                        SizedBox(
                          height: 40,
                          child: MaterialButton(
                              onPressed: () {},
                              color: Colors.blue,
                              child: const Text(
                                '????????????',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                '?????????',
                textScaleFactor: 1.4,
              ),
              TextField(
                controller: titleController,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Text(
                '??????',
                textScaleFactor: 1.4,
              ),
              TextField(
                controller: artistController,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Text(
                '??????',
                textScaleFactor: 1.4,
              ),
              TextField(
                controller: albumController,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Text(
                '????????????',
                textScaleFactor: 1.4,
              ),
              TextField(
                controller: albumArtistController,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      '?????????',
                      textScaleFactor: 1.4,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      '??????',
                      textScaleFactor: 1.4,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cdController,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: trackController,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                '??????',
                textScaleFactor: 1.4,
              ),
              TextField(
                controller: yearController,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '??????',
                textScaleFactor: 1.4,
              ),
              TextField(
                controller: lyricController,
                maxLines: null,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Text(
                '??????',
                textScaleFactor: 1.4,
              ),
              TextField(
                controller: commentController,
                maxLines: null,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}
