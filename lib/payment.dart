import 'package:flutter/cupertino.dart';

class Payment{
  String? description;
  DateTime? date;
  int? monthsLeft;
  bool? done, creditCard;
  Payment({@required this.description, @required this.date, @required this.monthsLeft, @required this.done, @required this.creditCard});
  Payment.clear(){description = '';date= DateTime.now(); monthsLeft = 0; done = false; creditCard = false;}
  Payment.fromJson(Map<String, dynamic> json)
    : description = json['description'],
      date = json['date'],
      monthsLeft = json['monthsLeft'],
      done = json['done'],
      creditCard = json['creditCard'];

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'date': date.toString(),
      'monthsLeft': monthsLeft,
      'done': done,
      'creditCard': creditCard,
    };
  }
  @override
  String toString() {
    return description! +", "+date.toString()+", " + monthsLeft.toString()+", " + done.toString();
  }
}