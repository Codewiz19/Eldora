import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/medication_model.dart';
import 'medication_form_screen.dart';

class ElderMedicationScreen extends StatefulWidget {
  final String elderId;
  final String elderName;

  const ElderMedicationScreen({
    Key? key,
    required this.elderId,
    required this.elderName,
  }) : super(key: key);

  @override
  _ElderMedicationScreenState createState() => _ElderMedicationScreenState();
}

class _ElderMedicationScreenState extends State<ElderMedicationScreen> {
  bool _isLoading = true;
  List<MedicationModel> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final elderDoc = await FirebaseFirestore.instance
          .collection('elders')
          .doc(widget.elderId)
          .get();

      if (elderDoc.exists) {
        final elderData = elderDoc.data();
        if (elderData != null && elderData.containsKey('medications')) {
          final medicationsData = elderData['medications'] as List<dynamic>;

          setState(() {
            _medications = medicationsData
                .map((med) => MedicationModel.fromMap(med))
                .toList();
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading medications: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMedication(int index) async {
    try {
      // Get a copy of the current medications
      List<MedicationModel> updatedMedications = List.from(_medications);
      updatedMedications.removeAt(index);

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('elders')
          .doc(widget.elderId)
          .update({
        'medications': updatedMedications.map((med) => med.toMap()).toList(),
      });

      // Refresh the list
      await _loadMedications();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medication deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting medication: $e')),
      );
    }
  }

  String _getFormattedTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.elderName}\'s Medications'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _medications.isEmpty
              ? _buildEmptyState()
              : _buildMedicationsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicationFormScreen(
                elderId: widget.elderId,
                onSaved: _loadMedications,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Medication',
      ),
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
            'No Medications',
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
              'No medications have been added for ${widget.elderName} yet. Tap the + button to add a medication.',
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

  Widget _buildMedicationsList() {
    return RefreshIndicator(
      onRefresh: _loadMedications,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Medications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Manage ${widget.elderName}\'s medications',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ..._medications.asMap().entries.map((entry) {
            final index = entry.key;
            final medication = entry.value;
            return _buildMedicationCard(index, medication);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(int index, MedicationModel medication) {
    Color cardColor;

    // Assign different colors based on meal type
    switch (medication.mealType) {
      case 'Breakfast':
        cardColor = Colors.amber.shade100;
        break;
      case 'Lunch':
        cardColor = Colors.blue.shade100;
        break;
      case 'Dinner':
        cardColor = Colors.purple.shade100;
        break;
      default:
        cardColor = Colors.green.shade100;
    }

    return Dismissible(
      key: Key(medication.name + index.toString()),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Delete'),
              content: Text('Are you sure you want to delete this medication?'),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteMedication(index);
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardColor,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicationFormScreen(
                  elderId: widget.elderId,
                  onSaved: _loadMedications,
                  medication: medication,
                  index: index,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getFormattedTime(medication.scheduledTime),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Dosage: ${medication.dosage}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '${medication.mealRelation} ${medication.mealType}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                if (medication.photoUrl != null)
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(medication.photoUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.edit),
                      label: Text('Edit'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicationFormScreen(
                              elderId: widget.elderId,
                              onSaved: _loadMedications,
                              medication: medication,
                              index: index,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
