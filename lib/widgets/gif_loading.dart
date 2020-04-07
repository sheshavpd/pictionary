import 'package:flutter/material.dart';

class GifLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: Container(
      color: Color.fromARGB(220, 255, 255, 255),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            width: 60,
            image: AssetImage("assets/images/loading.gif"),
            fit: BoxFit.fitWidth,
          ),
          Text("Loading..")
        ],
      ),
    ));
  }
}
