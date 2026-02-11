import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geek_toolbox/core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GEEK TOOLBOX')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StatusPanel(),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _ModuleCard(
                    title: 'CODE-TO-VIDEO',
                    subtitle: 'Generate Hacker-Style Videos',
                    icon: Icons.movie_filter_outlined,
                    onTap: () {
                      context.push('/code-to-video');
                    },
                  ),
                  _ModuleCard(
                    title: 'MESH MESSENGER',
                    subtitle: 'Off-Grid Communication',
                    icon: Icons.radar_outlined,
                    onTap: () {
                      context.push('/mesh-messenger');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SYSTEM STATUS',
                style: TextStyle(
                  color: AppTheme.primaryColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'ONLINE',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Icon(
            Icons.shield_outlined,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primaryColor),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icon, size: 48, color: AppTheme.primaryColor),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppTheme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
