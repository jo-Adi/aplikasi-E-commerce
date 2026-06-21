import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                decoration: const InputDecoration(
                  hintText: 'Cari produk di BinMart...',
                  hintStyle:
                      TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Filter button
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9E72),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
