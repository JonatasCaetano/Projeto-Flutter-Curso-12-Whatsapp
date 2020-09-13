import 'package:flutter/material.dart';
import 'package:whatsappclone/Login.dart';
import 'package:whatsappclone/RouteGenerator.dart';

void main(){
  runApp(
    MaterialApp(
      home: Login(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff075e54),
        accentColor: Color(0xff25d366)
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute
    )
  );

}
