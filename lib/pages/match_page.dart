// lib/pages/match_page.dart
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/api.dart';

class MatchPage extends StatefulWidget {
  final Map shop;
  const MatchPage({super.key, required this.shop});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

// ---- helper: String / num -> double ----
double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }
  return null;
}

class _MatchPageState extends State<MatchPage> {
  bool _busy = false;
  XFile? _photo;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    try {
      XFile? picked;

      if (kIsWeb) {
        picked = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 60,
        );
      } else if (Platform.isAndroid || Platform.isIOS) {
        picked = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 60,
        );
      } else {
        picked = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 60,
        );
        if (picked == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Windows la direct camera support illa.\nAndroid phone la run panna camera open aagum.',
              ),
            ),
          );
        }
      }

      if (picked != null) {
        setState(() => _photo = picked);
        await _checkAndLog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera error: $e')),
      );
    }
  }

  Future<void> _checkAndLog() async {
    setState(() => _busy = true);
    try {
      final user = context.read<AuthService>().user!;
      final shop = widget.shop;

      // current position
      final pos = await LocationService.getCurrentPosition();

      // shop lat/lng – String / num irunthaalum safe-a convert
      final shopLat = _toDouble(shop["lat"]);
      final shopLng = _toDouble(shop["lng"]);

      if (shopLat == null || shopLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop lat/lng set pannala. Sheet la values check pannunga.'),
          ),
        );
        return;
      }

      // distance calculate
      final distance = LocationService.distanceMeters(
        sLat: shopLat,
        sLng: shopLng,
        uLat: pos.latitude,
        uLng: pos.longitude,
      );

      final isMatch = distance <= LocationService.allowedRadius;
      final result = isMatch ? 'match' : 'mismatch';

      // server log
      final data = await Api.logCheckin(
        userId: user.id,
        shopId: shop["shop_id"],
        shopName: shop["shop_name"],
        salesman: user.name,
        lat: pos.latitude,
        lng: pos.longitude,
        distanceM: distance,
        result: result,
      );

      // 👉 idha ADD pannunga (new code)
      final serverMsg =
      data["ok"] == true ? "ok" : (data["error"] ?? "unknown");


      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            isMatch ? 'MATCH' : 'MISMATCH',
            style: TextStyle(
              color: isMatch ? Colors.green : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Server: $serverMsg\n'
                'Result: $result\n'
                'Distance: ${distance.toStringAsFixed(1)} m\n'
                'Allowed: ${LocationService.allowedRadius} m',
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.shop;

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D5DF6),
        title: Text(
          'Check-in: ${s["shop_name"]}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SHOP DETAILS CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor:
                      const Color(0xFF6D5DF6).withOpacity(0.12),
                      child: const Icon(
                        Icons.storefront,
                        color: Color(0xFF6D5DF6),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s["shop_name"]}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${s["shop_id"]}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Segment: ${s["segment"]}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lat: ${s["lat"]}, Lng: ${s["lng"]}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // PHOTO PREVIEW CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: _photo != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: kIsWeb
                      ? Image.network(
                    _photo!.path,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Image.file(
                    File(_photo!.path),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : Container(
                  height: 160,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.4),
                    ),
                  ),
                  child: const Text(
                    'No photo captured',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6D5DF6)),
                      foregroundColor: const Color(0xFF6D5DF6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _busy ? null : _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D5DF6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _busy ? null : _checkAndLog,
                    icon: _busy
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.check_circle),
                    label: const Text('Check & Log'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
