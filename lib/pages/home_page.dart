// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'shops_page.dart';
import 'history_page.dart';
import 'dashboard_page.dart'; // 👈 NEW IMPORT

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'master':
        return Colors.redAccent;
      case 'manager_fmcg':
      case 'manager_pipes':
      case 'manager':
        return Colors.blueAccent;
      case 'sales_fmcg':
      case 'sales_pipes':
      case 'sales':
        return Colors.deepPurple;
      case 'accounts':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user!;
    final role = user.role; // master / manager_fmcg / sales_pipes ...
    final segment = user.segment; // fmcg / pipes / all

    final isMaster = role == 'master';
    final isManager = role.startsWith('manager');
    final isSales = role.startsWith('sales');
    final isFmcg = segment.contains('fmcg') || segment == 'all';
    final isPipes = segment.contains('pipes') || segment == 'all';

    final roleColor = _roleColor(role);

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D5DF6),
        title: const Text(
          'ABHINAV AGENCY APP',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // ROLE BADGE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              backgroundColor: roleColor.withOpacity(0.15),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user,
                    size: 16,
                    color: roleColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // ✅ 1. session clear
              await context.read<AuthService>().logout();
              // ✅ 2. all routes clear, go to LoginPage
              // (back button press pannalum home-ku thirumba vara koodadhu)
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6D5DF6), // blueish purple
              Color(0xFFCFA8FF), // light purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // TOP WELCOME CARD
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        color: Colors.black.withOpacity(0.18),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: roleColor.withOpacity(0.12),
                        child: Icon(
                          Icons.person,
                          color: roleColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user.name}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Role: ${role.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Segment: ${segment.isEmpty ? '-' : segment.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 13,
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

              const SizedBox(height: 8),

              // DASHBOARD TILES IN WHITE BOX
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView(
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.05,
                        ),
                        children: [
                          // DASHBOARD (NEW)
                          _DashboardTile(
                            icon: Icons.dashboard,
                            title: 'Dashboard',
                            subtitle: 'Summary & stats',
                            color: Colors.teal,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DashboardPage(),
                                ),
                              );
                            },
                          ),

                          // Check-in
                          _DashboardTile(
                            icon: Icons.my_location,
                            title: 'Check-In',
                            subtitle: 'Location match / mismatch',
                            color: Colors.deepPurple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ShopsPage(),
                                ),
                              );
                            },
                          ),

                          // My Shops
                          _DashboardTile(
                            icon: Icons.storefront,
                            title: 'My Shops',
                            subtitle: isSales
                                ? 'Assigned shops only'
                                : 'Segment wise shops',
                            color: Colors.indigo,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ShopsPage(),
                                ),
                              );
                            },
                          ),

                          // History
                          _DashboardTile(
                            icon: Icons.history,
                            title: 'History',
                            subtitle: isMaster
                                ? 'All users activity'
                                : 'Your check-in logs',
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HistoryPage(),
                                ),
                              );
                            },
                          ),

                          // FMCG Summary
                          if (isMaster || (isManager && isFmcg))
                            _DashboardTile(
                              icon: Icons.inventory_2,
                              title: 'FMCG Summary',
                              subtitle: 'Manager view',
                              color: Colors.pinkAccent,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                    Text('FMCG summary coming soon'),
                                  ),
                                );
                              },
                            ),

                          // Pipes Summary
                          if (isMaster || (isManager && isPipes))
                            _DashboardTile(
                              icon: Icons.plumbing,
                              title: 'Pipes Summary',
                              subtitle: 'Manager view',
                              color: Colors.orange,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                    Text('Pipes summary coming soon'),
                                  ),
                                );
                              },
                            ),

                          // Admin
                          if (isMaster)
                            _DashboardTile(
                              icon: Icons.admin_panel_settings,
                              title: 'Admin',
                              subtitle: 'Master control (future)',
                              color: Colors.redAccent,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Admin panel will be added later'),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  const _DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.96),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
