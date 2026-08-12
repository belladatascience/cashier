import 'package:flutter/material.dart';

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 187, 128, 107),
        title: const Text("Hello Batch7"),
        centerTitle: true,
        actions: const [Text("1"), Text("2")],
        leading: const Icon(Icons.arrow_back),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text("Hello Batch 7"),
          SizedBox(height: 20),
          Text("Hello Batch 7"),
          SizedBox(height: 20),
          Text("Hello Batch 7"),
        ],
      ),
    );
  }
}
