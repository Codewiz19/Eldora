import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../models/medication_model.dart';

class MedicationFormScreen extends StatefulWidget {
  final String elderId;
  final Function onSaved;
  final MedicationModel? medication;
  final int? index;

  const MedicationFormScreen({
    Key? key,
    required this.elderId,
    required this.onSaved,
    this.medication,
    this.index,
  }) : super(key: key);

  @override
  _MedicationFormScreenState createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();

  String _mealRelation = 'After';
  String _mealType = 'Breakfast';
  TimeOfDay _scheduledTime = TimeOfDay(hour: 8, minute: 0);
  File? _imageFile;
  String? _currentPhotoUrl;

  List<String> _mealRelationOptions = ['Before', 'After'];
  List<String> _mealTypeOptions = ['Breakfast', 'Lunch', 'Dinner'];

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      // Editing existing medication
      _nameController.text = widget.medication!.name;
      _dosageController.text = widget.medication!.dosage;
      _mealRelation = widget.medication!.mealRelation;
      _mealType = widget.medication!.mealType;
      _scheduledTime = TimeOfDay(
          hour: widget.medication!.scheduledTime.hour,
          minute: widget.medication!.scheduledTime.minute);
      _currentPhotoUrl = widget.medication!.photoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );
    if (picked != null && picked != _scheduledTime) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _currentPhotoUrl;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('medication_images')
          .child(
              '${widget.elderId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_imageFile!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image if selected
      final String? photoUrl = await _uploadImage();

      // Convert TimeOfDay to DateTime
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );

      // Create medication object
      final medication = MedicationModel(
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        mealRelation: _mealRelation,
        mealType: _mealType,
        scheduledTime: scheduledDateTime,
        photoUrl: photoUrl,
      );

      // Get current medications array
      final elderDoc = await FirebaseFirestore.instance
          .collection('elders')
          .doc(widget.elderId)
          .get();

      List<dynamic> medicationsData = [];
      if (elderDoc.exists) {
        final data = elderDoc.data();
        if (data != null && data.containsKey('medications')) {
          medicationsData = List.from(data['medications']);
        }
      }

      // Update or add medication
      if (widget.index != null) {
        // Update existing medication
        medicationsData[widget.index!] = medication.toMap();
      } else {
        // Add new medication
        medicationsData.add(medication.toMap());
      }

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('elders')
          .doc(widget.elderId)
          .update({'medications': medicationsData});

      // Notify parent and navigate back
      widget.onSaved();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medication saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving medication: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.medication == null ? 'Add Medication' : 'Edit Medication'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // Medication Image
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : _currentPhotoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(_currentPhotoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: _imageFile == null && _currentPhotoUrl == null
                            ? Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey[400],
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tap to add a photo (optional)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Medication Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Medication Name',
                      prefixIcon: Icon(Icons.medication),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the medication name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Dosage
                  TextFormField(
                    controller: _dosageController,
                    decoration: InputDecoration(
                      labelText: 'Dosage (e.g., "1 tablet", "5ml")',
                      prefixIcon: Icon(Icons.straighten),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the dosage';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Meal Relation (Before/After)
                  Text(
                    'When to take',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: _mealRelationOptions.map((option) {
                          return Expanded(
                            child: RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue: _mealRelation,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _mealRelation = value!;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Meal Type (Breakfast/Lunch/Dinner)
                  Text(
                    'Meal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: _mealTypeOptions.map((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _mealType,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _mealType = value!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Time Picker
                  Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Scheduled Time',
                            style: TextStyle(fontSize: 16),
                          ),
                          Row(
                            children: [
                              Text(
                                '${_scheduledTime.hour.toString().padLeft(2, '0')}:${_scheduledTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.access_time),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: _saveMedication,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Medication',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
