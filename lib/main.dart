import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jhs_pop/pages/home_page.dart';
import 'package:jhs_pop/pages/load_order_page.dart';
import 'package:jhs_pop/pages/new_item_page.dart';
import 'package:jhs_pop/pages/payment_screen.dart';
import 'package:sqflite/sqflite.dart';

late final Database db;
final dbReady = Completer<void>();

void main() {
  runApp(const MyApp());

  openDatabase('jhs_pop.db').then((database) {
    db = database;

    // setup tables
    db.execute('''
        CREATE TABLE IF NOT EXISTS products (
          id INTEGER PRIMARY KEY,
          name TEXT,
          description TEXT,
          price REAL,
          image TEXT
        )
      ''');

    db.execute('''
        CREATE TABLE IF NOT EXISTS orders (
          id INTEGER PRIMARY KEY,
          teacher TEXT,
          room TEXT,
          preferences TEXT,
          price REAL,
          quantity INTEGER
        )
      ''');

    dbReady.complete();
  });
}

final routes = <String, WidgetBuilder>{
  '/': (context) => const HomePage(),
  '/add': (context) => const NewItemPage(),
  '/payment': (context) => PaymentScreen(total: 23.45),
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
        useMaterial3: true,
      ),
      routes: routes,
    );
  }
}
