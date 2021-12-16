import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:odeme_hatirlatici/main.dart';
import 'package:odeme_hatirlatici/payment.dart';
import 'package:odeme_hatirlatici/payment_edit.dart';
import 'package:path_provider/path_provider.dart';

class PaymentsAtDateSendPage extends StatefulWidget{
  final DateTime? date; 
  const PaymentsAtDateSendPage({Key? key, @required this.date}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PaymentEditPage(this.date);
  }
}
class PaymentEditPage extends State<PaymentsAtDateSendPage>{
  DateTime? date;
  List<Payment> currentPayments = List.empty(growable: true);
  PaymentEditPage(this.date);
  @override
  void initState() {
    currentPayments = payments.where((element) => element.date == date).toList();
    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(date.toString()),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){
              showDialog(context: context, builder: (BuildContext context){
                TextEditingController tecDescription = TextEditingController(text: ''), tecMonths = TextEditingController(text: '1');
                return AlertDialog(
                  title: const Text('Odeme Ekle'),
                  content: 
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: tecDescription,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(hintText: 'Aciklama Girin'),
                        ),
                        TextField(
                          controller: tecMonths,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(hintText: 'Kalan Ay'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20,),
                        ElevatedButton.icon(
                          onPressed: () async{
                            if(tecDescription.text != '' && tecMonths.text != '0'){
                              int monthsLeft = int.parse(tecMonths.text);
                              for(int i=0;i<int.parse(tecMonths.text);i++){
                                payments.add(Payment(date: DateTime(date!.year, date!.month + i, date!.day), description: tecDescription.text, monthsLeft: monthsLeft--, done: null));
                              }
                              setState(() {                                
                                currentPayments = payments.where((element) => element.date == date).toList();
                              });
                              final externalDir = await getExternalStorageDirectory();
                              await File(externalDir!.path + "/Save.json").writeAsString(jsonEncode(payments));
                              Navigator.pop(context);
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kontrol edin.')));
                            }
                        }, icon: const Icon(Icons.task_alt_outlined), label: const Text("Ok"))
                      ],
                    ),
                );
              });
            }, 
            icon: const Icon(Icons.add)
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DataTable(
              showCheckboxColumn: false,
              columns: 
                const [
                  DataColumn(label: Text('Aciklama')),
                  DataColumn(label: Text('Kalan Ay')),
                  DataColumn(label: Text('Tamamlandi')),
                ],
               rows: List.generate(currentPayments.length, (index) => getDataRow(context, currentPayments, index))
            ),
          ],
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
      DataCell(Text(currentPayments[index].description!)),
      DataCell(Text(currentPayments[index].monthsLeft!.toString())),
      DataCell(Opacity(
        opacity: .1,
        child: Checkbox(value: done ?? false, 
        onChanged: (bool? value) {
          value = value; 
        },
        ),
      )),
    ]
  );
}