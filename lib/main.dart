import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waveforms',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Real-time Waveform'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int pixelsPerMs = 7;
  int msOverPage = 0;
  final int durationInMs = 100;
  List<double?> samples = [];
  final Random random = Random();
  Timer? timer;
  int replacementIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      msOverPage = (MediaQuery.of(context).size.width / pixelsPerMs).floor();
      samples = List.generate(msOverPage, (_) => null);
      startGeneratingFakeData();
    });
  }

  void startGeneratingFakeData() {
    timer = Timer.periodic(Duration(milliseconds: durationInMs), (timer) {
      setState(() {
        // Add a new random value between -1.0 and 1.0
        final double randomValue = random.nextDouble() * 2 - 1;

        samples[replacementIndex] = randomValue;
        const int nextXMany = 5;

        if (replacementIndex + nextXMany < msOverPage - 1) {
          samples[replacementIndex + nextXMany] = null;
        }
        replacementIndex =
            replacementIndex + 1 == msOverPage ? 0 : replacementIndex + 1;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: CustomPaint(
          painter: WaveformPainter(samples, msOverPage),
          child: const SizedBox(
            height: 200,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double?> samples;
  final int count;
  WaveformPainter(this.samples, this.count);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final paintCircle = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    const double radius = 3;
    final Path firstPath = Path();
    Path? secondPath;

    if (samples.isNotEmpty) {
      final height = size.height / 2;
      final width = size.width;
      final sampleInterval = samples.length >= width
          ? samples.length / width
          : width / samples.length;

      for (int index = 0; index < count; index++) {
        if (index == 0) {
          if (samples.last != null) {
            final double lastY =
                height - (samples.last! * height).clamp(-height, height);
            firstPath.moveTo(0, lastY);
            canvas.drawCircle(Offset(0, lastY), radius, paintCircle);
          }
        }

        if (samples[index] != null) {
          final double x = sampleInterval * (index + 1);
          final double y =
              height - (samples[index]! * height).clamp(-height, height);

          if (index != 0 &&
              samples[index] != null &&
              samples[index - 1] == null) {
            secondPath = Path();

            secondPath.moveTo(x, y);
            canvas.drawCircle(Offset(x, y), radius, paintCircle);
          } else {
            if (secondPath != null) {
              secondPath.lineTo(x, y);
            } else {
              firstPath.lineTo(x, y);
            }
          }
        }
      }

      canvas.drawPath(firstPath, paint);
      if (secondPath != null) {
        canvas.drawPath(secondPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
