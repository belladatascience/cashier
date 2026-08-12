import 'package:flutter/material.dart';

class StylingDay5 extends StatelessWidget {
  const StylingDay5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: 
      const Color.fromARGB(255, 187, 128, 107), 
      title: Text("StylingDay5"),
      centerTitle: true,
      actions: [Text("1"), Text("2")],
      leading: Icon(Icons.arrow_back),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children:  [
          Text(
            "Hello Batch 7",
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),

        Text (
          "Hello Batch 7",
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: const Color.fromARGB(255, 65, 122, 129),
            backgroundColor: Colors.amberAccent,
          ),
        ),
      ],
    ),
    );
  }
}