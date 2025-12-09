import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 500,
              child: Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.contain,
              ),
            )
          ],
        ),
      ),

    );
  }
}
