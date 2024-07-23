import 'package:ecoomerce/firebase_options.dart';
import 'package:ecoomerce/prodects_screens/prodects_list.dart';
import 'package:ecoomerce/prodects_screens/add_prodect.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp( ProductListScreen());
}

