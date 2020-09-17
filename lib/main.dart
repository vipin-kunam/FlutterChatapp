import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:convert';
import 'Welcome.dart';
import './Screens/Permission.dart';
import './Screens/contacts.dart';
import './Screens/Signup.dart';
import './Screens/login.dart';
import './Screens/Chat.dart';
import './Service/SqliteService.dart'as Sqlite;
import './Service/mynoandbaseurl.dart';
import './Service/httpService.dart' as http;
var loggedin=false;
const simplePeriodicTask = "simplePeriodicTask1";
// flutter local notification setup
void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    FlutterLocalNotificationsPlugin flp = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSetttings = InitializationSettings(android, iOS);
    flp.initialize(initSetttings);
//    var myphoneno = getphoneno();
//    var  myphoneno1=myphoneno.substring(myphoneno.length - 10);
//    var response=await http.get('contacts/bgget/?to=${myphoneno1}');
//    var chatsfromserver=[];
//    chatsfromserver =jsonDecode(response.body);
//    for(dynamic data in chatsfromserver){
//      var res=Sqlite.DBProvider.db.getRecipiantbyno(data['sender']);
//      showNotification(data['message'], flp,'s');
//    }
//    print("no messgae");
    return Future.value(true);
  });
}
void showNotification( v, flp,sender) async {
  var android = AndroidNotificationDetails(
      'id', 'Name', 'CHANNEL DESCRIPTION',
      priority: Priority.High, importance: Importance.Max);
  var iOS = IOSNotificationDetails();
  var platform = NotificationDetails(android, iOS);
  await flp.show(0, 'Message received from ${sender}', '$v', platform,
      payload: 'VIS \n $v');
}

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager.initialize(callbackDispatcher);
  await Workmanager.registerPeriodicTask("6", simplePeriodicTask,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      frequency: Duration(minutes: 15),//when should it check the link
      initialDelay: Duration(seconds: 3),//duration before showing the notification
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,

      ));
  Sqlite.DBProvider.db.getuser().then((response){
    if(response!=null){
      loggedin=true;
      setphoneno(response['phoneno']);
      print(phoneno);
    }
    else{
      loggedin=false;
    }
    runApp(MyApp());
  });

}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    String firstpage=loggedin?'/contacts':'/';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatAPP',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
     initialRoute: firstpage,
      routes: {
        '/':(context)=>WelcomeScreen(),
        '/per':(context)=>SeeContactsButton(),
        '/contacts':(context)=>ContactsPage(),
        '/signup':(context)=>Signup(),
        '/login':(context)=>Login(),
        '/chat':(contect)=>Chat()
      },
    );
  }
}

