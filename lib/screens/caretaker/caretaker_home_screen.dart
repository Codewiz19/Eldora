// // lib/screens/caretaker/caretaker_home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../services/auth_service.dart';
// import '../../models/caretaker_model.dart';
// import '../auth/auth_screen.dart';
// import 'caretaker_medication_screen.dart';

// class CaretakerHomeScreen extends StatefulWidget {
//   @override
//   _CaretakerHomeScreenState createState() => _CaretakerHomeScreenState();
// }

// class _CaretakerHomeScreenState extends State<CaretakerHomeScreen> {
//   final AuthService _authService = AuthService();
//   bool _isLoading = true;
//   CaretakerModel? _caretakerData;

//   @override
//   void initState() {
//     super.initState();
//     _loadCaretakerData();
//   }

//   Future<void> _loadCaretakerData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       User? user = _authService.currentUser;
//       if (user != null) {
//         CaretakerModel? caretakerData =
//             await _authService.getCaretakerDetails(user.uid);
//         setState(() {
//           _caretakerData = caretakerData;
//         });
//       }
//     } catch (e) {
//       // Handle error
//       print('Error loading caretaker data: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _signOut() async {
//     try {
//       await _authService.signOut();
//       if (!mounted) return;

//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (_) => const AuthScreen()),
//       );
//     } catch (e) {
//       // Handle error
//       print('Error signing out: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Caretaker Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.exit_to_app),
//             onPressed: _signOut,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _caretakerData == null
//               ? const Center(child: Text('Could not load profile data'))
//               : RefreshIndicator(
//                   onRefresh: _loadCaretakerData,
//                   child: ListView(
//                     padding: const EdgeInsets.all(16.0),
//                     children: [
//                       // Profile Card
//                       Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 40,
//                                     backgroundColor:
//                                         Theme.of(context).colorScheme.secondary,
//                                     child: Text(
//                                       _caretakerData!.name.isNotEmpty
//                                           ? _caretakerData!.name[0]
//                                               .toUpperCase()
//                                           : 'C',
//                                       style: TextStyle(
//                                         fontSize: 32,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           _caretakerData!.name,
//                                           style: TextStyle(
//                                             fontSize: 22,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           _caretakerData!.email,
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           'Caretaker Profile',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             backgroundColor: Colors.teal[50],
//                                             color: Colors.teal,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Elders Section
//                       Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'My Elders',
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     '${_caretakerData!.elderIds.length} People',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               if (_caretakerData!.elderIds.isEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 32.0),
//                                   child: Center(
//                                     child: Column(
//                                       children: [
//                                         Icon(
//                                           Icons.people_alt_outlined,
//                                           size: 48,
//                                           color: Colors.grey[400],
//                                         ),
//                                         const SizedBox(height: 16),
//                                         Text(
//                                           'No elders linked yet',
//                                           style: TextStyle(
//                                             color: Colors.grey[600],
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           'Elders can link to you using your email address',
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             color: Colors.grey[600],
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                               else
//                                 FutureBuilder(
//                                   future: Future.wait(
//                                     _caretakerData!.elderIds
//                                         .map((ref) => ref.get()),
//                                   ),
//                                   builder: (context, snapshot) {
//                                     if (snapshot.connectionState ==
//                                         ConnectionState.waiting) {
//                                       return const Center(
//                                         child: Padding(
//                                           padding: EdgeInsets.all(16.0),
//                                           child: CircularProgressIndicator(),
//                                         ),
//                                       );
//                                     }

//                                     if (!snapshot.hasData) {
//                                       return const Center(
//                                         child: Text('Could not load elders'),
//                                       );
//                                     }

//                                     final elders = snapshot.data!;
//                                     return ListView.builder(
//                                       shrinkWrap: true,
//                                       physics: NeverScrollableScrollPhysics(),
//                                       itemCount: elders.length,
//                                       itemBuilder: (context, index) {
//                                         final elder = elders[index];
//                                         return Card(
//                                           elevation: 2,
//                                           margin:
//                                               EdgeInsets.symmetric(vertical: 8),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                           ),
//                                           child: ListTile(
//                                             leading: CircleAvatar(
//                                               backgroundColor: Colors.blue,
//                                               child: Text(
//                                                 elder['name'][0].toUpperCase(),
//                                                 style: TextStyle(
//                                                     color: Colors.white),
//                                               ),
//                                             ),
//                                             title: Text(
//                                               elder['name'],
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold),
//                                             ),
//                                             subtitle: Text(
//                                               'Age: ${elder['age']} • ${elder['gender']}',
//                                             ),
//                                             trailing: IconButton(
//                                               icon:
//                                                   Icon(Icons.arrow_forward_ios),
//                                               onPressed: () {
//                                                 // Navigate to detailed view of this elder
//                                                 _navigateToElderDetails(
//                                                     elder.id);
//                                               },
//                                             ),
//                                             onTap: () {
//                                               // Navigate to detailed view of this elder
//                                               _navigateToElderDetails(elder.id);
//                                             },
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Quick Access Cards
//                       Text(
//                         'Quick Actions',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Quick action cards grid
//                       GridView.count(
//                         crossAxisCount: 2,
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         mainAxisSpacing: 16,
//                         crossAxisSpacing: 16,
//                         children: [
//                           // Notifications card
//                           _buildQuickActionCard(
//                             context,
//                             icon: Icons.notifications,
//                             title: 'Notifications',
//                             color: Colors.orange,
//                             onTap: () {
//                               // Navigate to notifications screen
//                             },
//                           ),

//                           // Medication reminders card
//                           _buildQuickActionCard(
//                             context,
//                             icon: Icons.medication,
//                             title: 'Medication',
//                             color: Colors.green,
//                             onTap: () {
//                               // Navigate to medication alerts screen
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (_) => CaretakerMedicationScreen(),
//                                 ),
//                               );
//                             },
//                           ),

//                           // Emergency contacts card
//                           _buildQuickActionCard(
//                             context,
//                             icon: Icons.emergency,
//                             title: 'Emergency Contacts',
//                             color: Colors.red,
//                             onTap: () {
//                               // Navigate to emergency contacts screen
//                             },
//                           ),

//                           // Settings card
//                           _buildQuickActionCard(
//                             context,
//                             icon: Icons.settings,
//                             title: 'Settings',
//                             color: Colors.blue,
//                             onTap: () {
//                               // Navigate to settings screen
//                             },
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                     ],
//                   ),
//                 ),
//     );
//   }

//   Widget _buildQuickActionCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 48,
//                 color: color,
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateToElderDetails(String elderId) {
//     // Navigate to the elder details screen
//     // Navigator.of(context).push(
//     //   MaterialPageRoute(
//     //     builder: (_) => ElderDetailsScreen(elderId: elderId),
//     //   ),
//     // );
//     // Uncomment and implement ElderDetailsScreen when needed
//   }
// }

// lib/screens/caretaker/caretaker_home_screen.dart

// lib/screens/caretaker/caretaker_home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting timestamps
import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';
import '../../models/caretaker_model.dart';
import '../auth/auth_screen.dart';
import 'caretaker_medication_screen.dart';
import 'sos_details_screen.dart';

class CaretakerHomeScreen extends StatefulWidget {
  @override
  _CaretakerHomeScreenState createState() => _CaretakerHomeScreenState();
}

class _CaretakerHomeScreenState extends State<CaretakerHomeScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  CaretakerModel? _caretakerData;

  List<Map<String, dynamic>> _activeSOSAlerts = [];

  @override
  void initState() {
    super.initState();
    _initializeFCM();
    _loadCaretakerData();
    _loadActiveSOSAlerts();
  }

  /// Initialize FCM for push notifications
  void _initializeFCM() {
    FCMService().initialize(context);
    FCMService().checkInitialMessage(context);
  }

  /// Load caretaker data
  Future<void> _loadCaretakerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _authService.currentUser;
      if (user != null) {
        CaretakerModel? caretakerData =
            await _authService.getCaretakerDetails(user.uid);
        setState(() {
          _caretakerData = caretakerData;
        });
      }
    } catch (e) {
      print('Error loading caretaker data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load active SOS alerts for linked elders
  Future<void> _loadActiveSOSAlerts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot caretakerDoc =
            await _firestore.collection('caretakers').doc(user.uid).get();

        if (caretakerDoc.exists) {
          Map<String, dynamic> caretakerData =
              caretakerDoc.data() as Map<String, dynamic>;

          List<DocumentReference> elderRefs =
              List<DocumentReference>.from(caretakerData['elderIds'] ?? []);

          List<Map<String, dynamic>> activeAlerts = [];

          for (DocumentReference elderRef in elderRefs) {
            QuerySnapshot sosSnapshot = await elderRef
                .collection('sos_alerts')
                .where('resolved', isEqualTo: false)
                .orderBy('timestamp', descending: true)
                .get();

            DocumentSnapshot elderDoc = await elderRef.get();
            String elderName = elderDoc.exists
                ? (elderDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown'
                : 'Unknown';

            for (QueryDocumentSnapshot sosDoc in sosSnapshot.docs) {
              Map<String, dynamic> sosData =
                  sosDoc.data() as Map<String, dynamic>;

              activeAlerts.add({
                'elderId': elderRef.id,
                'elderName': elderName,
                'sosId': sosDoc.id,
                'timestamp': (sosData['timestamp'] as Timestamp).toDate(),
              });
            }
          }

          activeAlerts.sort((a, b) => (b['timestamp'] as DateTime)
              .compareTo(a['timestamp'] as DateTime));

          setState(() {
            _activeSOSAlerts = activeAlerts;
          });
        }
      }
    } catch (e) {
      print('Error loading active SOS alerts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Sign out
  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Navigate to SOS Details screen
  void _navigateToSOSDetails(String sosId, String elderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SOSDetailsScreen(
          sosId: sosId,
          elderId: elderId,
        ),
      ),
    ).then((_) {
      _loadActiveSOSAlerts(); // Refresh alerts after returning
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caretaker Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadCaretakerData();
                await _loadActiveSOSAlerts();
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Profile Card
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  // SOS Alerts Section
                  _buildSOSAlertsSection(),
                  const SizedBox(height: 24),
                  // Quick Actions
                  _buildQuickActions(),
                ],
              ),
            ),
    );
  }

  /// Build Profile Card Widget
  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            _caretakerData!.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          _caretakerData!.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_caretakerData!.email),
      ),
    );
  }

  /// Build SOS Alerts Section Widget
  Widget _buildSOSAlertsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _activeSOSAlerts.isNotEmpty
          ? Colors.red.shade100
          : Colors.green.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _activeSOSAlerts.isNotEmpty
                ? 'ACTIVE EMERGENCIES'
                : 'No Active Emergencies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _activeSOSAlerts.isNotEmpty
                  ? Colors.red.shade800
                  : Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          _activeSOSAlerts.isEmpty
              ? const Text('All elders are safe.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activeSOSAlerts.length,
                  itemBuilder: (context, index) {
                    var alert = _activeSOSAlerts[index];
                    return ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text('EMERGENCY: ${alert['elderName']}'),
                      subtitle: Text(
                        'Time: ${DateFormat('MMM dd, yyyy - hh:mm a').format(alert['timestamp'])}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _navigateToSOSDetails(
                        alert['sosId'],
                        alert['elderId'],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  /// Build Quick Actions Section Widget
  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildQuickActionCard(
          context,
          icon: Icons.notifications,
          title: 'Notifications',
          color: Colors.orange,
          onTap: () {
            // Navigate to notifications screen
          },
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.medication,
          title: 'Medication',
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CaretakerMedicationScreen(),
              ),
            );
          },
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.emergency,
          title: 'Emergency Contacts',
          color: Colors.red,
          onTap: () {
            // Navigate to emergency contacts screen
          },
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.settings,
          title: 'Settings',
          color: Colors.blue,
          onTap: () {
            // Navigate to settings screen
          },
        ),
      ],
    );
  }

  /// Build Quick Action Card Widget
  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
