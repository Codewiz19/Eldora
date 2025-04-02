import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../services/sos_service.dart';
import '../../models/sos_model.dart';

class SOSDetailsScreen extends StatefulWidget {
  final String sosId;
  final String elderId;

  const SOSDetailsScreen({
    Key? key,
    required this.sosId,
    required this.elderId,
  }) : super(key: key);

  @override
  _SOSDetailsScreenState createState() => _SOSDetailsScreenState();
}

class _SOSDetailsScreenState extends State<SOSDetailsScreen> {
  final SOSService _sosService = SOSService();
  bool _isLoading = true;
  SOSModel? _sosModel;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadSOSDetails();
  }

  Future<void> _loadSOSDetails() async {
    try {
      SOSModel sosModel = await _sosService.getSOSAlert(
        widget.elderId,
        widget.sosId,
      );

      setState(() {
        _sosModel = sosModel;
        _isLoading = false;

        // Add marker for SOS location
        _markers.add(
          Marker(
            markerId: MarkerId('sos_location'),
            position: LatLng(
              sosModel.location.latitude,
              sosModel.location.longitude,
            ),
            infoWindow: InfoWindow(
              title: 'SOS Location',
              snippet: 'Elder: ${sosModel.elderName}',
            ),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading SOS details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS Alert'),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sosModel == null
              ? const Center(child: Text('SOS alert not found'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Alert header
                      Container(
                        width: double.infinity,
                        color: Colors.red.shade100,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EMERGENCY ALERT',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Elder: ${_sosModel!.elderName}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Time: ${DateFormat('MMM dd, yyyy - hh:mm a').format(_sosModel!.timestamp)}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  _sosModel!.resolved
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: _sosModel!.resolved
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _sosModel!.resolved
                                      ? 'Resolved'
                                      : 'Active Emergency',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _sosModel!.resolved
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Location map
                      Container(
                        height: 300,
                        width: double.infinity,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              _sosModel!.location.latitude,
                              _sosModel!.location.longitude,
                            ),
                            zoom: 16,
                          ),
                          markers: _markers,
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                        ),
                      ),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _openMapsApp,
                              icon: const Icon(Icons.directions),
                              label: const Text('Navigate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _callEmergencyServices,
                              icon: const Icon(Icons.call),
                              label: const Text('Call 911'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Image section (if available)
                      if (_sosModel!.mediaUrl != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Situation Photo:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _sosModel!.mediaUrl!,
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Resolve button
                      if (!_sosModel!.resolved)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton.icon(
                            onPressed: _resolveSOSAlert,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Mark as Resolved'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  void _openMapsApp() async {
    if (_sosModel == null) return;

    final lat = _sosModel!.location.latitude;
    final lng = _sosModel!.location.longitude;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open maps app')),
      );
    }
  }

  void _callEmergencyServices() async {
    const url = 'tel:911';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open phone app')),
      );
    }
  }

  Future<void> _resolveSOSAlert() async {
    try {
      await _sosService.resolveSOSAlert(widget.elderId, widget.sosId);

      setState(() {
        if (_sosModel != null) {
          _sosModel = SOSModel(
            id: _sosModel!.id,
            elderId: _sosModel!.elderId,
            elderName: _sosModel!.elderName,
            timestamp: _sosModel!.timestamp,
            location: _sosModel!.location,
            mediaUrl: _sosModel!.mediaUrl,
            resolved: true,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SOS alert marked as resolved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resolving SOS alert: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
