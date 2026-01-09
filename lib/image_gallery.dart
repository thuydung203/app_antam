import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ImageGalleryPage extends StatelessWidget {
  final String? userId;
  const ImageGalleryPage({super.key, this.userId});

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
      body: StreamBuilder<QuerySnapshot>(
        stream: (userId != null && userId!.isNotEmpty)
            ? FirebaseFirestore.instance
                .collection('images')
                .where('userId', isEqualTo: userId)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('images')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("Thư viện hiện đang trống."));
          }

          // Sắp xếp thủ công
          final sortedDocs = List.from(docs);
          sortedDocs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final aTime = dataA['createdAt'] as Timestamp?;
            final bTime = dataB['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: sortedDocs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Hiển thị 3 ảnh trên 1 hàng
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final data = sortedDocs[index].data() as Map<String, dynamic>;
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
