import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:odeme_hatirlatici/main.dart';
import 'package:odeme_hatirlatici/payment.dart';
import 'package:odeme_hatirlatici/payments_at_date.dart';
import 'package:path_provider/path_provider.dart';

class PaymentEditPageSend extends StatefulWidget{
  final Payment? payment;
  const PaymentEditPageSend({Key? key, @required this.payment}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PaymentEditPage(payment);
  }
}

class PaymentEditPage extends State<PaymentEditPageSend>{
  Payment? payment;
  TextEditingController tecDescription = TextEditingController(text: ''), tecMonths = TextEditingController(text: '1');
  bool? done;
  PaymentEditPage(this.payment);
  @override
  void initState() {
    tecDescription = TextEditingController(text: payment?.description);
    tecMonths = TextEditingController(text: payment?.monthsLeft.toString());
    done = payment?.done;
    super.initState();
  }
  int findIdx(){
    for(int i=0;i<payments.length;i++){
      if(payments[i] == payment)return i;
  }
  return -1;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(payment!.description!),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
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
            Checkbox(
              value: done??false,
              onChanged: (value){
                setState(() {
                  done = value;
                });
              },
            ),
            const SizedBox(height: 20,),
            ElevatedButton.icon(
              onPressed: () async{
                int i = findIdx();
                if(tecMonths.text =='0'){
                  payments[i] = Payment(description: tecDescription.text==''?payments[i].description:tecDescription.text, monthsLeft: payments[i].monthsLeft, done: done, date: payments[i].date);
                }
                else if(int.tryParse(tecMonths.text) != null){
                  updateMonths(i);
                }
                final externalDir = await getExternalStorageDirectory();
                await File(externalDir!.path + "/Save.json").writeAsString(jsonEncode(payments));
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PaymentsAtDateSendPage(date: DateUtils.dateOnly(payment!.date!).toLocal())));
            }, icon: const Icon(Icons.task_alt_outlined), label: const Text("Ok"))
          ],
        ),
      ),
    );
  }
  void updateMonths(int idx) {
    List<Payment> range = payments.getRange(idx+1, idx + payment!.monthsLeft!).toList();
    payments.removeRange(idx, idx + payment!.monthsLeft!);
    payments.add(Payment(date: payment!.date, description: payment!.description, monthsLeft: int.parse(tecMonths.text), done: done));
    List<Payment> inner = List.empty(growable: true);
    int cnt = 1;
    for(int i = 0;i<int.parse((tecMonths.text));i++){
      inner.add(Payment(description: payment!.description, date: DateTime(payment!.date!.year, payment!.date!.month + cnt++, payment!.date!.day) , monthsLeft: i, done: i<range.length?range[i].done:false));
    }
    payments.insertAll(idx+1, inner.toList());
  }
}