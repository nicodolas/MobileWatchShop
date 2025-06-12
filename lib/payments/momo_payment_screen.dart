import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MomoPaymentScreen extends StatelessWidget {
  final String qrUrl; // Link thanh toán của Momo API trả về
  final Duration timeout;

  const MomoPaymentScreen({
    super.key,
    required this.qrUrl,
    required this.timeout,
  });

  Future<void> _launchMomoOrUrl(BuildContext context) async {
    final momoScheme = Uri.parse('momo://');
    final fallbackUri = Uri.parse(qrUrl);

    if (await canLaunchUrl(momoScheme)) {
      await launchUrl(momoScheme);
    } else if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không mở được liên kết thanh toán')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán QR Momo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: qrUrl,
                size: 250,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Dùng app Momo để quét mã QR trên màn hình để thanh toán.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _launchMomoOrUrl(context),
                child: const Text('Mở app Momo hoặc trang thanh toán'),
              ),
              const SizedBox(height: 10),
              CountdownTimer(timeout: timeout),
            ],
          ),
        ),
      ),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  final Duration timeout;

  const CountdownTimer({super.key, required this.timeout});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeout.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingSeconds <= 0) {
      return const Text(
        'Mã QR đã hết hạn.',
        style: TextStyle(fontSize: 14, color: Colors.red),
      );
    }
    return Text(
      'Thời gian còn lại: $formattedTime',
      style: const TextStyle(fontSize: 14, color: Colors.grey),
    );
  }
}
