import 'package:flutter/material.dart';

class TextFieldDay8 extends StatelessWidget {
  const TextFieldDay8({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TextField day 8"),
        backgroundColor: Colors.green,
      ),
      body: Column(children: [TextField(decoration: InputDecoration())]),
    );
  }
}
