import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:odeme_hatirlatici/payments_at_date.dart';
import 'package:odeme_hatirlatici/payment.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';

List<Payment> payments = List.empty(growable: true);
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final externalDir = await getExternalStorageDirectory();
  if(await File(externalDir!.path +'/Save.json').exists() && await File(externalDir.path+"/Save.json").readAsString() != ""){
    List<dynamic> paymentsRead = jsonDecode(await File(externalDir.path+"/Save.json").readAsString());
    for(var itm in paymentsRead){
      Payment tmp  = Payment.clear();
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
  print(payments.toString());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odeme Hatirlatici',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(color: Colors.green),
      ),
      home: const MyHomePage(title: 'Odeme Hatirlatici'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime currentDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
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
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PaymentsAtDateSendPage(date: DateUtils.dateOnly(date).toLocal())));
              },
              holidayPredicate: (DateTime date){
                return payments.any((element) => (element.date == DateUtils.dateOnly(date).toLocal()));
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
                holidayTextStyle: TextStyle(color: Colors.white),
                holidayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              ),
            )
          ],
        ),
      ),
      
    );
  }
}
