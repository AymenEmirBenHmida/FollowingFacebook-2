//@dart = 2.9
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';

import 'package:video_player/video_player.dart';

class ChewieDemo extends StatefulWidget {
    String url;
  
  ChewieDemo({this.url});

  
  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<ChewieDemo> {
  
   VideoPlayerController _videoPlayerController1;
   
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController1 = VideoPlayerController.network(
        widget.url);
    
    await Future.wait([
      _videoPlayerController1.initialize(),
     
    ]);
    _createChewieController();
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController?.dispose();
    super.dispose();
  }


   void _createChewieController() {
    // final subtitles = [
    //     Subtitle(
    //       index: 0,
    //       start: Duration.zero,
    //       end: const Duration(seconds: 10),
    //       text: 'Hello from subtitles',
    //     ),
    //     Subtitle(
    //       index: 0,
    //       start: const Duration(seconds: 10),
    //       end: const Duration(seconds: 20),
    //       text: 'Whats up? :)',
    //     ),
    //   ];

    /*final subtitles = [
      Subtitle(
        index: 0,
        start: Duration.zero,
        end: const Duration(seconds: 10),
        text: const TextSpan(children: [
          TextSpan(
            text: 'Hello',
            style: TextStyle(color: Colors.red, fontSize: 22),
          ),
          TextSpan(
            text: ' from ',
            style: TextStyle(color: Colors.green, fontSize: 20),
          ),
          TextSpan(
            text: 'subtitles',
            style: TextStyle(color: Colors.blue, fontSize: 18),
          )
        ]),
      ),
      Subtitle(
          index: 0,
          start: const Duration(seconds: 10),
          end: const Duration(seconds: 20),
          text: 'Whats up? :)'
          // text: const TextSpan(
          //   text: 'Whats up? :)',
          //   style: TextStyle(color: Colors.amber, fontSize: 22, fontStyle: FontStyle.italic),
          // ),
          ),
    ];*/

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: false,
      looping: false,
      autoInitialize: true,
      startAt: const Duration(milliseconds: 170),

      
     /* subtitleBuilder: (context, dynamic subtitle) => Container(
        padding: const EdgeInsets.all(10.0),
        child: subtitle is InlineSpan
            ? RichText(
                text: subtitle,
              )
            : Text(
                subtitle.toString(),
                style: const TextStyle(color: Colors.black),
              ),
      ),*/

      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
       
      // autoInitialize: true,
    );
  }


@override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
            minHeight:
                200, //minimum height
          ),
      child: SizedBox(
      height:  MediaQuery.of(context).size.height*0.36,
      width:  MediaQuery.of(context).size.width*0.7,
      
      child:
             Padding(padding: EdgeInsets.fromLTRB(
             0, 8, 0, 20), child:  Center(
                child: _chewieController != null &&
                        _chewieController
                            .videoPlayerController.value.isInitialized
                    ? Chewie(

                        controller: _chewieController,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text('Loading'),
                        ],
                      ),
              ))))
           ;

}
}