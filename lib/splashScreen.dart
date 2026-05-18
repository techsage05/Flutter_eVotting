import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 84, 182, 243), Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'version 1.0',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 110),
                Text(
                  'E-Voting.org',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 60),

                Image(
                  image: NetworkImage('https://i.ibb.co/5Wnqy4dH/logo.png'),
                  height: 150,
                  width: 150,
                ),

                SizedBox(height: 20),

                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),

                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 150),
                Divider(color: Colors.black, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Made with ',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Icon(
                      Icons.copyright_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                    Text(
                      ' by Hitesh prajapati',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
                Divider(color: Colors.black, thickness: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
