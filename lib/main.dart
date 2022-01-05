import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart' as an;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:odeme_hatirlatici/payments_at_date.dart';
import 'package:odeme_hatirlatici/payment.dart';
import 'package:odeme_hatirlatici/settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'AuthenticationServices.dart';
import 'helper_functions.dart';
import 'list_payments.dart';

DateTime currentDate = DateTime.now();
List<Payment> payments = List.empty(growable: true);
Settings settings = Settings.clear();
void onStart(){
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.setAutoStartOnBootMode(true);
  service.setNotificationInfo(title: 'Ödeme Hatırlatıcı ', content: "Arka planda çalışıyor.");
  service.onDataReceived.listen((event) {
    if (event!["action"] == "setAsForeground") {
      service.setForegroundMode(true);
      return;
    }
    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
    }
    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
  });
}
void setUpAlarms(){
  int nOfNotifs = 0;
  for(Payment payment in payments){
    if(payment.done == false && DateUtils.dateOnly(payment.date!).toLocal() == DateUtils.dateOnly(DateTime.now()).toLocal()){
      DateTime alarmDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, settings.time!.hour, settings.time!.minute);
      print(payment.toString()+alarmDate.toString());
      an.AwesomeNotifications().createNotification(
        schedule: an.NotificationCalendar.fromDate(date: alarmDate, allowWhileIdle: true),
        actionButtons: [
          an.NotificationActionButton(key: 'btnOk', label: 'Tamam', buttonType: an.ActionButtonType.KeepOnTop),
          // an.NotificationActionButton(key: 'btnDelay', label: 'Ertele', buttonType: an.ActionButtonType.KeepOnTop),
        ],
        content: an.NotificationContent(
          id: nOfNotifs++,
          channelKey: 'basic_channel',
          title: displayDate(payment.date!) + (payment.monthsLeft! < 0?' Kredi Kart':'') +" Ödemesi: ",
          body: payment.description.toString(),
          category: an.NotificationCategory.Reminder,
          notificationLayout: an.NotificationLayout.BigText,
          wakeUpScreen: true,
          displayOnBackground: true,
        )
      );
    }
  }
}
Future<void> readPayments(Directory externalDir) async{
  if(await File(externalDir.path +'/Save.json').exists() && await File(externalDir.path+"/Save.json").readAsString() != ""){
    List<dynamic> paymentsRead = jsonDecode(await File(externalDir.path+"/Save.json").readAsString());
    payments = List.empty(growable: true);
    for(var itm in paymentsRead){
      Payment tmp = Payment.clear();
      Map<String, dynamic> readSave = Map<String, dynamic>.from(itm);
      readSave.forEach((key, value) {
        switch(key){
          case("description"):
            tmp.description=value;        
            break;
          case("date"):
            tmp.date=DateTime.parse(value);
            break;
          case("monthsLeft"):
            tmp.monthsLeft=value;
            break;
          case("done"):
            tmp.done=value;
            break;
        }
      });
      payments.add(tmp);
    }
  }
  else{
    await File(externalDir.path +'/Save.json').create();
  }
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterBackgroundService.initialize(onStart);
  an.AwesomeNotifications().initialize(
    'resource://raw/payment',
    [
      an.NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Colors.green,
        enableLights: true,
        ledColor: Colors.red,
        enableVibration: false,
      )
    ]
  );
  final externalDir = await getExternalStorageDirectory();
  await readPayments(externalDir!);
  if(await File(externalDir.path +'/Settings.json').exists() && await File(externalDir.path+"/Settings.json").readAsString() != ""){
    print(await File(externalDir.path+"/Settings.json").readAsString());
    print(jsonDecode(await File(externalDir.path+"/Settings.json").readAsString()).runtimeType);
    List<dynamic> settingsRead = List.empty(growable: true);
    settingsRead.add(jsonDecode(await File(externalDir.path+"/Settings.json").readAsString()));
    for(var setting in settingsRead){
      Settings tmp = Settings.clear();
      Map<String, dynamic> readSave = Map<String, dynamic>.from(setting);
      readSave.forEach((key, value) {
        switch(key){
          case('time'):
            List<String> split = value.split(':');
            String hour = split[0][split[0].length - 2] + split[0][split[0].length - 1];
            String minute = split[1][0] + split[1][1];
            tmp.time = TimeOfDay(hour: int.parse(hour), minute: int.parse(minute));
            break;
        }
      });
      settings = tmp;
      setUpAlarms();
    }
  }
  else{
    await File(externalDir.path +'/Settings.json').create();
  }
  print(payments.toString());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationServices>(
          create: (_) => AuthenticationServices(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthenticationServices>().authStateChanges, initialData: null,
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          brightness: Brightness.dark,
          appBarTheme: const AppBarTheme(color: Colors.green),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ödeme Hatırlatıcı'),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Image(image: AssetImage('assets/logo.png'),),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Ana Sayfa', textAlign: TextAlign.center,),
                onTap: (){
                  if(context.widget.toString() != "MyHomePage"){
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const MyHomePage()));
                  }
                  else{
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Ödemeleri Listele', textAlign: TextAlign.center,),
                onTap: (){
                  if(context.widget.toString() != "ListPaymentsSendPage"){
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const ListPaymentsSendPage()));
                  }
                  else{
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Ayarlar', textAlign: TextAlign.center,),
                onTap: (){
                  if(context.widget.toString() != "SettingsPageSend"){
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const SettingsPageSend()));
                  }
                  else{
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Cikis Yap', textAlign: TextAlign.center,),
                onTap: () async{
                  FlutterBackgroundService().sendData({"action": "stopService"});
                  await Future.doWhile(() => FlutterBackgroundService().isServiceRunning());
                  exit(0);
                },
              )
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TableCalendar(
                focusedDay: currentDate,
                currentDay: DateTime.now(),
                firstDay: DateTime(2000),
                lastDay: DateTime(2050), 
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                calendarFormat: CalendarFormat.month,
                onHeaderTapped: (DateTime dt){
                  setState(() {
                    currentDate = DateTime.now();
                  });
                },
                onDaySelected: (DateTime date, DateTime date2){
                  setState(() {
                    currentDate = date;
                  });
                  print(DateUtils.dateOnly(date).toLocal());
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PaymentsAtDateSendPage(date: DateUtils.dateOnly(date).toLocal())));
                },
                holidayPredicate: (DateTime date){
                  return dateValid(DateUtils.dateOnly(date).toLocal());
                },
                headerStyle: const HeaderStyle(titleCentered: true),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(gradient: (payments.any((element) => (element.date == DateUtils.dateOnly(DateTime.now()).toLocal())))?const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Colors.green,
                      Colors.orange
                    ], 
                    tileMode: TileMode.repeated, 
                  ): const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Colors.green,
                      Colors.green,
                    ], 
                    tileMode: TileMode.repeated, 
                  ), shape: BoxShape.circle),
                  holidayTextStyle: const TextStyle(color: Colors.white),
                  holidayDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
