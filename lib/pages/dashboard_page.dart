import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api.dart';
import '../services/auth_service.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  List _logs = [];

  int todayTotal = 0;
  int todayMatch = 0;
  int todayMismatch = 0;

  int allTotal = 0;
  int allMatch = 0;
  int allMismatch = 0;

  late Map<String, Map<String, int>> last7days;

  // Animation
  late AnimationController _backController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    last7days = {};
    _load();

    _backController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _slideAnimation =
        Tween(begin: Offset.zero, end: const Offset(-1.3, 0)).animate(
          CurvedAnimation(parent: _backController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _backController.dispose();
    super.dispose();
  }

  // 🗓 Today's date
  String _todayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // 🗓 Last 7 days
  List<String> _last7DateStrings() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final dt = now.subtract(Duration(days: i));
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    }).reversed.toList();
  }

  // 🔄 Load logs
  Future<void> _load() async {
    try {
      final user = context.read<AuthService>().user!;
      final logs = await Api.getLogs(user.id);

      final last7Keys = _last7DateStrings();
      last7days = {
        for (var d in last7Keys) d: {"total": 0, "match": 0, "mismatch": 0}
      };

      final todayStr = _todayString();

      int tT = 0, tM = 0, tX = 0;
      int aT = 0, aM = 0, aX = 0;

      for (final l in logs) {
        String raw = "${l['date'] ?? ''}";
        if (raw.length > 10) raw = raw.substring(0, 10);

        final date = raw;
        final result = (l['result'] ?? '').toLowerCase();

        aT++;
        if (result == 'match') aM++;
        if (result == 'mismatch') aX++;

        if (date == todayStr) {
          tT++;
          if (result == 'match') tM++;
          if (result == 'mismatch') tX++;
        }

        if (last7days.containsKey(date)) {
          final m = last7days[date]!;
          m["total"] = (m["total"] ?? 0) + 1;
          if (result == 'match') m["match"] = (m["match"] ?? 0) + 1;
          if (result == 'mismatch') m["mismatch"] = (m["mismatch"] ?? 0) + 1;
        }
      }

      setState(() {
        _logs = logs;
        todayTotal = tT;
        todayMatch = tM;
        todayMismatch = tX;
        allTotal = aT;
        allMatch = aM;
        allMismatch = aX;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ⭐ Smooth Back Navigation
  Future<void> _performBack() async {
    await _backController.forward();
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6D5DF6),
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leadingWidth: 120,

        leading: Row(
          children: [
            const SizedBox(width: 6),

            // 🔙 Animated back
            SlideTransition(
              position: _slideAnimation,
              child: GestureDetector(
                onTap: _performBack,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8E2DE2),
                        Color(0xFF4A00E0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 20),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ☰ MENU
            Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.all(8),
                    child:
                    const Icon(Icons.menu, color: Colors.white, size: 26),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF6D5DF6)),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildGreetingCard(user),
            const SizedBox(height: 16),
            _buildTodaySummary(),
            const SizedBox(height: 16),
            _buildOverallSummary(),
            const SizedBox(height: 16),
            _buildLast7Days(),
          ],
        ),
      ),
    );
  }

  // -------------------- UI COMPONENTS --------------------

  Widget _buildGreetingCard(user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Hi ${user.name}',
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 4),
            Text('Total logs: $allTotal',
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary() {
    final percent = todayTotal == 0 ? 0 : (todayMatch * 100 / todayTotal);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today summary",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _smallStat(label: "Check-ins", value: todayTotal),
                _smallStat(
                    label: "Match", value: todayMatch, color: Colors.green),
                _smallStat(
                    label: "Mismatch",
                    value: todayMismatch,
                    color: Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            Text("Match %: ${percent.toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallSummary() {
    final percent = allTotal == 0 ? 0 : (allMatch * 100 / allTotal);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Overall summary",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _smallStat(label: "Total", value: allTotal),
                _smallStat(label: "Match", value: allMatch, color: Colors.green),
                _smallStat(
                    label: "Mismatch", value: allMismatch, color: Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            Text("Match %: ${percent.toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildLast7Days() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Last 7 days",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            ..._last7DateStrings().map((d) {
              final m =
                  last7days[d] ?? {"total": 0, "match": 0, "mismatch": 0};

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d, style: const TextStyle(fontSize: 14)),
                    Text(
                      "T:${m["total"]}  M:${m["match"]}  X:${m["mismatch"]}",
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _smallStat({
    required String label,
    required int value,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
