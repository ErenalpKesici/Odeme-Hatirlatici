
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:odeme_hatirlatici/main.dart';
import 'package:odeme_hatirlatici/payment.dart';
import 'package:odeme_hatirlatici/payments_at_date.dart';
import 'package:odeme_hatirlatici/preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'backup_restore.dart';

String boolToString(bool? bool){
  if(bool == null || !bool)return'Ödenmedi';
  return 'Ödendi ';
}
String displayDate(DateTime date){
  return date.day.toString()+"/"+date.month.toString()+"/"+date.year.toString();
}

List<Payment> queryPayments(DateTime date){
  List<Payment> ret = List.empty(growable: true);
  print(payments.toString());
  for(Payment payment in payments){
    if(payment.date == date){
      ret.add(payment);
    }
    else if((payment.creditCard == true && payment.monthsLeft == -1 && date.compareTo(payment.date!) > 0 && payment.date!.day == date.day)){
      Payment tmp = payment;
      tmp.done = false;
      ret.add(tmp);
    }
  }
  return ret;
}
bool dateValid(DateTime date){
  for(Payment payment in payments){
    if((payment.creditCard == true && date.compareTo(payment.date!) > 0 && payment.date!.day == date.day) || payment.date == date){
      return true;
    }
  }
  return false;
}
Future<void> savePayments(BuildContext context) async {
  final externalDir = await getExternalStorageDirectory();
  await File(externalDir!.path + "/Save.json").writeAsString(jsonEncode(payments));
}
void tryBackup() async{
  final externalDir = await getExternalStorageDirectory();
  if(await File(externalDir!.path+"/Preferences.json").exists()){
    String readPref = await File(externalDir.path+"/Preferences.json").readAsString();
    pref = Preferences.empty();
    Map<String, dynamic> prefs = jsonDecode(readPref);
    prefs.forEach((key, value) {
      switch(key){
        case('user'):
          pref!.user = value;
          break;
        case('backupFrequency'):
          pref!.backupFrequency = value;
          break;
      }
    });
    var doc = await FirebaseFirestore.instance.collection('Users').doc(pref!.user).get();
    DateTime dateUpdated = DateTime.parse(doc.get('dateUpdated'));
    int frequencyDays = 0;
    switch(pref!.backupFrequency){
      case('Day'):
        frequencyDays = 1;
        break;
      case('Week'):
        frequencyDays = 7;
        break;
      case('Month'):
        frequencyDays = 30;
        break;
    }
    if(DateUtils.dateOnly(dateUpdated.add(Duration(days: frequencyDays))).compareTo(DateUtils.dateOnly(DateTime.now())) < 1){
      String readSave = await File(externalDir.path+"/Save.json").readAsString();
      if(doc.get('save') != readSave) {
        FirebaseFirestore.instance.collection('Users').doc(pref!.user).update({'dateUpdated': DateTime.now().toString(), 'save': readSave});
      }
    }
  }
}