import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';
import '../services/auth_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List logs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final user = context.read<AuthService>().user!;
    logs = await Api.getLogs(user.id);
    logs = logs.reversed.toList();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D5DF6),
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
          ? const Center(
        child: Text(
          'No history found',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          setState(() => loading = true);
          await load();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, i) {
            final l = logs[i] ?? {};

            final shopId = '${l['shop_id'] ?? ''}'.trim();
            final shopName = '${l['shop_name'] ?? ''}'.trim();
            final salesman = '${l['salesman'] ?? ''}'.trim();
            final date = '${l['date'] ?? ''}'.trim();
            final time = '${l['time'] ?? ''}'.trim();

            final resultRaw =
            '${l['result'] ?? ''}'.trim().toLowerCase();
            final distanceStr =
            '${l['distance_m'] ?? ''}'.trim();

            final isMatch = resultRaw == 'match';
            final tagColor =
            isMatch ? Colors.green : Colors.redAccent;
            final tagText = isMatch ? 'MATCH' : 'MISMATCH';

            double? distanceM;
            try {
              distanceM = double.tryParse(distanceStr);
            } catch (_) {
              distanceM = null;
            }

            // Title: "CAT – Alex" / only shop / only salesman
            final title = (() {
              if (shopName.isEmpty && salesman.isEmpty) {
                return 'Shop $shopId';
              } else if (shopName.isEmpty) {
                return salesman;
              } else if (salesman.isEmpty) {
                return shopName;
              } else {
                return '$shopName – $salesman';
              }
            })();

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID LINE
                    Text(
                      'ID: ${shopId.isEmpty ? '-' : shopId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // TITLE + STATUS TAG
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isMatch
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color: tagColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tagText,
                                style: TextStyle(
                                  color: tagColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // DATE + TIME
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date.isEmpty ? '-' : date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time.isEmpty ? '-' : time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // DISTANCE
                    if (distanceM != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.social_distance,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Distance: ${distanceM.toStringAsFixed(1)} m',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 4),

                    // MATCH / MISMATCH TEXT
                    Row(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isMatch
                              ? 'Location matched'
                              : 'Location mismatched',
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
            );
          },
        ),
      ),
    );
  }
}
