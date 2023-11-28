import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jhs_pop/pages/home_page.dart';
import 'package:jhs_pop/pages/load_order_page.dart';
import 'package:jhs_pop/pages/manual_entry.dart';
import 'package:jhs_pop/pages/payment_screen.dart';
import 'package:jhs_pop/util/order.dart';
import 'package:sqflite/sqflite.dart';

late final Database db;
final dbReady = Completer<void>();

void main() {
  runApp(const MyApp());

  openDatabase('jhs_pop.db').then((database) {
    db = database;

    // setup table

    db.execute('''
        CREATE TABLE IF NOT EXISTS orders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          room TEXT,
          additional TEXT,
          frequency TEXT,
          creamer TEXT,
          sweetener TEXT
        )
      ''');

    dbReady.complete();
  });
}

final routes = <String, WidgetBuilder>{
  '/': (context) => const HomePage(),
  '/manual': (context) => const NewItemPage(),
  '/payment': (context) => PaymentScreen(
      order: ModalRoute.of(context)!.settings.arguments as TeacherOrder),
  '/load_order': (context) => const LoadOrderPage(),
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Point of Payment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          prefixIconColor: Colors.grey[400],
          suffixIconColor: Colors.grey[400],
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
          ),
        ),
        useMaterial3: true,
      ),
      routes: routes,
    );
  }
}
