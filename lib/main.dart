import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:hcastick/anasayfa.dart';
import 'package:hcastick/onmuhasebe/karsilamapage.dart';

import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
  //runApp(muhasebe());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HCA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 15, 14, 17),
        ),
      ),
      home: LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
