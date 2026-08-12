import 'package:cashier/2Widget/j_stack.dart';
import 'package:cashier/2Widget/p_save_button.dart';
import 'package:cashier/2Widget/z_function.dart';
import 'package:cashier/2Widget/z_home.dart';
import 'package:cashier/extension/navigator.dart';
import 'package:flutter/material.dart';

class RoutingDay11 extends StatelessWidget {
  const RoutingDay11({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routing Day 11"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => HomeRoutingDay11()),
                // );
                context.push(HomeRoutingDay11());
              },
              child: Text("Push"),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigator.pushNamed(context, "/home");
                context.pushNamed("/home");
              },
              child: Text("PushNamed"),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => HomeRoutingDay11()),
                // );
                context.pushReplacement(HomeRoutingDay11());
              },
              child: Text("PushReplacement"),
            ),
          ),
          tombolPush(context),

          //REUSABLE
          buttonNavigator(
            context,
            "Push",
            onPressed: () {
              context.push(Tugas4Flutter());
            },
          ),
          buttonNavigator(
            context,
            "PushNamed",
            onPressed: () {
              context.pushNamed("/home");
            },
          ),
          buttonNavigator(
            context,
            "PushReplacement",
            onPressed: () {
              context.push(StackDay8());
            },
          ),
          buttonNavigator(context, "PushRemoveAll"),
          // DefaultButton(text: "Simpan", onPressed: () {}),
          SaveButton(),
        ],
      ),
    );
  }

  Center tombolPush(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => HomeRoutingDay11()),
          // );
          context.pushReplacement(HomeRoutingDay11());
        },
        child: Text("PushReplacement"),
      ),
    );
  }

  Center buttonNavigator(
    BuildContext context,
    String text, {
    void Function()? onPressed,
  }) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        onPressed: onPressed,
        // () {
        //   // Navigator.push(
        //   //   context,
        //   //   MaterialPageRoute(builder: (context) => HomeRoutingDay11()),
        //   // );
        //   context.push(HomeRoutingDay11());
        // },
        child: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
