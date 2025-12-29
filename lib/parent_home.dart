import 'package:flutter/material.dart';

class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  // Widget thanh điều hướng dưới cùng
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 77,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.home, size: 40, color: Colors.blue),
            onPressed: () {},
          ),
          Transform.rotate(
            angle: 1.55,
            child: Container(width: 59, height: 1, color: Colors.grey.shade400),
          ),
          IconButton(
            icon: const Icon(Icons.send, size: 40, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'PARENT HOME',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 386,
                height: 386,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://picsum.photos/386"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 87),
              SizedBox(
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF94133),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SOS KHẨN CẤP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 88,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF78EC46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.call, color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }
}
