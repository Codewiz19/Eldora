// lib/screens/elder/fall_detection_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/fall_detection_service.dart';

class FallDetectionSettingsScreen extends StatefulWidget {
  const FallDetectionSettingsScreen({Key? key}) : super(key: key);

  @override
  State<FallDetectionSettingsScreen> createState() => _FallDetectionSettingsScreenState();
}

class _FallDetectionSettingsScreenState extends State<FallDetectionSettingsScreen> {
  final FallDetectionService _fallService = FallDetectionService();
  
  // Default values
  double _accelerationThreshold = 20.0;
  double _rotationThreshold = 2.5;
  int _countdownDuration = 10;
  
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _accelerationThreshold = prefs.getDouble('fallAccelerationThreshold') ?? 20.0;
      _rotationThreshold = prefs.getDouble('fallRotationThreshold') ?? 2.5;
      _countdownDuration = prefs.getInt('fallCountdownDuration') ?? 10;
      _isLoading = false;
    });
  }
  
  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setDouble('fallAccelerationThreshold', _accelerationThreshold);
      await prefs.setDouble('fallRotationThreshold', _rotationThreshold);
      await prefs.setInt('fallCountdownDuration', _countdownDuration);
      
      // Update service settings
      _fallService.setSensitivity(
        acceleration: _accelerationThreshold,
        rotation: _rotationThreshold,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _resetToDefaults() {
    setState(() {
      _accelerationThreshold = 20.0;
      _rotationThreshold = 2.5;
      _countdownDuration = 10;
    });
    
    _saveSettings();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fall Detection Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Adjust the sensitivity of fall detection. Lower values make detection more sensitive but may cause false alarms. Higher values require stronger movements to trigger detection.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Acceleration sensitivity
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Acceleration Sensitivity',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current: ${_accelerationThreshold.toStringAsFixed(1)} m/s²',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Slider(
                            value: _accelerationThreshold,
                            min: 10.0,
                            max: 30.0,
                            divisions: 20,
                            label: _accelerationThreshold.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _accelerationThreshold = value;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('More Sensitive'),
                              Text('Less Sensitive'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rotation sensitivity
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rotation Sensitivity',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current: ${_rotationThreshold.toStringAsFixed(1)} rad/s',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Slider(
                            value: _rotationThreshold,
                            min: 1.0,
                            max: 5.0,
                            divisions: 20,
                            label: _rotationThreshold.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _rotationThreshold = value;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('More Sensitive'),
                              Text('Less Sensitive'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Countdown duration
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SOS Countdown Duration',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current: $_countdownDuration seconds',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Slider(
                            value: _countdownDuration.toDouble(),
                            min: 5.0,
                            max: 30.0,
                            divisions: 25,
                            label: _countdownDuration.toString(),
                            onChanged: (value) {
                              setState(() {
                                _countdownDuration = value.toInt();
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Shorter Time'),
                              Text('Longer Time'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Settings'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Test fall detection
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Shake your device vigorously to test fall detection'),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Test Fall Detection'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}