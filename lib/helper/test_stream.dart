import 'dart:math';

Stream<double> testStream() async* {
  while(true) {
    await Future.delayed(const Duration(milliseconds: 500));
    yield Random().nextDouble();
  }
}