import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class LiftClubScreen extends StatefulWidget {
  const LiftClubScreen({super.key});

  @override
  State<LiftClubScreen> createState() => _LiftClubScreenState();
}

class _LiftClubScreenState extends State<LiftClubScreen> {
  final _picker = ImagePicker();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _timeController = TextEditingController();
  final _priceController = TextEditingController();
  final _whatsappController = TextEditingController();

  bool _postingRide = false;
  bool _uploadingLicense = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: VibeScaffold(
        appBar: AppBar(
          title: const Text('Lift Club'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Find a Lift'),
              Tab(text: 'Offer a Lift'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calculate_outlined),
              tooltip: 'Fuel Split Calculator',
              onPressed: _showFuelCalculator,
            ),
          ],
        ),
        body: TabBarView(children: [_buildFindTab(), _buildOfferTab()]),
      ),
    );
  }

  Widget _buildFindTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('lift_rides')
          .orderBy('departureTime')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading rides: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rides = snapshot.data!.docs;
        if (rides.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No rides yet. Be the first to offer one!'),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: rides.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ride = rides[index];
            final data = ride.data();
            final from = data['from'] as String? ?? 'Campus';
            final to = data['to'] as String? ?? 'Destination';
            final time = data['departureTime'] as String? ?? 'Soon';
            final price = data['price'] as String? ?? '--';
            final driver = data['driverName'] as String? ?? 'Driver';
            final whatsapp = data['whatsapp'] as String?;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$from → $to',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Departure: $time'),
                    Text('Driver: $driver'),
                    Text('Contribution: $price'),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: whatsapp == null
                            ? null
                            : () => _contactDriver(whatsapp, to),
                        icon: const Icon(Icons.chat),
                        label: const Text('WhatsApp Driver'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOfferTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Sign in to offer rides.'));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userData = snapshot.data!.data() ?? {};
        final isVerified = userData['isVerifiedDriver'] == true;
        final whatsapp = (userData['whatsapp'] as String?)?.trim();
        if (_whatsappController.text.isEmpty && whatsapp != null) {
          _whatsappController.text = whatsapp;
        }

        if (isVerified) {
          return _buildRideForm(userData);
        }

        return _buildDriverOnboarding(user.uid);
      },
    );
  }

  Widget _buildDriverOnboarding(String uid) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('driver_applications')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final status = snapshot.data?.data()?['status'] as String?;
        final isPending = status == 'pending';
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPending ? Icons.verified_outlined : Icons.drive_eta,
                size: 72,
                color: Colors.white70,
              ),
              const SizedBox(height: 16),
              Text(
                isPending
                    ? 'Your driver verification is pending. We will notify you soon.'
                    : 'Share your license to become a verified OG driver and earn fares.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isPending || _uploadingLicense
                    ? null
                    : () => _submitDriverApplication(uid),
                icon: _uploadingLicense
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  isPending ? 'Pending Verification' : 'Become a Driver',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRideForm(Map<String, dynamic> userData) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Post a ride and let vibers hop in. Payments happen off-platform.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _fromController,
              decoration: const InputDecoration(
                labelText: 'From (e.g. Braam campus)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(labelText: 'To (destination)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Departure time'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Seat contribution (R)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'WhatsApp contact'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _postingRide ? null : () => _postRide(userData),
                icon: _postingRide
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_postingRide ? 'Posting...' : 'Share Ride'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _postRide(Map<String, dynamic> userData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    final time = _timeController.text.trim();
    final price = _priceController.text.trim();
    final whatsapp = _whatsappController.text.trim();

    if ([from, to, time, price, whatsapp].any((element) => element.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    setState(() => _postingRide = true);
    try {
      await FirebaseFirestore.instance.collection('lift_rides').add({
        'from': from,
        'to': to,
        'departureTime': time,
        'price': 'R$price',
        'whatsapp': whatsapp,
        'driverId': user.uid,
        'driverName': userData['name'] ?? 'OG Driver',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _fromController.clear();
      _toController.clear();
      _timeController.clear();
      _priceController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ride posted!')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to post ride: $error')));
    } finally {
      if (mounted) {
        setState(() => _postingRide = false);
      }
    }
  }

  Future<void> _submitDriverApplication(String uid) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (picked == null) {
      return;
    }

    setState(() => _uploadingLicense = true);
    try {
      final storageRef = FirebaseStorage.instance.ref(
        'driver_licenses/$uid-${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final bytes = await picked.readAsBytes();
      await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('driver_applications')
          .doc(uid)
          .set({
            'licenseUrl': downloadUrl,
            'status': 'pending',
            'submittedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted. Hang tight!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _uploadingLicense = false);
      }
    }
  }

  Future<void> _contactDriver(String whatsapp, String destination) async {
    final encoded = Uri.encodeComponent(
      'Hi! Is there still a seat to $destination?',
    );
    final uri = Uri.parse('https://wa.me/$whatsapp?text=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('WhatsApp launch failed.')));
    }
  }

  void _showFuelCalculator() {
    final distanceController = TextEditingController();
    double? total;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Fuel Split Calculator'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: distanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Distance in KM',
                    ),
                  ),
                  if (total != null) ...[
                    const SizedBox(height: 12),
                    Text('Estimated fuel: R${total!.toStringAsFixed(2)}'),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final distance = double.tryParse(
                      distanceController.text.trim(),
                    );
                    if (distance == null) {
                      return;
                    }
                    setState(() => total = distance * 2.5);
                  },
                  child: const Text('Calculate'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
