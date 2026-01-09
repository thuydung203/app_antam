import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ImageGalleryPage extends StatelessWidget {
  final String? childId; // Nhận ID của con để lọc ảnh

  const ImageGalleryPage({super.key, this.childId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        title: const Text(
          'THƯ VIỆN ẢNH',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFFFF7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: childId == null || childId!.isEmpty
          ? const Center(child: Text("Không tìm thấy dữ liệu ảnh gia đình."))
          : StreamBuilder<QuerySnapshot>(
              // Lọc ảnh theo đúng userId của người con đã kết nối
              stream: FirebaseFirestore.instance
                  .collection('images')
                  .where('userId', isEqualTo: childId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final List<QueryDocumentSnapshot> docs = snapshot.data?.docs.toList() ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text("Thư viện hiện đang trống."));
                }

                // Sắp xếp theo thời gian ở phía client để tránh lỗi Index Firestore
                docs.sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime);
                });

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    itemCount: docs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, 
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final String base64Str = data['base64String'] ?? '';
                      
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(base64Str),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
