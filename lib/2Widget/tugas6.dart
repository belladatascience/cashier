import 'package:cashier/2Widget/z_home.dart';
import 'package:flutter/material.dart';

class Tugas6flutter extends StatelessWidget {
  const Tugas6flutter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.centerLeft,
            child: Text(
              "Welcome Back",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight(1000)),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 13),
            alignment: Alignment.centerLeft,
            child: Text(
              "Login to access your account",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 236, 240, 242),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),

                      color: Colors.white,
                    ),

                    child: SizedBox(
                      height: 45,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Phone Number",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Text(
                    "Email",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.only(left: 13),
            alignment: Alignment.centerLeft,
            child: Text(
              "Phone Number",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "+6287888848000",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.only(left: 13),
            alignment: Alignment.centerLeft,
            child: Text(
              "Password",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.visibility_off),
                hintText: "..........",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Container(
            width: double.infinity,
            height: 65,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(shape: BoxShape.rectangle),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 109, 208, 215),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeRoutingDay11()),
                );
              },
              child: Text(
                "Request OTP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Divider()),
              Text("Or Sign In With"),
              Expanded(child: Divider()),
            ],
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: const Color.fromARGB(255, 211, 208, 208),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/gg.png"),
                        SizedBox(width: 12),
                        Text(
                          "Google",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: const Color.fromARGB(255, 195, 194, 194),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/fb.png"),
                        SizedBox(width: 14),
                        Text(
                          "Facebook",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(left: 13),
                alignment: Alignment.center,
                child: Text(
                  "Don't have an account?",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 13),
                alignment: Alignment.center,
                child: Text(
                  "Sing Up",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
