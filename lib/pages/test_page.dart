import 'package:blastpin/defines/globals.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPage();
}

class _TestPage extends State<TestPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.pinkAccent,
        child: Center(
          child: Text(
            'TEST PAGE',
            textAlign: TextAlign.center,
            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleLarge!
          ),
        )
      ),
    );
  }
}