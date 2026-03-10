import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

/// ─── Gyroscope Parallax Service ─────────────────────────────────────────────
/// Reads accelerometer + gyroscope data, converts to 3D rotation values
/// for the Scene camera. Uses smooth interpolation (lerp) for fluid motion.
///
/// Pipeline: Sensor Data → Filter → Convert to Rotation → Smooth Lerp → Output
/// ─────────────────────────────────────────────────────────────────────────────

class GyroscopeData {
  final double pitch; // X-axis tilt (forward/backward)
  final double yaw;   // Y-axis tilt (left/right)
  final double roll;  // Z-axis rotation

  const GyroscopeData({
    this.pitch = 0.0,
    this.yaw = 0.0,
    this.roll = 0.0,
  });

  GyroscopeData lerp(GyroscopeData target, double t) {
    return GyroscopeData(
      pitch: _lerpDouble(pitch, target.pitch, t),
      yaw: _lerpDouble(yaw, target.yaw, t),
      roll: _lerpDouble(roll, target.roll, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}

class GyroscopeService extends ChangeNotifier {
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;

  // Raw sensor values
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  double _gyroZ = 0.0;

  // Smoothed output
  GyroscopeData _currentData = const GyroscopeData();
  GyroscopeData _targetData = const GyroscopeData();

  // Configuration
  double sensitivity = 0.8;
  double smoothingFactor = 0.12; // Lower = smoother, more lag
  bool _isActive = false;

  GyroscopeData get data => _currentData;
  bool get isActive => _isActive;

  /// Convert current gyroscope data to a 3D rotation matrix
  /// for the Flutter Scene camera.
  vm.Matrix4 get rotationMatrix {
    final matrix = vm.Matrix4.identity();
    matrix.rotateX(_currentData.pitch * sensitivity);
    matrix.rotateY(_currentData.yaw * sensitivity);
    return matrix;
  }

  /// Start listening to device sensors.
  void startListening() {
    if (_isActive) return;
    _isActive = true;

    // Accelerometer gives device tilt (gravity-based).
    // We use it for the base orientation.
    _accelSubscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((event) {
      _accelX = event.x;
      _accelY = event.y;
      _updateTarget();
    });

    // Gyroscope gives angular velocity.
    // We integrate it for responsive, high-frequency rotation updates.
    _gyroSubscription = gyroscopeEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((event) {
      _gyroX = event.x;
      _gyroY = event.y;
      _gyroZ = event.z;
      _updateTarget();
    });

    notifyListeners();
  }

  /// Update the target rotation from raw sensor values.
  void _updateTarget() {
    // Combine accelerometer tilt + gyroscope angular velocity.
    // Accelerometer provides absolute tilt; gyroscope provides instant turn.
    // Clamp to prevent extreme rotations.
    final maxAngle = pi / 6; // 30 degrees max

    final pitch = (_accelX / 9.81).clamp(-1.0, 1.0) * maxAngle +
        _gyroX * 0.02; // small gyro contribution
    final yaw = (_accelY / 9.81).clamp(-1.0, 1.0) * maxAngle +
        _gyroY * 0.02;

    _targetData = GyroscopeData(
      pitch: pitch.clamp(-maxAngle, maxAngle),
      yaw: yaw.clamp(-maxAngle, maxAngle),
      roll: (_gyroZ * 0.05).clamp(-maxAngle / 2, maxAngle / 2),
    );
  }

  /// Call this every frame from the animation ticker to smoothly
  /// interpolate towards the target rotation.
  void updateSmoothing() {
    _currentData = _currentData.lerp(_targetData, smoothingFactor);
    notifyListeners();
  }

  /// Stop listening and reset to zero.
  void stopListening() {
    _accelSubscription?.cancel();
    _gyroSubscription?.cancel();
    _accelSubscription = null;
    _gyroSubscription = null;
    _isActive = false;
    _currentData = const GyroscopeData();
    _targetData = const GyroscopeData();
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
