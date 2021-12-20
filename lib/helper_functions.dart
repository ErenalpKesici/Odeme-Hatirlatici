
import 'package:odeme_hatirlatici/main.dart';
import 'package:odeme_hatirlatici/payment.dart';

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
      return true;
    }
  }
  return false;
}