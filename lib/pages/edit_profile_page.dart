import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController segmentCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().user!;
    nameCtrl = TextEditingController(text: user.name);
    phoneCtrl = TextEditingController(text: user.id);
    segmentCtrl = TextEditingController(text: user.segment);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D5DF6),
        title: const Text("Edit Profile"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _input("Name", nameCtrl),
            const SizedBox(height: 16),
            _input("Phone", phoneCtrl),
            const SizedBox(height: 16),
            _input("Segment", segmentCtrl),

            const Spacer(),

            GestureDetector(
              onTap: () {
                // TODO: connect to your backend update API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile Updated (UI Only)")),
                );
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.teal, Colors.green],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text("Save",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String title, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
              )
            ],
          ),
          child: TextField(
            controller: ctrl,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        )
      ],
    );
  }
}
