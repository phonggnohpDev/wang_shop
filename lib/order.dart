import 'package:flutter/material.dart';
import 'package:wang_shop/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:wang_shop/ship_dialog.dart';
import 'package:wang_shop/pay_dialog.dart';
import 'package:wang_shop/summary_order.dart';

import 'package:wang_shop/bloc_provider.dart';
import 'package:wang_shop/bloc_count_order.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {

  BlocCountOrder blocCountOrder;

  @override
  DatabaseHelper databaseHelper = DatabaseHelper.internal();

  List orders = [];

  List units = [];
  String _currentUnit;
  var unitStatus;

  int selectedRadioTileShip;
  int selectedRadioTilePay;

  getOrderAll() async{
    var res = await databaseHelper.getOrder();
    print(res);

    setState(() {
      orders = res;
    });
  }

  showToastRemove(){
    Fluttertoast.showToast(
        msg: "ลบรายการแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3
    );
  }

  saveEditOrderDialog(id, unit, unitStatusVal, amount) async {
    Map order = {
      'id': id,
      'unit': unit,
      'unitStatus': unitStatusVal,
      'amount': amount,
    };
    await databaseHelper.updateOrder(order);
    getOrderAll();
  }

  editOrderDialog(order, closeDialog){

    units = [];

    //if(_currentUnit.isEmpty){
      _currentUnit = order['unit'].toString();
      unitStatus = order['unitStatus'];
    //}else{
      //_currentUnit = this._currentUnit;
    //}

    if(order['unit1'].toString() != "NULL"){
      units.add(order['unit1'].toString());
    }
    if(order['unit2'].toString() != "NULL"){
      units.add(order['unit2'].toString());
    }
    if(order['unit3'].toString() != "NULL"){
      units.add(order['unit3'].toString());
    }

    print(_currentUnit);
    print(units);

    TextEditingController editAmount = TextEditingController();

    editAmount.text = order['amount'].toString();

    return showDialog(context: context, builder: (context) {
        return SimpleDialog(
          title: Text('แก้ไขรายการ'),
          children: <Widget>[
            Divider(
              color: Colors.green,
            ),
            Padding(
             padding: EdgeInsets.all(5),
             child: Text('${order['name']}'),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "จำนวน",
                      ),
                      keyboardType: TextInputType.number,
                      controller: editAmount,
                    ),
                  ),
                  Expanded(
                    child: DropdownButton(
                      hint: Text("เลือกหน่วยสินค้า",style: TextStyle(fontSize: 18)),
                      items: units.map((dropDownStringItem){
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem, style: TextStyle(fontSize: 18)),
                        );
                      }).toList(),
                      onChanged: (newValueSelected){
                        var tempIndex = units.indexOf(newValueSelected)+1;
                        _onDropDownItemSelected(newValueSelected, tempIndex);
                        print(this._currentUnit);
                        print(tempIndex);

                      },
                      value: _currentUnit,

                    ),
                  )
                ],
              ),
            ),

            SimpleDialogOption(
              onPressed: (){

                    print(this._currentUnit);
                    print(this.unitStatus);

                    saveEditOrderDialog(order['id'], this._currentUnit, this.unitStatus, editAmount.text);
                    //print(order['id']);
                    //print(this._currentUnit);
                    //print(editAmount.text);
                    if(closeDialog == 1){
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                    }else{
                      Navigator.pop(context);
                    }

              },
              child: Text(
                  'ตกลง',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold
                  )
              ),
            ),
          ],


        );
    });
  }

  selectShip(){
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        title: Text('เลือกวิธีการรับสินค้า'),
        children: <Widget>[
          ShipDialogPage(),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Divider(
            color: Colors.black,
          ),
          SimpleDialogOption(
            onPressed: (){
              selectPay();
            },
            child: Text(
                'ตกลง',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      );
    });
  }

  selectPay(){
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        title: Text('เลือกวิธีชำระเงิน'),
        children: <Widget>[
          //Text('จำนวน'),
          PayDialogPage(),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Divider(
            color: Colors.black,
          ),
          SimpleDialogOption(
            onPressed: (){

              Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryOrderPage()));
            },
            child: Text(
                'ตกลง',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold
                )
            ),
          ),
        ],


      );
    });
  }



  _onDropDownItemSelected(newValueSelected, newIndexSelected){
    setState(() {
      this._currentUnit = newValueSelected;
      this.unitStatus = newIndexSelected;
      //print('select--${units}');
    });
  }

  void _confirmDelShowAlert(int id, valProduct) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันลบรายการ'),
          actions: <Widget>[
            FlatButton(
              color: Colors.red,
              child: Text('ลบ', style: TextStyle(fontSize: 18, color: Colors.white),),
              onPressed: (){
                showDialogDelConfirm(id);
                //Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.green,
              child: Text('แก้ไข', style: TextStyle(fontSize: 18, color: Colors.white)),
              onPressed: (){
                setState(() {
                  editOrderDialog(valProduct, 1);
                });
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showDialogDelConfirm(id) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("แจ้งเตือน"),
          content: Text("ยืนยันลบรายการสินค้า"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              color: Colors.green,
              child: Text("ตกลง",style: TextStyle(color: Colors.white, fontSize: 18),),
              onPressed: () {
                removeOrder(id);
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  removeOrder(int id) async{
    await databaseHelper.removeOrder(id);
    getOrderAll();
    showToastRemove();

    //add notify order
    blocCountOrder.getOrderCount();

  }

  void initState(){
    super.initState();
    getOrderAll();

  }

  Widget build(BuildContext context) {

    blocCountOrder = BlocProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('รายการสินค้า'),
        actions: <Widget>[
          IconButton(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              icon: Stack(
                children: <Widget>[
                  Icon(Icons.check_box, size: 40,),
                  Positioned(
                    right: 0,
                    child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: StreamBuilder(
                          initialData: blocCountOrder.countOrder,
                          stream: blocCountOrder.counterStream,
                          builder: (BuildContext context, snapshot) => Text(
                          '${snapshot.data}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: (){
                selectShip();
                //Navigator.pushReplacementNamed(context, '/Order');
              }
          )
        ],
      ),
      body: ListView.builder(
        //separatorBuilder: (context, index) => Divider(
          //color: Colors.black,
        //),
        itemBuilder: (context, int index){
          return ListTile(
              //contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
              onTap: (){
                //setState(() {
                  editOrderDialog(orders[index], 0);
                //});
              },
              leading: Image.network('http://www.wangpharma.com/cms/product/${orders[index]['pic']}',fit: BoxFit.cover, width: 70, height: 70,),
              title: Text('${orders[index]['code']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${orders[index]['name']}'),
                  Text('จำนวน ${orders[index]['amount']} : ${orders[index]['unit']}',
                    style: TextStyle(fontSize: 18, color: Colors.red),),
                ],
              ),
              trailing: IconButton(
                  icon: Icon(Icons.list, size: 30,),
                  onPressed: (){
                    _confirmDelShowAlert(orders[index]['id'], orders[index]);
                  }
              ),
          );
        },
        itemCount: orders != null ? orders.length : 0,
      ),
    );
  }
}
