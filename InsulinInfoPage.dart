import 'package:flutter/material.dart';

class InsulinInfoPage extends StatelessWidget {
  const InsulinInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حساب جرعة الإنسولين'),
        backgroundColor: Color.fromRGBO(52, 91, 99, 1),
      ),
      body: Center(
        child: Text(
          'دي صفحة حساب الإنسولين',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
