//@dart = 2.9
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';
class FBData {
  final String full_picture;
  final String id;
  final String message;
  List<dynamic> listAlbum;
  String type;
  String date;
  String permaL;
  int notification;
  
  
  FBData({this.message, this.full_picture, this.id, this.listAlbum, this.type,this.date, this.permaL, this.notification});

  FBData transform(Map<String, dynamic> json) {
    List<dynamic> listAlbum1 = [];
    List<dynamic> j = [];
    List<FBData> listFinal=[];
    String type;
    String relativeDate = Jiffy(json["created_time"]).fromNow();
    Duration difference = DateTime.now().difference(DateTime.parse(json["created_time"]));
    // print("formatted date ${formatDate(DateTime.parse(json["created_time"]), [  dd,' ',MM, ' at ',hh,':',ss])}");
    var time =DateFormat('yyyy').format(DateTime.parse(json["created_time"]));
    var time2 = DateFormat('yyyy').format(DateTime.now());
    time = time.toString();
    print("transformed time = ${time}");
    Jiffy().local();
    var notificationC = difference.inMinutes;
    var condTime = difference.inHours;
   
     if(condTime>48 && time == time2){

 relativeDate =  formatDate(DateTime.parse(json["created_time"]), [  dd,' ',MM, ' at ',hh,':',ss]);
       
     }else if (condTime>24 && time != time2) {
       relativeDate =  formatDate(DateTime.parse(json["created_time"]), [  yy,' ',dd,' ',MM]);
       
     }
    if (json['attachments'] == null)
      return FBData(
        full_picture: json['full_picture'],
        message: json['message'],
        id: json['id'],
        date: relativeDate,
        permaL: json['permalink_url'],
        notification: notificationC,
      );
    String mess;
    if (json['message'] != null) {
      mess = json['message'];
    } else
      mess = "";
    if (json['attachments'] != null) {
      //if(json['attachments'])
      j = json['attachments']['data'];
      /*j.forEach((element) {
     print(element['type']);
     type = element['type'];
    });*/
     // print(j.first['type']);
      type = j.first['type'];
      

      if (type == "photo") {

       //print("date = ${json["created_time"]}");
  //print("date = ${ Jiffy(json["created_time"]).fromNow()}");
      
        return FBData(
          full_picture: j.first['media']['image']['src'],
          message: mess,
          id: json['id'],
          type: type,
          date: relativeDate,
           permaL: json['permalink_url'],
           notification: notificationC,
        );
      }

      if (type == "video_autoplay") {
        return FBData(
          full_picture: j.first['media']['source'],
          message: mess,
          id: json['id'],
          type: type,
          date: relativeDate,
           permaL: json['permalink_url'],
           notification: notificationC,
        );
      }

      if (type == "video_inline"|| type== "video_direct_response") {
 return FBData(
          full_picture: j.first['media']['source'],
          message: mess,
          id: json['id'],
          type: type,
          date: relativeDate,
           permaL: json['permalink_url'],
           notification: notificationC,
        );
      }

        if (type == "album") {
        listAlbum1=   j.first['subattachments']['data'];
        

        for(var i =0; i<listAlbum1.length;i++){
       //  print("album =  ${listAlbum1.elementAt(i)['type']} ${i}");
         FBData dataA = new FBData(
          full_picture: listAlbum1.elementAt(i)['media']['image']['src'],
          
          
          type: type,
        );
         listFinal.add(dataA) ;
        }
        return FBData(
          listAlbum: listFinal,
          message: mess,
          id: json['id'],
          type: type,
          date: relativeDate,
           permaL: json['permalink_url'],
           notification: notificationC,
        );
      }
     // print(DateTime.now());

      return FBData(
        full_picture: json['picture'],
        message: mess,
        id: json['id'],
        date: relativeDate,
         permaL: json['permalink_url'],
           notification: notificationC,
      );
    }
  }

  
}
