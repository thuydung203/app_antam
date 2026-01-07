import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  bool _isSelectionMode = false; // Trạng thái chọn ảnh
  final Set<int> _selectedIndexes = {}; // Lưu trữ index các ảnh được chọn
  
  // Danh sách ảnh thực tế sử dụng XFile từ image_picker
  List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  // Hàm mở album để chọn nhiều ảnh
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage();
      if (pickedImages.isNotEmpty) {
        setState(() {
          _images.addAll(pickedImages);
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi chọn ảnh: $e");
    }
  }

  // Thoát chế độ chọn
  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedIndexes.clear();
    });
  }

  // Chọn tất cả ảnh
  void _selectAll() {
    setState(() {
      _selectedIndexes.clear();
      for (int i = 0; i < _images.length; i++) {
        _selectedIndexes.add(i);
      }
    });
  }

  // Xử lý xóa các ảnh đã chọn và cập nhật danh sách
  void _deleteSelected() {
    if (_selectedIndexes.isEmpty) return;
    
    setState(() {
      // Sắp xếp index từ lớn đến bé để xóa chính xác
      List<int> sortedIndices = _selectedIndexes.toList()..sort((a, b) => b.compareTo(a));
      
      for (var index in sortedIndices) {
        _images.removeAt(index);
      }
      
      _selectedIndexes.clear();
      _isSelectionMode = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa các ảnh thành công')),
    );
  }

  // Đảo ngược trạng thái chọn của một ảnh
  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      body: SafeArea(
        child: Column(
          children: [
            // ===== TOP INFO =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/parent.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 50),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Name + Age + Buttons
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bố: Nguyễn Văn A',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Tuổi: 80',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        
                        // HÀNG NÚT ĐIỀU KHIỂN
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: _isSelectionMode 
                            ? [
                                // Nút Xóa (Thùng rác)
                                IconButton(
                                  onPressed: _selectedIndexes.isEmpty ? null : _deleteSelected,
                                  icon: Icon(
                                    Icons.delete_outline, 
                                    color: _selectedIndexes.isEmpty ? Colors.grey : Colors.red,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Nút Chọn tất cả
                                TextButton(
                                  onPressed: _selectAll,
                                  child: const Text('Chọn tất cả', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                ),
                                // Nút Hủy
                                TextButton(
                                  onPressed: _cancelSelection,
                                  child: const Text('Hủy', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                ),
                              ]
                            : [
                                // Nút Chọn bình thường
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _isSelectionMode = true);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Chọn',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.more_horiz, size: 28, color: Colors.black54),
                              ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ===== GRID IMAGES =====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _images.isEmpty 
                  ? const Center(child: Text("Album trống. Nhấn + để thêm ảnh."))
                  : GridView.builder(
                  itemCount: _images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedIndexes.contains(index);
                    
                    return GestureDetector(
                      onTap: () {
                        if (_isSelectionMode) {
                          _toggleSelection(index);
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected 
                                ? Border.all(color: Colors.blue, width: 3)
                                : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(_images[index].path),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image),
                              ),
                            ),
                          ),
                          // Overlay mờ và icon check khi được chọn
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(Icons.check_circle, color: Colors.white, size: 30),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ===== ADD IMAGE BUTTON =====
            if (!_isSelectionMode)
              GestureDetector(
                onTap: _pickImages, // Gọi hàm mở album ảnh
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, size: 26),
                ),
              ),

            const SizedBox(height: 16),

            // ===== FOOTER =====
            Text(
              _isSelectionMode 
                ? 'Đã chọn ${_selectedIndexes.length} mục'
                : '${_images.length} ảnh, 4 video\nDo Nguyễn Văn B tạo',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
