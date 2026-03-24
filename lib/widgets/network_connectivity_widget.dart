import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NetworkConnectivityWidget extends StatefulWidget {
  final Widget child;
  
  const NetworkConnectivityWidget({
    super.key,
    required this.child,
  });

  @override
  State<NetworkConnectivityWidget> createState() => _NetworkConnectivityWidgetState();
}

class _NetworkConnectivityWidgetState extends State<NetworkConnectivityWidget> {
  bool _isConnected = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _checkConnectivity());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connected = await _hasInternetAccess();
    if (!mounted) return;
    if (connected != _isConnected) {
      setState(() {
        _isConnected = connected;
      });
    }
  }

  Future<bool> _hasInternetAccess() async {
    final uris = <Uri>[
      Uri.parse('https://clients3.google.com/generate_204'),
      Uri.parse('https://diet-health-app.onrender.com'),
    ];

    for (final uri in uris) {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 5);
        final request = await client.getUrl(uri).timeout(const Duration(seconds: 5));
        request.followRedirects = true;
        request.maxRedirects = 3;
        final response = await request.close().timeout(const Duration(seconds: 5));
        final ok = response.statusCode >= 200 && response.statusCode < 500;
        response.drain();
        client.close(force: true);
        if (ok) return true;
      } catch (_) {
        continue;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_isConnected)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: AppColors.error,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'No Internet Connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
