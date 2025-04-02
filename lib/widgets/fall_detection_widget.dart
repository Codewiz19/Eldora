// lib/widgets/fall_detection_widget.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/services/fall_detection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FallDetectionWidget extends StatefulWidget {
  final String elderId;
  final String elderName;
  final String? emergencyContact;
  
  const FallDetectionWidget({
    Key? key,
    required this.elderId,
    required this.elderName,
    this.emergencyContact,
  }) : super(key: key);

  @override
  State<FallDetectionWidget> createState() => _FallDetectionWidgetState();
}

class _FallDetectionWidgetState extends State<FallDetectionWidget> {
  final FallDetectionService _fallService = FallDetectionService();
  bool _isMonitoring = false;
  bool _fallDetected = false;
  int _countdown = 10;
  Timer? _countdownTimer;
  
  @override
  void initState() {
    super.initState();
    _loadMonitoringState();
  }
  
  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadMonitoringState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMonitoring = prefs.getBool('fallDetectionActive') ?? false;
      if (_isMonitoring) {
        _startMonitoring();
      }
    });
  }
  
  Future<void> _saveMonitoringState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fallDetectionActive', value);
  }
  
  void _startMonitoring() {
    _fallService.startMonitoring(
      onFallDetected: _handleFallDetected,
      onSendingSOS: _handleSendingSOS,
      onSOSSent: _handleSOSSent,
      onSOSCancelled: _handleSOSCancelled,
      onError: _handleError,
    );
    
    _saveMonitoringState(true);
    
    setState(() {
      _isMonitoring = true;
    });
  }
  
  void _stopMonitoring() {
    _fallService.stopMonitoring();
    _countdownTimer?.cancel();
    
    _saveMonitoringState(false);
    
    setState(() {
      _isMonitoring = false;
      _fallDetected = false;
      _countdown = 10;
    });
  }
  
  void _handleFallDetected() {
    setState(() {
      _fallDetected = true;
    });
    
    // Start countdown for SOS
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          // Send SOS when countdown reaches zero
          _fallService.sendSOS(
            elderId: widget.elderId,
            elderName: widget.elderName,
            emergencyContact: widget.emergencyContact,
          );
          _countdownTimer?.cancel();
        }
      });
    });
  }
  
  void _handleSendingSOS() {
    // Show sending indicator if needed
  }
  
  void _handleSOSSent(String sosId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('SOS alert sent successfully'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Reset the detection state
    setState(() {
      _fallDetected = false;
      _countdown = 10;
    });
  }
  
  void _handleSOSCancelled() {
    _countdownTimer?.cancel();
    
    setState(() {
      _fallDetected = false;
      _countdown = 10;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('SOS alert cancelled'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  void _handleError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red,
      ),
    );
    
    // Reset the detection state
    setState(() {
      _fallDetected = false;
      _countdown = 10;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fall Detection',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          _isMonitoring ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: _isMonitoring ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isMonitoring,
                      onChanged: (value) {
                        if (value) {
                          _startMonitoring();
                        } else {
                          _stopMonitoring();
                        }
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        if (_fallDetected) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.red[100],
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'FALL DETECTED!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sending SOS in $_countdown seconds',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _fallService.cancelSOS(),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: const Text('I\'m OK - Cancel SOS'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}