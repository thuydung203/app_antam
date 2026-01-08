import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PairingExpiredPage extends StatefulWidget {
  const PairingExpiredPage({super.key});

  @override
  State<PairingExpiredPage> createState() => _PairingExpiredPageState();
}

class _PairingExpiredPageState extends State<PairingExpiredPage> {
  String _pairingCode = "";
  Timer? _timer;
  int _secondsRemaining = 1800;

  @override
  void initState() {
    super.initState();
    _generateNewCode();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateNewCode() {
    final random = Random();
    setState(() {
      _pairingCode = (random.nextInt(9000000) + 1000000).toString();
      _secondsRemaining = 1800;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _generateNewCode();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F7),
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: const Text(
          "Gia đình", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildCodeCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        children: [
          const Text("Gửi mã ghép", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _pairingCode, 
                style: const TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFFFFB300)
                )
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.grey),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _pairingCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã sao chép mã!"))
                  );
                },
              ),
            ],
          ),
          Text(
            "Mã hết hạn sau: ${_formatTime(_secondsRemaining)}", 
            style: const TextStyle(color: Colors.red, fontSize: 13)
          ),
          const SizedBox(height: 20),
          QrImageView(data: _pairingCode, size: 160, version: QrVersions.auto),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
