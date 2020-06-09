import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlay extends StatefulWidget {
  @override
  _VideoPlayState createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'iLnmTe5Q2Qw',
    flags: YoutubePlayerFlags(
      autoPlay: false,
      mute: false,
    ),
  );
  List<YoutubePlayerController> controllers = [];
  List<String> videoTitle = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getYougaVideos();
  }

  void getYougaVideos() async {
    await chillRef
        .document('2')
        .collection('youga')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        print('yarab');
//        setState(() {});
        setState(() {
          controllers.add(YoutubePlayerController(
            initialVideoId: f.data['video_id'],
            flags: YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          ));
          videoTitle.add(f.data['video_title']);
        });

        print('${f.data}}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Youga'),
        ),
        body: GridView.count(
          crossAxisCount: 1,
          shrinkWrap: true,
          children: new List<Widget>.generate(controllers.length, (index) {
            return new Column(
              children: <Widget>[
                GridTile(
                  child: FittedBox(
                    child: Card(
                        color: Colors.blue.shade200,
                        child: YoutubePlayer(
                          controller: controllers[index],
                          showVideoProgressIndicator: true,
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    videoTitle[index],
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            );
          }),
        ));
  }
}
