import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ProductHotPage extends StatefulWidget {
  @override
  _ProductHotPageState createState() => _ProductHotPageState();
}

class _ProductHotPageState extends State<ProductHotPage> {

  var product;
  bool isLoading = true;

  getProduct() async{
    final res = await http.get('http://wangpharma.com/API/product.php?PerPage=30&act=Hot');

    if(res.statusCode == 200){
      var jsonRes = json.decode(res.body);
      print(jsonRes);

      setState(() {
        isLoading = false;
        product = jsonRes;
      });

      print(product.length);

    }else{
      print('error');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? CircularProgressIndicator()
          : ListView.builder(itemBuilder: (context, int index){
        return ListTile(
          onTap: (){},
          leading: Image.network('http://www.wangpharma.com/cms/product/${product[index]['pic']}',width: 70, height: 70,),
          title: Text('${product[index]['nproduct']}'),
          subtitle: Text('${product[index]['nproductENG']}'),
          trailing: Icon(Icons.shopping_basket),
        );
      }, itemCount: product != null ? product.length : 0,),
    );
  }
}
