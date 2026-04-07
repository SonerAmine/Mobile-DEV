import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Images Galerie',
      initialRoute: 'first',
      routes: {
        'first': (context) => const Firstscreen(),
        'second': (context) => const Secondscreen(),
      },
    ),
  );
}

// ─── Premier écran ───────────────────────────────────────────────
class Firstscreen extends StatefulWidget {
  const Firstscreen({super.key});

  @override
  State<Firstscreen> createState() => _FirstscreenState();
}

class _FirstscreenState extends State<Firstscreen> {
  int _deg = 0;
  final String _image = 'images/ronaldo.png';

  void _rotateImage() {
    setState(() {
      _deg = _deg + 45;
      if (_deg == 360) _deg = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double angle = _deg * pi / 180;

    return Scaffold(
      appBar: AppBar(
        title: const Text('First Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Images :'),
            const SizedBox(height: 20),
            Transform.rotate(
              angle: angle,
              child: Image.asset(_image),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'second');
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _rotateImage,
        tooltip: 'Rotate',
        child: const Text('Rotate'),
      ),
    );
  }
}

// ─── Deuxième écran ───────────────────────────────────────────────
class Secondscreen extends StatelessWidget {
  const Secondscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back'),
        ),
      ),
    );
  }
}