import 'dart:async';
import 'dart:convert';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:antam_app/models/user_model.dart';
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

  // LOGIC KẾT NỐI
  Future<void> _handleConnect() async {
    final String code = _inputController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isConnecting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final parent = authProvider.userModel;

      if (parent == null) throw "Vui lòng đăng nhập lại.";

      if (parent.childId != null && parent.childId!.isNotEmpty) {
        throw "Tài khoản này đã kết nối với một người con khác.";
      }

      final doc = await FirebaseFirestore.instance.collection('pairing_codes').doc(code).get();
      if (!doc.exists) throw "Mã kết nối không hợp lệ hoặc đã hết hạn.";

      final data = doc.data()!;
      final String childId = data['childId'];
      final String childName = data['childName'] ?? "Con của bạn";
      final String? childAvatar = data['childAvatar'];
      final DateTime expiresAt = (data['expiresAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) throw "Mã đã hết hạn.";

      final Map<String, dynamic> parentInfo = {
        'uid': parent.uid,
        'name': parent.name,
        'avatar': parent.avatar,
        'phone': parent.phone,
        'age': parent.age,
        'role': 'parent',
        'connectedAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('users').doc(childId).update({
        'following': FieldValue.arrayUnion([parentInfo])
      });

      await FirebaseFirestore.instance.collection('users').doc(parent.uid).update({
        'childId': childId,
        'childName': childName,
        'childAvatar': childAvatar,
      });

      await FirebaseFirestore.instance.collection('pairing_codes').doc(code).delete();

      if (mounted) {
        await authProvider.reloadUserModel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kết nối thành công!")),
        );
        setState(() {
          _isConnecting = false;
          _inputController.clear();
        });
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
    final user = Provider.of<AuthProvider>(context).userModel;
    final bool isConnected = user?.childId != null && user!.childId!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(isConnected ? "Người giám sát" : "Kết nối gia đình",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                if (isConnected)
                  _buildConnectedProfile(user!.childId!)
                else ...[
                  const Icon(Icons.family_restroom, size: 100, color: Color(0xFFFFA387)),
                  const SizedBox(height: 20),
                  _buildInputSection(),
                ]
              ],
            ),
          ),
          if (_isScanning) _buildCameraOverlay(),
          if (_isConnecting) _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: (_isScanning || isConnected)
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFFFFA387),
              onPressed: _toggleScanner,
              child: const Icon(Icons.qr_code_scanner, color: Colors.white),
            ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const Text(
            "Vui lòng nhập mã kết nối từ điện thoại của con để bắt đầu liên kết.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          _buildInputCard(),
        ],
      ),
    );
  }

  Widget _buildConnectedProfile(String childId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(childId).snapshots(),
      builder: (context, snapshot) {
        String name = "Con của bạn";
        String? avatar;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? name;
          avatar = data['avatar'];
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const Text(
                  "TÀI KHOẢN ĐANG GIÁM SÁT",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFFFC1A8),
                  backgroundImage: (avatar != null && avatar.isNotEmpty)
                      ? MemoryImage(base64Decode(avatar))
                      : null,
                  child: (avatar == null || avatar.isEmpty)
                      ? const Icon(Icons.person, size: 70, color: Colors.white)
                      : null,
                ),

                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Đã kết nối và đang bảo vệ bạn",
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 50),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "Người này có thể xem lịch trình uống thuốc, vị trí và nhận cảnh báo SOS của bạn.",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _inputController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
            decoration: InputDecoration(
              hintText: "Nhập mã 7 chữ số",
              hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.2), fontSize: 18, letterSpacing: 0),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("KẾT NỐI NGAY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final String? code = capture.barcodes.first.rawValue;
                if (code != null) {
                  setState(() { _inputController.text = code; _isScanning = false; });
                  cameraController.stop();
                  _handleConnect();
                }
              },
            ),
            Center(child: Container(width: 260, height: 260, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(20)))),
            Positioned(top: 40, left: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: _toggleScanner)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: Color(0xFFFFA387))));
  }
}
