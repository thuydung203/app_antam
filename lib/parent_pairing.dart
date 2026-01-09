import 'dart:async';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class ParentPairingPage extends StatefulWidget {
  const ParentPairingPage({super.key});

  @override
  State<ParentPairingPage> createState() => _ParentPairingPageState();
}

class _ParentPairingPageState extends State<ParentPairingPage> {
  final TextEditingController _inputController = TextEditingController();
  bool _isInputEmpty = true;
  bool _isScanning = false;
  bool _isConnecting = false;

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

  // LOGIC KẾT NỐI: 1 CHA MẸ CHỈ CÓ 1 CON THEO DÕI
  Future<void> _handleConnect() async {
    final String code = _inputController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isConnecting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final parent = authProvider.userModel;

      if (parent == null) throw "Vui lòng đăng nhập lại.";

      // KIỂM TRA: Nếu Cha Mẹ đã có con theo dõi rồi thì báo lỗi ngay
      if (parent.childId != null && parent.childId!.isNotEmpty) {
        throw "Tài khoản của bạn đã được kết nối với một người con khác.";
      }

      // 1. Tìm mã của Con trong collection pairing_codes
      final doc = await FirebaseFirestore.instance.collection('pairing_codes').doc(code).get();

      if (!doc.exists) {
        throw "Mã kết nối không hợp lệ hoặc đã hết hạn.";
      }

      final data = doc.data()!;
      final String childId = data['childId'];
      final DateTime expiresAt = (data['expiresAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) {
        throw "Mã đã hết hạn. Vui lòng yêu cầu mã mới từ con.";
      }

      // --- THỰC HIỆN KẾT NỐI ---

      // A. Cập nhật cho CON (Người theo dõi): Thêm thông tin CHA MẸ vào danh sách 'following'
      final Map<String, dynamic> parentInfo = {
        'uid': parent.uid,
        'name': parent.name,
        'avatar': parent.avatar,
        'phone': parent.phone,
        'age': parent.age,
        'role': 'parent',
        'connectedAt': DateTime.now(),
      };

      await FirebaseFirestore.instance.collection('users').doc(childId).update({
        'following': FieldValue.arrayUnion([parentInfo]) 
      });

      // B. Cập nhật cho CHA MẸ (Người được theo dõi): Lưu ID của CON vào 'childId' (duy nhất)
      await FirebaseFirestore.instance.collection('users').doc(parent.uid).update({
        'childId': childId,
      });

      // 2. Xóa mã sau khi dùng xong
      await FirebaseFirestore.instance.collection('pairing_codes').doc(code).delete();

      if (mounted) {
        await authProvider.reloadUserModel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cho phép con theo dõi thành công!")),
        );
        Navigator.pop(context); 
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

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
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.family_restroom, size: 100, color: Color(0xFFFFA387)),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Nhập mã từ điện thoại của con để cho phép con theo dõi sức khỏe của bạn.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 40),
                _buildInputCard(),
              ],
            ),
          ),

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
                            _handleConnect();
                          }
                        }
                      },
                    ),
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
                  ],
                ),
              ),
            ),
          
          if (_isConnecting)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: Color(0xFFFFA387))),
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
            "Nhập mã ghép nối từ con",
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
              hintText: "Mã 7 chữ số",
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
              onPressed: _isInputEmpty || _isConnecting ? null : _handleConnect,
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
