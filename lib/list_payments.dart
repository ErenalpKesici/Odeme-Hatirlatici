import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:odeme_hatirlatici/main.dart';
import 'package:odeme_hatirlatici/payment.dart';

import 'helper_functions.dart';

class ListPaymentsSendPage extends StatefulWidget{
  const ListPaymentsSendPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ListPaymentsPage();
  }
}
class ListPaymentsPage extends State<ListPaymentsSendPage>{
  List<List<Payment>> payments2D = List.empty(growable: true);
  @override
  void initState() {
    if(payments.isNotEmpty){
      List<Payment> paymentInner = List.empty(growable: true);
      paymentInner.add(payments[0]);
      for(int i=1;i<payments.length;i++){
        if(payments[i - 1].description == payments[i].description){
          paymentInner.add(payments[i]);
        } 
        else{
          payments2D.add(paymentInner);
          paymentInner = List.filled(1, payments[i], growable: true);
        }
      }
      payments2D.add(paymentInner);
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text("Ödemeler Listesi"),
       centerTitle: true,
     ),
     body: Center(
       child: ListView.builder(
         itemCount: payments2D.length,
         itemBuilder: (BuildContext context, int index){
           return SingleChildScrollView(
             child: ExpansionTile(
               leading: Text(displayDate(payments2D[index][0].date!)),
               title: Text(payments2D[index][0].description!+",    " + boolToString(payments2D[index][0].done), textAlign: TextAlign.center,),
               children: List.generate(payments2D[index].length, (idx) => getData(context, payments2D[index], idx)),
             ),
           );
         },
      )
     ),
   ); 
  }

  Widget getData(BuildContext context, List<Payment> payments2d, int index) {
    if(index != 0) {
      return ListTile(
        leading: Text(displayDate(payments2d[index].date!)),
        title: Text(payments2d[index].description!+" - "+boolToString(payments2d[index].done), textAlign: TextAlign.center,),
      );
    }
    else{
      return Container();
    }
  }
}