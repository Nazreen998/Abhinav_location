import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    var permission = await Geolocator.checkPermission();

    setState(() {
      _locationEnabled =
          serviceEnabled && (permission == LocationPermission.always || permission == LocationPermission.whileInUse);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // CAMERA
              GestureDetector(
                onTap: () async {
                  final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  if (picked != null) {
                    setState(() => _image = File(picked.path));
                  }
                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.photo_camera, size: 38, color: Colors.deepPurple),
                    SizedBox(height: 8),
                    Text("Camera"),
                  ],
                ),
              ),

              // GALLERY
              GestureDetector(
                onTap: () async {
                  final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                  if (picked != null) {
                    setState(() => _image = File(picked.path));
                  }
                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.photo, size: 38, color: Colors.deepPurple),
                    SizedBox(height: 8),
                    Text("Gallery"),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isMaster = user.role.toLowerCase() == "master";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6D5DF6),
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ----- TOP HEADER -----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),

              child: Column(
                children: [
                  // PROFILE PHOTO with glow
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: _image != null ? FileImage(_image!) : null,
                          backgroundColor: Colors.white,
                          child: _image == null
                              ? Text(
                            user.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          )
                              : null,
                        ),
                      ),

                      // UPLOAD ICON
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.deepPurple, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),

                  // ROLE + SEGMENT
                  Text(
                    "${user.role.toUpperCase()} | ${user.segment.toUpperCase()}",
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                  ),

                  const SizedBox(height: 8),

                  // ONLINE / OFFLINE STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _locationEnabled ? Colors.greenAccent : Colors.redAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _locationEnabled ? "Online" : "Offline",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ----- INFO CARDS -----
            _infoCard(Icons.person, "Name", user.name),
            _infoCard(Icons.phone, "Phone", user.id),
            _infoCard(Icons.security, "Role", user.role),
            _infoCard(Icons.category, "Segment", user.segment),

            const SizedBox(height: 25),

            // MASTER ONLY — EDIT PROFILE
            if (isMaster)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditProfilePage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.green],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // LOGOUT BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  context.read<AuthService>().logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.redAccent, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 12,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Logout",
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // -------- INFO CARD WIDGET ---------
  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF6D5DF6).withOpacity(0.12),
            child: Icon(icon, color: const Color(0xFF6D5DF6)),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
