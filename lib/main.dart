import 'package:ecom_android/pages/product_details_page.dart';
import 'package:ecom_android/providers/product_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/dashboard_page.dart';
import 'pages/launcher_page.dart';
import 'pages/login_page.dart';
import 'pages/new_product_page.dart';
import 'pages/product_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
              elevation: 0
          ),
          primarySwatch: Colors.blue,
        ),
        home: LoginPage(),
        routes: {
          LauncherPage.routeName : (context) => LauncherPage(),
          LoginPage.routeName : (context) => LoginPage(),
          DashboardPage.routeName : (context) => DashboardPage(),
          NewProductPage.routeName : (context) => NewProductPage(),
          ProductListPage.routeName : (context) => ProductListPage(),
          ProductDetailsPage.routeName : (context) => ProductDetailsPage(),
        },
      ),
    );
  }
}

