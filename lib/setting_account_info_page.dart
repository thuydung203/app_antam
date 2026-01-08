import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  final _editController = TextEditingController();

  void _showEditDialog({
    required BuildContext context,
    required String title,
    required String currentValue,
    required String hint,
    required TextInputType keyboardType,
    required Function(String) onSave,
  }) {
    _editController.text = currentValue;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: _editController,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newValue = _editController.text.trim();
              if (newValue.isNotEmpty) {
                await onSave(newValue);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Cập nhật $title thành công!")),
                  );
                }
              }
            },
            child: const Text("Lưu", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Hàm chọn ngày sinh
  Future<void> _selectBirthDate(BuildContext context, DateTime? current) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      await Provider.of<AuthProvider>(context, listen: false).updateBirthDate(picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật ngày sinh thành công!")),
        );
      }
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf7f7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thông tin tài khoản",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.userModel;
          final String? avatarBase64 = user?.avatar;
          final String birthDateStr = user?.birthDate != null 
              ? DateFormat('dd/MM/yyyy').format(user!.birthDate!) 
              : "Chưa cập nhật";

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFFFFC1A8),
                  backgroundImage: (avatarBase64 != null && avatarBase64.isNotEmpty)
                      ? MemoryImage(base64Decode(avatarBase64))
                      : null,
                  child: (avatarBase64 == null || avatarBase64.isEmpty)
                      ? const Icon(Icons.person, size: 55, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 30),
                
                _buildLabel("Họ và tên"),
                _buildInputBox(
                  value: user?.name ?? "Chưa cập nhật",
                  rightIcon: Icons.person,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Họ và tên",
                    currentValue: user?.name ?? "",
                    hint: "Nhập tên mới",
                    keyboardType: TextInputType.name,
                    onSave: (val) => auth.updateName(val),
                  ),
                ),
                
                const SizedBox(height: 20),
                _buildLabel("Ngày tháng năm sinh"),
                _buildInputBox(
                  value: birthDateStr,
                  rightIcon: Icons.calendar_today,
                  onTap: () => _selectBirthDate(context, user?.birthDate),
                ),

                const SizedBox(height: 20),
                _buildLabel("Số điện thoại"),
                _buildInputBox(
                  value: user?.phone ?? "Chưa cập nhật",
                  rightIcon: Icons.phone_in_talk,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Số điện thoại",
                    currentValue: user?.phone ?? "",
                    hint: "Nhập số điện thoại mới",
                    keyboardType: TextInputType.phone,
                    onSave: (val) => auth.updatePhone(val),
                  ),
                ),

                const SizedBox(height: 20),
                _buildLabel("Email liên hệ"),
                _buildInputBox(
                  value: user?.email ?? "Đang tải...",
                  rightIcon: Icons.mail,
                ),

                const SizedBox(height: 20),
                _buildLabel("Địa chỉ"),
                _buildInputBox(
                  value: user?.address ?? "Chưa cập nhật",
                  rightIcon: Icons.location_on,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Địa chỉ",
                    currentValue: user?.address ?? "",
                    hint: "Nhập địa chỉ mới",
                    keyboardType: TextInputType.streetAddress,
                    onSave: (val) => auth.updateAddress(val),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInputBox({required String value, IconData? rightIcon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (rightIcon != null)
              Icon(rightIcon, size: 22, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
