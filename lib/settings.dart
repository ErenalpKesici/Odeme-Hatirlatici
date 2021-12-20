import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';

class Settings{
  TimeOfDay? time;
  Settings({@required this.time});
  Settings.clear(){time = const TimeOfDay(hour: 12, minute: 0);}
  Settings.fromJson(Map<String, dynamic> json)
    : time = json['time'];
  Map<String, dynamic> toJson() {
    return {
      'time': time.toString(),
    };
  }
}
class SettingsPageSend extends StatefulWidget{
  const SettingsPageSend({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SettingsPage();
  }
}
class SettingsPage extends State<SettingsPageSend>{
  TimeOfDay? selectedTime;
  SettingsPage();
  @override
  void initState() {
    selectedTime = settings.time;
    super.initState();
  }
  Future<void> updateSettings() async{
    final externalDir = await getExternalStorageDirectory();
    await File(externalDir!.path + "/Settings.json").writeAsString(jsonEncode(settings));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Card(
              elevation: 1,
              child: ListTile(
                leading: const Text('Hatirlatma Zamani'),
                title: Text(selectedTime!.hour.toString()+":"+selectedTime!.minute.toString(), textAlign: TextAlign.center,),
                onTap: () async{ 
                  TimeOfDay? tmpTime = await showTimePicker(
                    context: context, 
                    initialTime: settings.time!,
                  );
                  setState((){
                    if(tmpTime != null) {
                      selectedTime = tmpTime;
                      settings.time = selectedTime;
                    }                    
                  });
                  await updateSettings();
                  setUpAlarms();
                }, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}