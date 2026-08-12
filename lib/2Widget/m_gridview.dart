import 'package:flutter/material.dart';

class GridviewDay8 extends StatelessWidget {
  const GridviewDay8({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GridView day "),
        backgroundColor: Colors.green,
      ),
      body: GridView.count(
        crossAxisSpacing: 1,
        mainAxisSpacing: 2,
        crossAxisCount: 2,
        children: <Widget>[
          Container(color: Colors.red),
          Container(color: Colors.yellow),
          Container(color: Colors.blue),
          Container(color: Colors.green),
        ],
      ),
    );
  }
}
