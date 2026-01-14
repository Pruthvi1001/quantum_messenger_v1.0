import 'package:flutter/material.dart';
import 'package:quantum_messenger41/ui/colors.dart';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  double _batteryLevel = 50;
  double _urgency = 2;
  double _trust = 3;

  final Map<int, String> _urgencyLabels = {
    1: 'Low',
    2: 'Medium',
    3: 'High',
  };

  final Map<int, String> _trustLabels = {
    1: 'Untrusted',
    2: 'Known',
    3: 'Trusted',
  };

  final List<Map<String, dynamic>> _algorithms = [
    {'name': 'AES-256 + SHA-3', 'color': disasterAmber, 'icon': Icons.bolt},
    {'name': 'ChaCha20-Poly1305', 'color': disasterOrange, 'icon': Icons.security},
    {'name': 'Kyber-1024 + Dilithium5', 'color': disasterGreen, 'icon': Icons.shield},
    {'name': 'Kyber-512 + Dilithium2', 'color': disasterOrange, 'icon': Icons.lock},
    {'name': 'X25519 + Ed25519', 'color': disasterAmber, 'icon': Icons.speed},
  ];

  Map<String, dynamic> _getCurrentAlgorithm() {
    if (_batteryLevel < 20) {
      return _algorithms[0];
    } else if (_urgency > 2 && _trust > 2) {
      return _algorithms[2];
    } else if (_urgency > 1 && _trust < 2) {
      return _algorithms[1];
    } else if (_batteryLevel > 80 && _urgency < 2) {
      return _algorithms[4];
    }
    return _algorithms[3];
  }

  @override
  Widget build(BuildContext context) {
    final currentAlgo = _getCurrentAlgorithm();

    return Scaffold(
      backgroundColor: disasterDark,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: disasterDark,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Policy Engine',
                  style: TextStyle(
                    color: disasterText,
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                Text(
                  'Crypto-agile algorithm selection',
                  style: TextStyle(
                    color: disasterTextMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            toolbarHeight: 80,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: disasterOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.info_outline, color: disasterOrange),
                  onPressed: () {
                    _showInfoDialog(context);
                  },
                ),
              ),
            ],
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Active Algorithm Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (currentAlgo['color'] as Color).withOpacity(0.2),
                        (currentAlgo['color'] as Color).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (currentAlgo['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (currentAlgo['color'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              currentAlgo['icon'] as IconData,
                              color: currentAlgo['color'] as Color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active Algorithm',
                                  style: TextStyle(
                                    color: disasterTextMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentAlgo['name'] as String,
                                  style: TextStyle(
                                    color: currentAlgo['color'] as Color,
                                    fontFamily: 'Roboto Mono',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: disasterDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: glassBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Security', _getSecurityLevel(), disasterGreen),
                            Container(width: 1, height: 30, color: glassBorder),
                            _buildStatItem('Speed', _getSpeedLevel(), disasterAmber),
                            Container(width: 1, height: 30, color: glassBorder),
                            _buildStatItem('Battery', _getBatteryImpact(), disasterOrange),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Sliders
                _buildSliderCard(
                  icon: Icons.battery_charging_full,
                  label: 'Battery Level',
                  value: _batteryLevel,
                  min: 0,
                  max: 100,
                  displayValue: '${_batteryLevel.toInt()}%',
                  color: _batteryLevel < 20 ? disasterRed : _batteryLevel < 50 ? disasterAmber : disasterGreen,
                  onChanged: (value) => setState(() => _batteryLevel = value),
                ),
                const SizedBox(height: 16),
                _buildSliderCard(
                  icon: Icons.priority_high,
                  label: 'Message Urgency',
                  value: _urgency,
                  min: 1,
                  max: 3,
                  steps: 2,
                  displayValue: _urgencyLabels[_urgency.toInt()]!,
                  color: _urgency == 3 ? disasterRed : _urgency == 2 ? disasterAmber : disasterGreen,
                  onChanged: (value) => setState(() => _urgency = value),
                ),
                const SizedBox(height: 16),
                _buildSliderCard(
                  icon: Icons.verified_user,
                  label: 'Peer Trust Level',
                  value: _trust,
                  min: 1,
                  max: 3,
                  steps: 2,
                  displayValue: _trustLabels[_trust.toInt()]!,
                  color: _trust == 3 ? disasterGreen : _trust == 2 ? disasterAmber : disasterRed,
                  onChanged: (value) => setState(() => _trust = value),
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: disasterTextMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _getSecurityLevel() {
    if (_urgency > 2 && _trust > 2) return 'Max';
    if (_batteryLevel < 20) return 'Good';
    return 'High';
  }

  String _getSpeedLevel() {
    if (_batteryLevel > 80 && _urgency < 2) return 'Fast';
    if (_urgency > 2) return 'Slow';
    return 'Med';
  }

  String _getBatteryImpact() {
    if (_batteryLevel < 20) return 'Low';
    if (_urgency > 2) return 'High';
    return 'Med';
  }

  Widget _buildSliderCard({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required Color color,
    required ValueChanged<double> onChanged,
    int? steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: glassCardDecoration(borderRadius: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: disasterText,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: steps,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: disasterSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: glassBorder),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: disasterOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.security, color: disasterOrange, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Crypto-Agility',
              style: TextStyle(
                color: disasterText,
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The policy engine automatically selects the optimal encryption algorithm based on:',
              style: TextStyle(color: disasterTextMuted, height: 1.5),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(Icons.battery_full, 'Battery level - conserve power when low'),
            _buildInfoItem(Icons.priority_high, 'Message urgency - stronger encryption for critical messages'),
            _buildInfoItem(Icons.verified_user, 'Peer trust - adjust based on relationship'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: disasterOrange)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: disasterOrange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: disasterText, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}