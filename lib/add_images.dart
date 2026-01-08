import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; // Ẩn AuthProvider của firebase_auth
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};
  
  List<QueryDocumentSnapshot> _currentDocs = [];
  late Stream<QuerySnapshot> _imageStream;

  @override
  void initState() {
    super.initState();
    _imageStream = _firestore
        .collection('images')
        .where('userId', isEqualTo: _auth.currentUser?.uid ?? '')
        .snapshots();
  }

  Future<void> _pickAndUploadImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 20, 
    );

    if (images.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final String userId = _auth.currentUser?.uid ?? 'unknown';
      
      for (var image in images) {
        final File file = File(image.path);
        final Uint8List bytes = await file.readAsBytes();
        String base64String = base64Encode(bytes);

        await _firestore.collection('images').add({
          'base64String': base64String,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tải lên ${images.length} ảnh thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSelectedImages() async {
    try {
      for (String id in _selectedIds) {
        await _firestore.collection('images').doc(id).delete();
      }
      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
    } catch (e) {
      debugPrint("Lỗi khi xóa: $e");
    }
  }

  void _selectAll() {
    setState(() {
      for (var doc in _currentDocs) {
        _selectedIds.add(doc.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userName = authProvider.userModel?.name ?? "Người dùng";
        final String? avatarBase64 = authProvider.userModel?.avatar;

        return Scaffold(
          backgroundColor: const Color(0xFFFFF7F7),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopInfo(userName, avatarBase64),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _imageStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("Lỗi: ${snapshot.error}"));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      _currentDocs = snapshot.data!.docs.toList();
                      _currentDocs.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aTime = aData['createdAt'] as Timestamp?;
                        final bTime = bData['createdAt'] as Timestamp?;
                        if (aTime == null || bTime == null) return 0;
                        return bTime.compareTo(aTime);
                      });

                      if (_currentDocs.isEmpty) {
                        return const Center(child: Text("Album trống. Nhấn + để thêm ảnh."));
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          itemCount: _currentDocs.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            final doc = _currentDocs[index];
                            final String id = doc.id;
                            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                            final String base64Str = data['base64String'] ?? '';
                            bool isSelected = _selectedIds.contains(id);

                            return GestureDetector(
                              onTap: () {
                                if (_isSelectionMode) {
                                  setState(() {
                                    if (isSelected) _selectedIds.remove(id);
                                    else _selectedIds.add(id);
                                  });
                                }
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.memory(
                                        base64Decode(base64Str),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        gaplessPlayback: true,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Center(child: Icon(Icons.check_circle, color: Colors.blue, size: 30)),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                if (_isLoading) const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: CircularProgressIndicator(),
                ),
                if (!_isSelectionMode)
                  GestureDetector(
                    onTap: _pickAndUploadImages,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.add, size: 26),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildFooter(userName),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildTopInfo(String userName, String? avatarBase64) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFFFC1A8),
            backgroundImage: (avatarBase64 != null && avatarBase64.isNotEmpty)
                ? MemoryImage(base64Decode(avatarBase64))
                : null,
            child: (avatarBase64 == null || avatarBase64.isEmpty)
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 80, 
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      userName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _isSelectionMode
                      ? [
                          TextButton(
                            onPressed: _selectAll, 
                            child: const Text("Chọn tất cả", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: _selectedIds.isEmpty ? Colors.grey : Colors.red),
                            onPressed: _selectedIds.isEmpty ? null : _deleteSelectedImages,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isSelectionMode = false;
                                _selectedIds.clear();
                              });
                            }, 
                            child: const Text("Hủy", style: TextStyle(color: Colors.red))
                          ),
                        ]
                      : [
                          TextButton(onPressed: () => setState(() => _isSelectionMode = true), child: const Text("Chọn")),
                          const Icon(Icons.more_horiz),
                        ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(String userName) {
    return StreamBuilder<QuerySnapshot>(
      stream: _imageStream,
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Text(
          _isSelectionMode ? 'Đã chọn ${_selectedIds.length} mục' : '$count ảnh\nDo $userName tạo',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        );
      },
    );
  }
}
