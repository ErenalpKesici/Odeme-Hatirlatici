import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:odeme_hatirlatici/main.dart';
import 'package:odeme_hatirlatici/payment.dart';
import 'package:odeme_hatirlatici/payment_edit.dart';
import 'package:path_provider/path_provider.dart';

import 'helper_functions.dart';

class PaymentsAtDateSendPage extends StatefulWidget{
  final DateTime? date; 
  const PaymentsAtDateSendPage({Key? key, @required this.date}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PaymentEditPage(this.date);
  }
}
class PaymentEditPage extends State<PaymentsAtDateSendPage>{
  List<Payment> currentPayments = List.empty(growable: true);
  DateTime? date;
  PaymentEditPage(this.date);
  @override
  void initState() {
    currentPayments = queryPayments(date!);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(date!.day.toString()+"/"+date!.month.toString()+"/"+date!.year.toString()),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: (){
                showDialog(context: context, builder: (BuildContext context){
                  TextEditingController tecDescription = TextEditingController(text: ''), tecMonths = TextEditingController(text: '');
                  String info = "";
                  bool? unlimited;
                  return StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) setState) {
                      return AlertDialog(
                        title: const Text('Ödeme Ekle'),
                        content:
                          SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextField(
                                  controller: tecDescription,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(hintText: 'Ödeme', icon: Icon(Icons.description)),
                                ),
                                const Divider(height: 50,  thickness: 1,),
                                TextField(
                                  enabled: unlimited==null||unlimited==false,
                                  controller: tecMonths,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(hintText: 'Kalan Ay', icon: Icon(Icons.access_time_filled_sharp)),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 20,),
                                const Text('Ya da', textAlign: TextAlign.center,),
                                CheckboxListTile(
                                  title: const Text('Kredi Karti'),
                                  onChanged: (bool? value) { 
                                    setState(() {                                
                                      unlimited = value;
                                      if(unlimited == true){
                                        tecMonths.text = '';
                                      }
                                    });
                                   }, 
                                   value: unlimited??false,
                                ),
                                const SizedBox(height: 20,),
                                ElevatedButton.icon(
                                  onPressed: () async{
                                    if(tecDescription.text != ''){
                                      int monthsLeft = -1;
                                      if((unlimited == null || unlimited == false) && (tecMonths.text != '0' && tecMonths.text != '')) {
                                        monthsLeft = int.parse(tecMonths.text);
                                        for(int i=0;i<int.parse(tecMonths.text);i++){
                                          payments.add(Payment(date: DateTime(date!.year, date!.month + i, date!.day), description: tecDescription.text, monthsLeft: monthsLeft--, done: false));
                                        }
                                      }
                                      else{
                                        payments.add(Payment(date: DateTime(date!.year, date!.month, date!.day), description: tecDescription.text, monthsLeft: monthsLeft, done: false));
                                      }
                                      setState(() {                                
                                        currentPayments = queryPayments(date!);
                                      });
                                      await savePayments(context);
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PaymentsAtDateSendPage(date: DateUtils.dateOnly(date!).toLocal())));
                                    }
                                    else{
                                      setState(() {
                                        info = "Aciklama girdiginize ve kalan ayin 0 dan buyuk olduguna emin olun.";
                                      });
                                    }
                                }, icon: const Icon(Icons.task_alt_outlined), label: const Text("Ok")),
                                Opacity(child: Text(info), opacity: .5,),
                              ],
                            ),
                          ),
                        );
                      },
                  );
                });
              }, 
              icon: const Icon(Icons.add)
            )
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                if(currentPayments.isNotEmpty)
                  DataTable(
                    showCheckboxColumn: false,
                    columns: 
                      const [
                        DataColumn(label: Text('Ödeme')),
                        DataColumn(label: Text('Kalan Ay')),
                        DataColumn(label: Text('Durum')),
                      ],
                    rows: List.generate(currentPayments.length, (index) => getDataRow(context, currentPayments, index))
                  ),
                if(currentPayments.isEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height/3, 0, 0),
                    child: const Text("Bu Tarihde bir Ödeme Girilmedi"),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
DataRow getDataRow(BuildContext context, List<Payment> currentPayments, int index){
  bool? done = currentPayments[index].done;
  return DataRow(
    onSelectChanged: (bool? selected){
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PaymentEditPageSend(payment: currentPayments[index],)));
    },
    cells: [
      DataCell(SizedBox(width: 100, child: Text(currentPayments[index].description!))),
      DataCell(Text(currentPayments[index].monthsLeft! < 0?'Kredi':currentPayments[index].monthsLeft!.toString())),
      DataCell(Text(boolToString(done))),
    ]
  );
}