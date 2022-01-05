
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:odeme_hatirlatici/main.dart';
import 'package:odeme_hatirlatici/payment.dart';
import 'package:odeme_hatirlatici/payments_at_date.dart';
import 'package:path_provider/path_provider.dart';

String boolToString(bool? bool){
  if(bool == null || !bool)return'Ödenmedi';
  return 'Ödendi ';
}
String displayDate(DateTime date){
  return date.day.toString()+"/"+date.month.toString()+"/"+date.year.toString();
}

List<Payment> queryPayments(DateTime date){
  List<Payment> ret = List.empty(growable: true);
  for(Payment payment in payments){
    if((payment.monthsLeft == -1 && payment.date!.day == date.day) || payment.date == date){
      ret.add(payment);
    }
  }
  return ret;
}
bool dateValid(DateTime date){
  for(Payment payment in payments){
    if((payment.monthsLeft == -1 && payment.date!.day == date.day) || payment.date == date){
      print(payment.date.toString() +" and " + date.toString());
      return true;
    }
  }
  return false;
}
Future<void> savePayments(BuildContext context) async {
  final externalDir = await getExternalStorageDirectory();
  await File(externalDir!.path + "/Save.json").writeAsString(jsonEncode(payments));
}