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
  List<bool> selected = List.empty(growable: true);
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
          selected.add(false);
        }
      }
      payments2D.add(paymentInner);
      selected.add(false);
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
   return WillPopScope(
     onWillPop: ()async{
       Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const MyHomePage()));
       return false;
     },
     child: Scaffold(
       appBar: AppBar(
         title: const Text("Ödemeler Listesi"),
         centerTitle: true,
         actions: [
           if(selected.any((element) => element))
            IconButton( 
              onPressed: (){
                for(int i=0;i<selected.length;i++){
                  if(selected[i]) {
                    payments2D.removeAt(i);
                    selected.removeAt(i--);
                  }
                }
                payments = List.empty(growable: true);
                for(int i=0;i<payments2D.length;i++){
                  for(int j=0;j<payments2D[i].length;j++){
                    payments.add(payments2D[i][j]);
                  }
                }
                setState(() {
                  payments2D;payments;
                });
                savePayments(context);
              }, icon: const Icon(Icons.delete_forever))
         ],
       ),
       body: Center(
         child: ListView.builder(
           itemCount: payments2D.length,
           itemBuilder: (BuildContext context, int index){
             return SingleChildScrollView(
               child: Row(
                 children: [
                   SizedBox(width: 50, child: Checkbox(value: selected[index], onChanged: (bool? value) {  
                     setState(() {
                      selected[index] = value!;
                    });},
                   )),
                   Expanded(
                     child: ExpansionTile(
                      leading: Text(displayDate(payments2D[index][0].date!)),
                      title: Text(payments2D[index][0].description!+" "+(payments2D[index][0].monthsLeft! < 0?'(Kredi)':'')+ " " + boolToString(payments2D[index][0].done), textAlign: TextAlign.center,),
                      children: List.generate(payments2D[index].length, (idx) => getData(context, payments2D[index], idx)),
                      ),
                   ),
                 ],
               ) 
             );
           },
        )
       ),
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