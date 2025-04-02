import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/caretaker_model.dart';
import '../../services/auth_service.dart';
import 'elder_medication_screen.dart';

class CaretakerMedicationScreen extends StatefulWidget {
  @override
  _CaretakerMedicationScreenState createState() =>
      _CaretakerMedicationScreenState();
}

class _CaretakerMedicationScreenState extends State<CaretakerMedicationScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  List<DocumentSnapshot> _elders = [];

  @override
  void initState() {
    super.initState();
    _loadElders();
  }

  Future<void> _loadElders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final caretaker = await _authService.getCaretakerDetails(user.uid);

        if (caretaker != null && caretaker.elderIds.isNotEmpty) {
          final eldersData = await Future.wait(
            caretaker.elderIds.map((ref) => ref.get()),
          );

          setState(() {
            _elders = eldersData;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading elders: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Management'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _elders.isEmpty
              ? _buildEmptyState()
              : _buildEldersList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Elders Linked',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'You don\'t have any elders linked to your account yet. Elders can link to you using your email address.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEldersList() {
    return RefreshIndicator(
      onRefresh: _loadElders,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Select an Elder',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Choose an elder to manage their medications',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ..._elders.map((elder) => _buildElderCard(elder)).toList(),
        ],
      ),
    );
  }

  Widget _buildElderCard(DocumentSnapshot elder) {
    final data = elder.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown';
    final age = data['age'] ?? 0;
    final gender = data['gender'] ?? '';

    // Count medications if available
    int medicationCount = 0;
    if (data.containsKey('medications') && data['medications'] is List) {
      medicationCount = (data['medications'] as List).length;
    }

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ElderMedicationScreen(elderId: elder.id, elderName: name),
            ),
          ).then((_) => _loadElders()); // Refresh after returning
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'E',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Age: $age • $gender',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.medication,
                            size: 16, color: Theme.of(context).primaryColor),
                        SizedBox(width: 4),
                        Text(
                          '$medicationCount medications',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
