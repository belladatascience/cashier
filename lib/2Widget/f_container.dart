import 'package:flutter/material.dart';

class ContainerDay6 extends StatelessWidget {
  const ContainerDay6({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Container"), backgroundColor: Colors.amber),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(height: 100, width: 400, color: Colors.brown),
          ),
          //2
          Container(
            height: 100,
            width: 200,
            color: Colors.purpleAccent,
            child: Column(
              children: [
                Text("Nama : Bella"),
                Text("Hoby : Jalan-jalan"),
                Text("Alamat : Jakarta"),
              ],
            ),
          ),
          //3
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(16),
            height: 100,
            width: 200,
            color: Colors.pink,
            child: Column(
              children: [
                Text("Nama : Bella"),
                Text("Hoby : Jalan-jalan"),
                Text("Alamat : Jakarta"),
              ],
            ),
          ),
          //4
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.all(16),
            height: 100,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.amber[300],
              border: Border.all(
                color: const Color.fromARGB(255, 197, 185, 12),
                width: 2,
                strokeAlign: 10,
                //style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text("Nama : Bella"),
                Text("Hoby : Jalan-jalan"),
                Text("Alamat : Jakarta"),
              ],
            ),
          ),

          //5
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.all(16),
            height: 100,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.amber[300],
              border: Border.all(
                color: const Color.fromARGB(255, 238, 199, 28),
                width: 2,
                strokeAlign: 10,
                //style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 86, 3, 124),
                  blurRadius: 10,
                  offset: Offset(10, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                Text("Nama : Bella"),
                Text("Hoby : Jalan-jalan"),
                Text("Alamat : Jakarta"),
              ],
            ),
          ),
          //6
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.all(16),
            height: 100,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.green,
              // backgroundBlendMode: BlendMode.color,
              border: Border.all(
                color: Colors.black,
                width: 2,
                strokeAlign: 10,
                // style: BorderStyle.none,
              ),
              // borderRadius: BorderRadius.all(Radius.circular(20)),
              // borderRadius: BorderRadius.circular(20),
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(20),
              //   bottomRight: Radius.circular(20),
              // ),
              // borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Text("Nama : Andrea"),
                Text("Hoby : Mengajar"),
                Text("Alamat : Indonesia Terci"),
              ],
            ),
          ),

          //7
          Container(
            margin: EdgeInsets.only(top: 40),
            padding: EdgeInsets.all(16),
            height: 100,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.green,
              // backgroundBlendMode: BlendMode.color,
              border: Border.all(
                color: Colors.black,
                width: 2,
                strokeAlign: 10,
                // style: BorderStyle.none,
              ),
              // borderRadius: BorderRadius.all(Radius.circular(20)),
              // borderRadius: BorderRadius.circular(20),
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(20),
              //   bottomRight: Radius.circular(20),
              // ),
              // borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue,
                  blurRadius: 10,
                  offset: Offset(10, 20),
                ),
                BoxShadow(
                  color: Colors.blue,
                  blurRadius: 10,
                  offset: Offset(-5, -10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text("Nama : Andrea"),
                Text("Hoby : Mengajar"),
                Text("Alamat : Indonesia Terci"),
              ],
            ),
          ),

          //5
          Container(
            margin: EdgeInsets.only(top: 40),
            padding: EdgeInsets.all(16),
            height: 100,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.green,
              // backgroundBlendMode: BlendMode.color,
              border: Border.all(
                color: Colors.black,
                width: 2,
                strokeAlign: 10,
                // style: BorderStyle.none,
              ),
              // borderRadius: BorderRadius.all(Radius.circular(20)),
              // borderRadius: BorderRadius.circular(20),
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(20),
              //   bottomRight: Radius.circular(20),
              // ),
              // borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              gradient:
                  //  RadialGradient(
                  //   // center: AlignmentGeometry.centerStart,
                  //   // focal: AlignmentGeometry.bottomCenter,
                  //   colors: [Colors.yellow, Colors.red, Colors.blue],
                  // ),
                  // SweepGradient(
                  //   colors: [Colors.yellow, Colors.red, Colors.blue],
                  // ),
                  LinearGradient(
                    colors: [Colors.yellow, Colors.red, Colors.blue],
                  ),
            ),
            child: Column(
              children: [
                Text("Nama : Andrea"),
                Text("Hoby : Mengajar"),
                Text("Alamat : Indonesia Terci"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
