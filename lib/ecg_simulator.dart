import 'dart:async';
import 'dart:math';

class ECGSimulator {
  final StreamController<double> _ecgStreamController =
      StreamController<double>();
  Timer? _timer;
  int _timeIndex = 0;
  final Random _random = Random();
  final double minValue = -1;
  final double maxValue = 1;
  final double timeOffset = pi / 2;

  ECGSimulator() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final double newData = _generateFakeECGWaveform(_timeIndex++);
      final double normalizedData = _normalize(newData);

      _ecgStreamController.add(normalizedData);
    });
  }

  Stream<double> get ecgStream => _ecgStreamController.stream;
  void stop() {
    _timer?.cancel();
    _ecgStreamController.close();
  }

  double _normalize(double value) {
    return 2 * ((value - minValue) / (maxValue - minValue)) - 1;
  }

  double _generateFakeECGWaveform(int index) {
    double t = (index / 50.0 * 4 * pi) * timeOffset;
    double ecgValue = _generateECGWaveform(t);

    ecgValue += (_random.nextDouble() - 0.5) / 5;

    if (_random.nextDouble() < 0.05) {
      ecgValue += (_random.nextDouble() - 0.5) * 2;
    }

    return ecgValue;
  }

  double _generateECGWaveform(double t) {
    // Simple model to generate the P, QRS, and T waves
    double pWave = 0.1 * sin(2 * pi * t); // Small sine wave for the P wave
    double qrsComplex = _qrsFunction(t); // Sharp QRS complex
    double tWave = 0.2 * sin(pi * t / 4); // Broad T wave
    return pWave + qrsComplex + tWave;
  }

  double _qrsFunction(double t) {
    // Simulating the QRS complex (sharp peak)
    double q = -exp(-pow(t - pi / 2, 2) / 0.01); // Small Q wave
    double r1 = 3 * exp(-pow(t - pi, 2) / 0.05); // Large R wave (sharp peak)
    double r2 = 2 *
        exp(-pow(t - pi * 1.2, 2) /
            0.05); // Secondar R wave (smaller, sharp peak)
    double s = -exp(-pow(t - 3 * pi / 2, 2) / 0.01); // Small S wave
    return q + r1 + r2 + s;
  }
}
