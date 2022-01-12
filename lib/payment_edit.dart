import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:odeme_hatirlatici/main.dart';
import 'package:odeme_hatirlatici/payment.dart';
import 'package:odeme_hatirlatici/payments_at_date.dart';
import 'package:path_provider/path_provider.dart';
import 'helper_functions.dart';

class PaymentEditPageSend extends StatefulWidget{
  final Payment? payment;
  final DateTime? date;
  const PaymentEditPageSend({Key? key, @required this.payment, @required this.date}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PaymentEditPage(payment, date);
  }
}

class PaymentEditPage extends State<PaymentEditPageSend>{
  Payment? payment;
  DateTime? date;
  TextEditingController tecDescription = TextEditingController(text: ''), tecMonths = TextEditingController(text: '1');
  bool? done;
  PaymentEditPage(this.payment, this.date);
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
              decoration: InputDecoration(labelText: 'Aciklama', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            if(!payment!.creditCard!)
              TextField(
                controller: tecMonths,
                textAlign: TextAlign.center,
                decoration: InputDecoration(labelText: 'Kalan Ay', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                keyboardType: TextInputType.number,
              ),
            CheckboxListTile(
              title: const Text("Ödendi mi", textAlign: TextAlign.center,),
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
                int idx = findIdx();
                if(payment!.creditCard!){
                  int difference = -1;
                  if((difference = date!.month - payments[idx].date!.month) > 0){
                    payments[idx] = Payment(description: tecDescription.text==''?payments[idx].description:tecDescription.text, monthsLeft: difference, done: payments[idx].done, date: payments[idx].date, creditCard: true);
                    List<Payment> inner = List.empty(growable: true);
                    for(int i=0;i<difference;i++){
                      inner.add(Payment(done: i+1==difference?done:false, description: payment!.description, monthsLeft: i+1==difference?-1:difference - i - 1, date: DateTime(payment!.date!.year, payment!.date!.month + i + 1, payment!.date!.day), creditCard: true));
                    }
                    payments.insertAll(idx, inner.toList());
                  }
                  else if(difference == 0){
                     payments[idx] = Payment(description: tecDescription.text==''?payments[idx].description:tecDescription.text, monthsLeft: 0, done: done, date: payments[idx].date, creditCard: true);
                  }
                  else{
                    print("?");
                  }
                  print(payments[idx].date.toString() +" and " + date.toString());
                }
                else if(tecMonths.text == '0'){
                  payments[idx] = Payment(description: tecDescription.text==''?payments[idx].description:tecDescription.text, monthsLeft: 0, done: done, date: payments[idx].date, creditCard: false);
                }
                else if(int.tryParse(tecMonths.text) != null){
                  updateMonths(idx);
                }
                await savePayments(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
            }, icon: const Icon(Icons.task_alt_outlined), label: const Text("Ok"))
          ],
        ),
      ),
    );
  }
  void updateMonths(int idx) {
    List<Payment> range = payments.getRange(idx+1, idx + payment!.monthsLeft!).toList();
    payments.removeRange(idx, idx + payment!.monthsLeft!);
    payments.add(Payment(date: payment!.date, description: payment!.description, monthsLeft: int.parse(tecMonths.text), done: done, creditCard: false));
    List<Payment> inner = List.empty(growable: true);
    int cnt = 1;
    for(int i = 0;i<int.parse((tecMonths.text));i++){
      inner.add(Payment(description: payment!.description, date: DateTime(payment!.date!.year, payment!.date!.month + cnt++, payment!.date!.day) , monthsLeft: i, done: i<range.length?range[i].done:false, creditCard: false));
    }
    payments.insertAll(idx+1, inner.toList());
  }
}