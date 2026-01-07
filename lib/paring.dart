import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PairingExpiredPage extends StatefulWidget {
  const PairingExpiredPage({super.key});

  @override
  State<PairingExpiredPage> createState() => _PairingExpiredPageState();
}

class _PairingExpiredPageState extends State<PairingExpiredPage> {
  String _pairingCode = "";
  Timer? _timer;
  int _secondsRemaining = 1800;
  final TextEditingController _inputController = TextEditingController();
  bool _isInputEmpty = true;
  bool _isScanning = false; 
  
  // Khởi tạo controller
  final MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.back,
    autoStart: false, // Tắt tự động chạy để kiểm soát bằng tay
  );

  @override
  void initState() {
    super.initState();
    _generateNewCode();
    _startTimer();
    _inputController.addListener(() {
      if (mounted) {
        setState(() {
          _isInputEmpty = _inputController.text.trim().isEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _inputController.dispose();
    cameraController.dispose(); 
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

  // Hàm bật tắt camera
  void _toggleScanner() async {
    if (_isScanning) {
      await cameraController.stop();
      setState(() => _isScanning = false);
    } else {
      setState(() => _isScanning = true);
      // Đợi một chút để UI render khung camera rồi mới start
      Future.delayed(const Duration(milliseconds: 100), () {
        cameraController.start();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F7),
        elevation: 0,
        automaticallyImplyLeading: false, // Tắt nút back mặc định
        leading: _isScanning 
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: _toggleScanner,
            )
          : null,
        title: Text(_isScanning ? "Đưa mã QR vào khung" : "Gia đình", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Nội dung chính của trang
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildCodeCard(),
                const SizedBox(height: 20),
                _buildInputCard(),
                const SizedBox(height: 30),
              ],
            ),
          ),
          
          // Lớp Camera phủ lên trên khi đang quét (không dùng Navigator)
          if (_isScanning)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String? code = barcodes.first.rawValue;
                          if (code != null) {
                            HapticFeedback.heavyImpact(); // Rung khi quét trúng
                            setState(() {
                              _inputController.text = code;
                              _isScanning = false;
                            });
                            cameraController.stop();
                          }
                        }
                      },
                    ),
                    // Khung ngắm màu trắng
                    Center(
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "Đang tìm mã QR...",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isScanning 
        ? null 
        : FloatingActionButton(
            backgroundColor: const Color(0xFFFFD54F),
            onPressed: _toggleScanner,
            child: const Icon(Icons.qr_code_scanner, color: Colors.black),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Text("Gửi mã ghép", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_pairingCode, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFFB300))),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.grey),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _pairingCode));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã sao chép mã!")));
                },
              ),
            ],
          ),
          Text("Mã hết hạn sau: ${_formatTime(_secondsRemaining)}", style: const TextStyle(color: Colors.red, fontSize: 13)),
          const SizedBox(height: 20),
          QrImageView(data: _pairingCode, size: 160, version: QrVersions.auto),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFE0B2), foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: const Text("Gửi mã", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Nhập mã đối tác", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 15),
          TextField(
            controller: _inputController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: "Nhập mã ghép nối", filled: true, fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isInputEmpty ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _isInputEmpty ? Colors.grey.shade300 : const Color(0xFFFFB300),
                foregroundColor: _isInputEmpty ? Colors.grey : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text("Kết nối", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
