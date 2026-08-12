import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.yellow,
      onTap: () {},
      child: Container(
        height: 48,
        margin: EdgeInsets.all(8),
        width: double.infinity,
        color: Colors.red,
        child: Center(
          child: Text(
            "Simpan",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
