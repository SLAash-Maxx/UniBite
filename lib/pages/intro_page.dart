import 'package:flutter/material.dart';
import 'package:unibite/pages/home_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //logo
          Center(
            child: Image.asset(
              'lib/images/logo.png',
              height: 240,
            ),
          ),
          //title

          GestureDetector(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => HomePage()
                )),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(25),
              child: Center(
                child: Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 16, 
                    color: Colors.white
                    ),
                    ),
                    ),
            ),
          )
        ],
      ),
    );
  }
}