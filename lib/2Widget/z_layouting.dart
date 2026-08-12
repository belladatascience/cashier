import 'package:flutter/material.dart';

class LayoutingDay5 extends StatelessWidget {
  const LayoutingDay5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: 
      const Color.fromARGB(255, 187, 128, 107), 
      title: Text("LayoutingDay5"),
      centerTitle: true,
      actions: [Text("1"), Text("2")],
      leading: Icon(Icons.arrow_back),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children:  [
        Text ("Hello Batch 7"),
        Text ("Hello Batch 7"),
        Text ("Hello Batch 7"),
        Icon(Icons.star),
        Text("Hello Batch 7"),
        Text("Di bawah ini Row"),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          
          children: [Icon(Icons.star), Text("Hello Batch 7")],
        ),
      ],
    ),
    );
  }
}