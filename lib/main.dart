//@dart=2.9
import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:following_news/Signup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'Models/FBData.dart';
import 'api/notificationApi.dart';
import 'app.dart';
import 'package:http/http.dart' show Client;


import 'authentication/authentication_service.dart';
import 'login.dart';

String graphApi = "https://graph.facebook.com/v11.0/me?fields=posts.limit(20){picture,attachments{media_type,url,media,type,subattachments},message,created_time,permalink_url}&access_token=EAAhw2JKk20sBAM8ZBNgIXWbZBb7QS3u2d3YGQalMnrNTl1fR7d9RyjqF6KzcXnHrhNkRkekfWfIdNgZBiqjn1ZBucZAB9rDjAVAZCrnWVtukr7HG18n79o6XVvXeQDZAXdhsEr1hAWXavAIxsr4V4YqYZChkJ38FnF1qPGBr7KAoeeGLWDBDmoOa";


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  print(message.data);
  print(message.notification);

  // NotificationService().showNotification(
  //   message.data.hashCode, message.data['title'],message.data['body'], 10);
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
   

    
    final result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.none) {
      

      SharedPreferences _preference = await SharedPreferences.getInstance();
      String dateC;
      int tim = 16;
      Duration difference;
      print("entered online");

      
        if (_preference.getString("offline-state") == null) {
          _preference.setString("offline-state", "notdone");
           _preference.setString("online", "1");
          var c = DateTime.now().toString();
          await _preference.setString("date_online", c);
          print("enetred _preference.getString(offline-state) == null $c");
        } 
        if (_preference.getString("offline-state") =="done" ) {
          dateC = _preference.getString("date");
          difference = DateTime.now().difference(DateTime.parse(dateC));
          tim = difference.inMinutes;
          print("enetred _preference.getString(offline-state) ==done $tim");
        }
      if (_preference.getString("offline-state") =="notdone"&&_preference.getString("online")=="2" ) {
         dateC = await _preference.getString("date_online");
          difference = DateTime.now().difference(DateTime.parse(dateC));
        tim = difference.inMinutes;
          var c = DateTime.now().toString();
          await _preference.setString("date_online", c);
          print("enetred _preference.getString(offline-state) ==notdone&&_preference.getString(online)==2 $c");
 

      }
    //at the end it registers not done so it doesnt use the wrong setup of time
  print("enetred tim =  $tim");
      List<FBData> fbdata = [];
      Client client = Client();
      FBData fbdata1 = new FBData();
      var url = Uri.parse(
          graphApi);

      try {
        final response = await client.get(url);
        if (response.statusCode == 200) {
          Iterable l = jsonDecode(response.body)['posts']['data'];

          fbdata = l.map((e) => fbdata1.transform(e)).toList();
        }
        fbdata.forEach((element) async {
          var message = element.message == null ? " " : element.message;
          print("notification date ${element.notification}");
          if (element.notification <= tim) {
            NotificationService()
                .showNotification(element.id.hashCode, "title", message, 10);
            await Future.delayed(const Duration(milliseconds: 60), () {});
          }
        });
         _preference.setString("offline-state", "notdone");
          _preference.setString("online", "2");
      } catch (e) {
        print(e.toString());
      }
      
    } else {
      SharedPreferences _preference = await SharedPreferences.getInstance();

      String c;
      print("enetred offline");
      if (await _preference.getString("date") == null) {
        c = DateTime.now().toString();
        await _preference.setString("offline-state", "done");
        await _preference.setString("date", c);
        print("enetred 1 $c");
      } else {
        if (_preference.getString("offline-state") == "notdone") {
          c = DateTime.now().toString();
          await _preference.setString("date", c);
          print("enetred 2 $c");
        }
      }
// offlkne state to limite it to the first task to record the curent date
      
       var difference = DateTime.now().difference(DateTime.parse(_preference.getString("date")));
          var tim = difference.inMinutes;
      
          await _preference.setString("offline-state", "done");
    }
    return Future.value(true);
  });
}

const simplePeriodicTask = "simplePeriodicTask";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService().initNotification();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask("background-1", simplePeriodicTask,
      frequency: Duration(minutes: 16),
       existingWorkPolicy: ExistingWorkPolicy.replace);
  runApp(Auth());
}

class Auth extends StatelessWidget {
  const Auth({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges)
      ],
      child: MaterialApp(
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class Auth1 extends StatelessWidget {
  const Auth1({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
        )
      ],
      child: MaterialApp(
        home: AuthenticationWrapper1(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({ Key key }) : super(key: key);

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  

 

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
 
    if (firebaseUser != null  ) {
      return MyApp();
    }
    return LoginPage();
  }
}



class AuthenticationWrapper1 extends StatelessWidget {
  const AuthenticationWrapper1({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if (firebaseUser != null) {
      return MyApp();
    }
    return SignupPage();
  }
}

getToken() async {
  String token = await FirebaseMessaging.instance.getToken();

  print(token);
  return token;
}
