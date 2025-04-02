// // lib/screens/elder/elder_home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../services/auth_service.dart';
// import '../../models/elder_model.dart';
// import '../auth/auth_screen.dart';
// import 'link_caretaker_screen.dart';

// class ElderHomeScreen extends StatefulWidget {
//   @override
//   _ElderHomeScreenState createState() => _ElderHomeScreenState();
// }

// class _ElderHomeScreenState extends State<ElderHomeScreen> {
//   final AuthService _authService = AuthService();
//   bool _isLoading = true;
//   ElderModel? _elderData;

//   @override
//   void initState() {
//     super.initState();
//     _loadElderData();
//   }

//   Future<void> _loadElderData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       User? user = _authService.currentUser;
//       if (user != null) {
//         ElderModel? elderData = await _authService.getElderDetails(user.uid);
//         setState(() {
//           _elderData = elderData;
//         });
//       }
//     } catch (e) {
//       // Handle error
//       print('Error loading elder data: $e');
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
//         title: const Text('Elder Home'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.exit_to_app),
//             onPressed: _signOut,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _elderData == null
//               ? const Center(child: Text('Could not load profile data'))
//               : RefreshIndicator(
//                   onRefresh: _loadElderData,
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
//                                         Theme.of(context).colorScheme.primary,
//                                     child: Text(
//                                       _elderData!.name.isNotEmpty
//                                           ? _elderData!.name[0].toUpperCase()
//                                           : 'E',
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
//                                           _elderData!.name,
//                                           style: TextStyle(
//                                             fontSize: 22,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           'Age: ${_elderData!.age}',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           'Gender: ${_elderData!.gender}',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.grey[600],
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

//                       // Caretakers Section
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
//                                     'My Caretakers',
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: Icon(Icons.add_circle),
//                                     color:
//                                         Theme.of(context).colorScheme.primary,
//                                     onPressed: () {
//                                       Navigator.of(context)
//                                           .push(
//                                             MaterialPageRoute(
//                                               builder: (_) =>
//                                                   LinkCaretakerScreen(),
//                                             ),
//                                           )
//                                           .then((_) => _loadElderData());
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               if (_elderData!.caretakerIds.isEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 16.0),
//                                   child: Center(
//                                     child: Column(
//                                       children: [
//                                         Icon(
//                                           Icons.person_add_alt,
//                                           size: 48,
//                                           color: Colors.grey[400],
//                                         ),
//                                         const SizedBox(height: 16),
//                                         Text(
//                                           'No caretakers linked yet',
//                                           style: TextStyle(
//                                             color: Colors.grey[600],
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         ElevatedButton.icon(
//                                           icon: Icon(Icons.add),
//                                           label: Text('Link a Caretaker'),
//                                           onPressed: () {
//                                             Navigator.of(context)
//                                                 .push(
//                                                   MaterialPageRoute(
//                                                     builder: (_) =>
//                                                         LinkCaretakerScreen(),
//                                                   ),
//                                                 )
//                                                 .then((_) => _loadElderData());
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                               else
//                                 FutureBuilder(
//                                   future: Future.wait(
//                                     _elderData!.caretakerIds
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
//                                         child:
//                                             Text('Could not load caretakers'),
//                                       );
//                                     }

//                                     final caretakers = snapshot.data!;
//                                     return ListView.builder(
//                                       shrinkWrap: true,
//                                       physics: NeverScrollableScrollPhysics(),
//                                       itemCount: caretakers.length,
//                                       itemBuilder: (context, index) {
//                                         final caretaker = caretakers[index];
//                                         return ListTile(
//                                           leading: CircleAvatar(
//                                             backgroundColor: Colors.teal,
//                                             child: Text(
//                                               caretaker['name'][0]
//                                                   .toUpperCase(),
//                                               style: TextStyle(
//                                                   color: Colors.white),
//                                             ),
//                                           ),
//                                           title: Text(caretaker['name']),
//                                           subtitle: Text(caretaker['email']),
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
//                         'Quick Access',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       GridView.count(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 16,
//                         mainAxisSpacing: 16,
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         children: [
//                           _buildActionCard(
//                             context,
//                             'Medications',
//                             Icons.medication,
//                             Colors.red,
//                             () {},
//                           ),
//                           _buildActionCard(
//                             context,
//                             'Appointments',
//                             Icons.calendar_today,
//                             Colors.blue,
//                             () {},
//                           ),
//                           _buildActionCard(
//                             context,
//                             'Emergency',
//                             Icons.emergency,
//                             Colors.orange,
//                             () {},
//                           ),
//                           _buildActionCard(
//                             context,
//                             'Health Tips',
//                             Icons.favorite,
//                             Colors.green,
//                             () {},
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//     );
//   }

//   Widget _buildActionCard(
//     BuildContext context,
//     String title,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: color.withOpacity(0.2),
//               child: Icon(
//                 icon,
//                 size: 32,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/screens/elder/elder_home_screen.dart
 

 import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/sos_service.dart';
import '../../models/elder_model.dart';
import '../../models/sos_model.dart';
import '../auth/auth_screen.dart';
import 'link_caretaker_screen.dart';
import 'sos_button_screen.dart';

class ElderHomeScreen extends StatefulWidget {
  @override
  _ElderHomeScreenState createState() => _ElderHomeScreenState();
}

class _ElderHomeScreenState extends State<ElderHomeScreen> {
  final AuthService _authService = AuthService();
  final SOSService _sosService = SOSService();

  bool _isLoading = true;
  bool _isLoadingHistory = false;

  ElderModel? _elderData;
  List<SOSModel> _sosHistory = [];

  @override
  void initState() {
    super.initState();
    _loadElderData();
    _loadSOSHistory();
  }

  Future<void> _loadElderData() async {
    setState(() => _isLoading = true);

    try {
      User? user = _authService.currentUser;
      if (user != null) {
        ElderModel? elderData = await _authService.getElderDetails(user.uid);
        setState(() => _elderData = elderData);
      }
    } catch (e) {
      print('Error loading elder data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSOSHistory() async {
    setState(() => _isLoadingHistory = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        List<SOSModel> history = await _sosService.getElderSOSHistory(user.uid);
        setState(() => _sosHistory = history);
      }
    } catch (e) {
      print('Error loading SOS history: $e');
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _signOut() async {
    try {
      // Show confirmation dialog before signing out
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('SIGN OUT'),
            ),
          ],
        ),
      ) ?? false;
      
      if (!confirm) return;
      
      await _authService.signOut();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _elderData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Could not load profile data',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        onPressed: _loadElderData,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadElderData();
                    await _loadSOSHistory();
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildProfileSection(),
                      const SizedBox(height: 24),
                      _buildSOSButton(context),
                      const SizedBox(height: 24),
                      _buildQuickAccessSection(context),
                      const SizedBox(height: 24),
                      _buildCaretakersSection(),
                      const SizedBox(height: 24),
                      _buildSOSHistorySection(),
                    ],
                  ),
                ),
    );
  }

  /// Profile Section with improved visuals
  Widget _buildProfileSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  _elderData!.name.isNotEmpty
                      ? _elderData!.name[0].toUpperCase()
                      : 'E',
                  style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome,',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _elderData!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _elderData!.gender.toLowerCase() == 'male'
                              ? Icons.male
                              : Icons.female,
                          size: 16,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_elderData!.gender}, ${_elderData!.age} years',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SOS Button Section - moved up for better visibility
  Widget _buildSOSButton(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SOSButtonScreen()),
        ),
        icon: const Icon(Icons.warning_amber_rounded, size: 36),
        label: const Text(
          'EMERGENCY SOS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  /// Quick Access Section with improved card designs
  Widget _buildQuickAccessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildActionCard(
              context,
              'Medications',
              Icons.medication,
              Colors.red,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medications coming soon!')),
                );
              },
            ),
            _buildActionCard(
              context,
              'Appointments',
              Icons.calendar_today,
              Colors.blue,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointments coming soon!')),
                );
              },
            ),
            _buildActionCard(
              context,
              'Health Tips',
              Icons.favorite,
              Colors.green,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Health tips coming soon!')),
                );
              },
            ),
            _buildActionCard(
              context,
              'Video Call',
              Icons.video_call,
              Colors.purple,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video call coming soon!')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Caretakers Section with improved visuals
  Widget _buildCaretakersSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Caretakers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (_elderData!.caretakerIds.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) => LinkCaretakerScreen(),
                            ),
                          )
                          .then((_) => _loadElderData());
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _elderData!.caretakerIds.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Icon(Icons.person_add_alt,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No caretakers linked yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Link a Caretaker'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) => LinkCaretakerScreen(),
                                  ),
                                )
                                .then((_) => _loadElderData());
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  )
                : FutureBuilder(
                    future: Future.wait(
                      _elderData!.caretakerIds.map((ref) => ref.get()),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'No caretakers found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      }

                      final caretakers = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: caretakers.length,
                        itemBuilder: (context, index) {
                          final caretaker = caretakers[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.teal,
                                child: Text(
                                  caretaker['name'][0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              title: Text(
                                caretaker['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  caretaker['email'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.phone),
                                color: Colors.teal,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Calling ${caretaker['name']}...')),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  /// SOS History Section with improved visuals
  Widget _buildSOSHistorySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent SOS Alerts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _isLoadingHistory
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _sosHistory.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Colors.green[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No emergency alerts sent',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _sosHistory.length,
                        itemBuilder: (context, index) {
                          final sos = _sosHistory[index];
                          // Format the timestamp (assuming sos.timestamp exists)
                          String formattedDate = sos.timestamp != null
                              ? DateFormat('MMM dd, yyyy - hh:mm a').format(sos.timestamp)
                              : 'Unknown date';
                              
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red[700],
                                ),
                              ),
                              title: Text(
                                'Emergency Alert',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(formattedDate),
                                  if (sos.reason?.isNotEmpty ?? false)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Reason: ${sos.reason}',
                                        style: const TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              onTap: () {
                                // View SOS details
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('SOS details coming soon!')),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
