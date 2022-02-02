//@dart=2.9
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show Client;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'Models/FBData.dart';
import 'package:flutter/gestures.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'Models/Video.dart';
import 'package:share_plus/share_plus.dart';

import 'Models/test.dart';
import 'aboutUs.dart';

import 'api/notificationApi.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.black,
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.black),
            bodyText2: TextStyle(color: Colors.black),
          )),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FBData> fbdata = [];
  String token;
  Client client = Client();
  FBData fbdata1;
  var id = 0;
  List<int> listOpt = [30, 50, 100];
  int numPosts = 30;
  String key =
      "EAAhw2JKk20sBAM8ZBNgIXWbZBb7QS3u2d3YGQalMnrNTl1fR7d9RyjqF6KzcXnHrhNkRkekfWfIdNgZBiqjn1ZBucZAB9rDjAVAZCrnWVtukr7HG18n79o6XVvXeQDZAXdhsEr1hAWXavAIxsr4V4YqYZChkJ38FnF1qPGBr7KAoeeGLWDBDmoOa";
  String fields =
      "picture,attachments{media_type,url,media,type,subattachments},message,created_time,permalink_url";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFBData();
    fbdata1 = new FBData();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        NotificationService().showNotification(
            notification.hashCode, notification.title, notification.body, 10);
      }
    });
  }

  getToken() async {
    String token = await FirebaseMessaging.instance.getToken();
    setState(() {
      token = token;
    });
    print("token = ${token}");
  }

  sendNotif() async {
  }

  Future fetchFBData() async {
    try {
      var url = Uri.parse(
          "https://graph.facebook.com/v11.0/me?fields=posts.limit(${numPosts}){$fields}&access_token=$key");
      final response = await client.get(url);
      if (response.statusCode == 200) {
        Iterable l = jsonDecode(response.body)['posts']['data'];
        setState(() {
          fbdata = l.map((e) => fbdata1.transform(e)).toList();
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _shareContent({FBData data}) {
    var message = data.message == null ? " " : data.message;
    var ShareM = message + "/n link : ${data.permaL}";
    Share.share(ShareM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Row(children: [
                        Spacer(
                          flex: 1,
                        ),
                        Align(
                            child: SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.759,
                                child: DropdownSearch<int>(
                                  items: listOpt,
                                  mode: Mode.MENU,
                                  maxHeight: 200,
                                  dialogMaxWidth: 100,
                                  // onFind: (String filter) => getData(filter),
                                  label: "number of posts ",
                                  // when what is selected is changed
                                  onChanged: (selectedItem) {
                                    setState(() {
                                      numPosts = selectedItem;
                                      fetchFBData();
                                    });
                                  },
                                ))),
                        SizedBox(
                            width: 70,
                            child: FlatButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AboutUs()),
                                );
                              },
                              icon: Icon(Icons.info_outline_rounded),
                              label: Text(''),
                            )),
                      ]),
                    ])),
                Expanded(
                    child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child:
                      /*ListView.builder(itemCount: fbdata.length,itemBuilder: (context, index){
               return _buildListItem(context, fbdata[index]);*/
                      StreamBuilder(
                    stream: Stream.periodic(Duration(seconds: 5)).asyncMap((i) =>
                        fetchFBData()), // i is null here (check periodic docs)
                    builder: (context, snapshot) => ListView.builder(
                        itemCount: fbdata.length,
                        itemBuilder: (context, index) {
                          return _buildListItem(context, fbdata[index]);
                        }),
                  ),
                ))
              ],
            ),
          )),
    ));
  }

  Widget _buildListItem(BuildContext context, FBData data) {
    var message = data.message == null ? " " : data.message;
    /* if(data.notification<6){
   NotificationService().showNotification(
                data.permaL.hashCode, "title", message, 10);
    }*/

    var full_picture = data.full_picture == null
        ? Text("")
        : Image.network(
            data.full_picture,
            width: 300,
            height: 200,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null,
                ),
              );
            },
          );
    var Rdate = data.date == null
        ? Text(" ")
        : Row(children: [
            Icon(
              Icons.access_time,
              color: Colors.blue,
            ),
            Text(
              " " + data.date,
              style: TextStyle(color: Colors.blue),
            )
          ]);
    var Passage = message == null
        ? SizedBox(height: 0, child: Text(""))
        : TextNormal(message);

    print("data notification  = ${data.notification}");
    /* if(data.notification <= 4){
             number.num=number.num+1;
          NotificationService().showNotification(number.num, "title", message, 10);
    
    }*/
    if (data.type == "video_inline" || data.type == "video_direct_response") {
      return Column(children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: double.infinity,
          ),
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 4,
                    offset: Offset(0, 3))
              ]),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Rdate,
                    ),
                    Spacer(
                      flex: 7,
                    ),
                    SizedBox(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            var message =
                                data.message == null ? " " : data.message;
                            var ShareM = message + "\n link : ${data.permaL}";
                            Share.share(ShareM);
                          },
                          icon: Icon(Icons.share),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    SizedBox(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () async {
                          if (await canLaunch(data.permaL)) {
                            await launch(
                              data.permaL,
                            );
                          } else {
                            throw 'Could not launch ${data.permaL}';
                          }
                        },
                        icon: Icon(Icons.facebook),
                      ),
                    )
                  ],
                ),
                Divider(
                  height: 10,
                  endIndent: MediaQuery.of(context).size.width * 0.65,
                  color: Colors.blueGrey,
                ),
                if (Passage != Text("")) Passage,
                Divider(
                  height: 20,
                ),
                ChewieDemo(url: data.full_picture),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        )
      ]);
    }

    if (data.type == "video_autoplay") {
      return Column(children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: double.infinity,
          ),
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 4,
                    offset: Offset(0, 3))
              ]),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Rdate,
                    ),
                    Spacer(
                      flex: 7,
                    ),
                    SizedBox(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            var message =
                                data.message == null ? " " : data.message;
                            var ShareM = message + "\n link : ${data.permaL}";
                            Share.share(ShareM);
                          },
                          icon: Icon(Icons.share),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    SizedBox(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () async {
                          if (await canLaunch(data.permaL)) {
                            await launch(
                              data.permaL,
                            );
                          } else {
                            throw 'Could not launch ${data.permaL}';
                          }
                        },
                        icon: Icon(Icons.facebook),
                      ),
                    )
                  ],
                ),
                if (Passage != Text(""))
                  Divider(
                    height: 10,
                    endIndent: MediaQuery.of(context).size.width * 0.65,
                    color: Colors.blueGrey,
                  ),
                Passage,
                ChewieDemo(url: data.full_picture),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        )
      ]);
    }

    if (data.type == "album") {
      return Column(children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: double.infinity,
          ),
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 4,
                    offset: Offset(0, 3))
              ]),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Rdate,
                    ),
                    Spacer(
                      flex: 7,
                    ),
                    SizedBox(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            var message =
                                data.message == null ? " " : data.message;
                            var ShareM = message + "\n link : ${data.permaL}";
                            Share.share(ShareM);
                          },
                          icon: Icon(Icons.share),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    SizedBox(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () async {
                          if (await canLaunch(data.permaL)) {
                            await launch(
                              data.permaL,
                            );
                          } else {
                            throw 'Could not launch ${data.permaL}';
                          }
                        },
                        icon: Icon(Icons.facebook),
                      ),
                    )
                  ],
                ),
                Divider(
                  height: 10,
                  endIndent: MediaQuery.of(context).size.width * 0.65,
                  color: Colors.blueGrey,
                ),
                Passage,
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 0, 0),
                    child: Row(children: [
                      Icon(Icons.burst_mode),
                      Text(" " + data.listAlbum.length.toString() + ' images'),
                    ]),
                  ),
                ),
                Divider(
                  height: 10,
                  endIndent: MediaQuery.of(context).size.width * 0.65,
                  color: Colors.blueGrey,
                  indent: 20,
                ),
                SizedBox(
                  height: 5,
                ),
                CarouselSlider(
                  items: data.listAlbum
                      .map((e) => InteractiveViewer(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              HeroPhotoViewRouteWrapper(
                                            imageProvider:
                                                NetworkImage(e.full_picture),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Image.network(
                                      e.full_picture,
                                      width: 200,
                                      height: 600,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ))))
                      .toList(),
                  options: CarouselOptions(
                    aspectRatio: 2.0,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,

                    // autoPlay: true,
                  ),
                ),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        )
      ]);
    }
    if (data.type == "photo") {
      return Column(children: [
        Container(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height * 0.3, //minimum height
          ),
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 4,
                    offset: Offset(0, 3))
              ]),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Rdate,
                    ),
                    Spacer(
                      flex: 7,
                    ),
                    SizedBox(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            var message =
                                data.message == null ? " " : data.message;
                            var ShareM = message + "\n link : ${data.permaL}";
                            Share.share(ShareM);
                          },
                          icon: Icon(Icons.share),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    SizedBox(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () async {
                          if (await canLaunch(data.permaL)) {
                            await launch(
                              data.permaL,
                            );
                          } else {
                            throw 'Could not launch ${data.permaL}';
                          }
                        },
                        icon: Icon(Icons.facebook),
                      ),
                    )
                  ],
                ),
                Divider(
                  height: 10,
                  endIndent: MediaQuery.of(context).size.width * 0.65,
                  color: Colors.blueGrey,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Passage,
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HeroPhotoViewRouteWrapper(
                            imageProvider: NetworkImage(data.full_picture),
                          ),
                        ),
                      );
                    },
                    child: full_picture),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        )
      ]);
    }

    return Column(children: [
      Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.3, //minimum height
        ),
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 4,
                  offset: Offset(0, 3))
            ]),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Rdate,
                  ),
                  Spacer(
                    flex: 7,
                  ),
                  SizedBox(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () {
                          var message =
                              data.message == null ? " " : data.message;
                          var ShareM = message + "\n link : ${data.permaL}";
                          Share.share(ShareM);
                        },
                        icon: Icon(Icons.share),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () async {
                        if (await canLaunch(data.permaL)) {
                          await launch(
                            data.permaL,
                          );
                        } else {
                          throw 'Could not launch ${data.permaL}';
                        }
                      },
                      icon: Icon(Icons.facebook),
                    ),
                  )
                ],
              ),
              Divider(
                height: 10,
                endIndent: MediaQuery.of(context).size.width * 0.65,
                color: Colors.blueGrey,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Passage,
              ),
              SizedBox(
                height: 20,
              ),
              full_picture,
            ],
          ),
        ),
      ),
      SizedBox(
        height: 30,
      )
    ]);
  }
}

class ExpandableText extends StatefulWidget {
  const ExpandableText(
    this.text, {
    Key key,
    this.trimLines = 2,
  })  : assert(text != null),
        super(key: key);

  final String text;
  final int trimLines;

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  bool _readMore = true;
  void _onTapLink() {
    setState(() => _readMore = !_readMore);
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    final colorClickableText = Colors.blue;
    final widgetColor = Colors.black;
    TextSpan link = TextSpan(
        text: _readMore ? "... read more" : " read less",
        style: TextStyle(
          color: colorClickableText,
        ),
        recognizer: TapGestureRecognizer()..onTap = _onTapLink);
    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;
        // Create a TextSpan with data
        final text =
            TextSpan(text: widget.text, style: TextStyle(color: Colors.black));
        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,

          textDirection: TextDirection
              .rtl, //better to pass this from master widget if ltr and rtl both supported
          maxLines: widget.trimLines,
          ellipsis: '...',
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;
        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;
        // Get the endIndex of data
        int endIndex;
        final pos = textPainter.getPositionForOffset(Offset(
          textSize.width - linkSize.width,
          textSize.height,
        ));
        endIndex = textPainter.getOffsetBefore(pos.offset);
        var textSpan;
        if (textPainter.didExceedMaxLines) {
          textSpan = TextSpan(
            text: _readMore ? widget.text.substring(0, endIndex) : widget.text,
            style: TextStyle(
              color: widgetColor,
            ),
            children: <TextSpan>[link],
          );
        } else {
          textSpan = TextSpan(
            style: TextStyle(color: Colors.black),
            text: widget.text,
          );
        }
        return RichText(
          softWrap: true,
          overflow: TextOverflow.clip,
          text: textSpan,
        );
      },
    );
    return result;
  }
}

class TextNormal extends StatefulWidget {
  const TextNormal(
    this.text, {
    Key key,
  })  : assert(text != null),
        super(key: key);

  final String text;

  @override
  TextNormalState createState() => TextNormalState();
}

class TextNormalState extends State<TextNormal> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      final span =
          TextSpan(text: widget.text, style: TextStyle(color: Colors.black));
      final tp = TextPainter(
          textDirection: TextDirection.rtl, text: span, maxLines: 1);
      tp.layout(maxWidth: size.maxWidth);

      if (tp.didExceedMaxLines) {
        // The text has more than three lines.
        // TODO: display the prompt message
        return ExpandableText(
          widget.text,
          trimLines: 2,
        );
      } else {
        return Text(widget.text, style: TextStyle(color: Colors.black));
      }
    });
  }
}
