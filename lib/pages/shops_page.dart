// lib/pages/shops_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';
import '../services/auth_service.dart';
import 'match_page.dart';

class ShopsPage extends StatefulWidget {
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  List shops = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final user = context.read<AuthService>().user!;
    shops = await Api.getShops(user.id); // same logic
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D5DF6),
        title: const Text(
          'My Shops',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: shops.length,
          itemBuilder: (_, i) {
            final s = shops[i] ?? {};
            final name = '${s["shop_name"] ?? "-"}';
            final segment = '${s["segment"] ?? "-"}';
            final id = '${s["shop_id"] ?? "-"}';

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchPage(shop: s),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                        const Color(0xFF6D5DF6).withOpacity(0.12),
                        child: const Icon(
                          Icons.storefront,
                          color: Color(0xFF6D5DF6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: $id',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.category,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Segment: $segment',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
