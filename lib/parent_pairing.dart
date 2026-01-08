import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ParentPairingPage extends StatefulWidget {
  const ParentPairingPage({super.key});

  @override
  State<ParentPairingPage> createState() => _ParentPairingPageState();
}

class _ParentPairingPageState extends State<ParentPairingPage> {
  final TextEditingController _inputController = TextEditingController();
  bool _isInputEmpty = true;
  bool _isScanning = false;

  // Khởi tạo controller cho camera
  final MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.back,
    autoStart: false,
  );

  @override
  void initState() {
    super.initState();
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
    _inputController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  // Hàm bật tắt camera quét QR
  void _toggleScanner() async {
    if (_isScanning) {
      await cameraController.stop();
      setState(() => _isScanning = false);
    } else {
      setState(() => _isScanning = true);
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
        automaticallyImplyLeading: false,
        leading: _isScanning
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: _toggleScanner,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          _isScanning ? "Quét mã QR của con" : "Kết nối với con",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Giao diện chính khi không quét QR
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.family_restroom, size: 100, color: Color(0xFFFFA387)),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Vui lòng nhập mã kết nối hiển thị trên điện thoại của con bạn để bắt đầu liên kết.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 40),
                _buildInputCard(),
              ],
            ),
          ),

          // Lớp Camera phủ lên khi đang quét
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
                            HapticFeedback.heavyImpact();
                            setState(() {
                              _inputController.text = code;
                              _isScanning = false;
                            });
                            cameraController.stop();
                          }
                        }
                      },
                    ),
                    // Khung ngắm
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
              backgroundColor: const Color(0xFFFFA387),
              onPressed: _toggleScanner,
              child: const Icon(Icons.qr_code_scanner, color: Colors.white),
            ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nhập mã ghép nối",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _inputController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
            decoration: InputDecoration(
              hintText: "Mã ghép nối",
              hintStyle: TextStyle(
                color: Colors.black.withValues(alpha: 0.2),
                fontSize: 18,
                letterSpacing: 0,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isInputEmpty
                  ? null
                  : () {
                      debugPrint("Kết nối với mã: ${_inputController.text}");
                      // Xử lý logic kết nối tại đây
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA387),
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text(
                "KẾT NỐI NGAY",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
