import 'package:flutter/cupertino.dart';

class Payment{
  String? description;
  DateTime? date;
  int? monthsLeft;
  bool? done;
  Payment({@required this.description, @required this.date, @required this.monthsLeft, @required this.done});
  Payment.clear(){description = '';date= DateTime.now(); monthsLeft = 0; done = false;}
  Payment.fromJson(Map<String, dynamic> json)
    : description = json['description'],
      date = json['date'],
      monthsLeft = json['monthsLeft'],
      done = json['done'];

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'date': date.toString(),
      'monthsLeft': monthsLeft,
      'done': done
    };
  }
  @override
  String toString() {
    return description! +", "+date.toString()+", " + monthsLeft.toString()+", " + done.toString();
  }
}