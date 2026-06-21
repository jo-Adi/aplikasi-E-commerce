import 'package:flutter/material.dart';
import '../cubit/auth_cubit.dart';

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleSelected;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar sebagai',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                role: UserRole.buyer,
                emoji: '🛍️',
                title: 'Pembeli',
                subtitle: 'Temukan & beli\nproduk terbaik',
                isSelected: selectedRole == UserRole.buyer,
                onTap: () => onRoleSelected(UserRole.buyer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoleCard(
                role: UserRole.seller,
                emoji: '🏪',
                title: 'Penjual',
                subtitle: 'Buka toko &\njual produkmu',
                isSelected: selectedRole == UserRole.seller,
                onTap: () => onRoleSelected(UserRole.seller),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D9E72).withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D9E72)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0D9E72).withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          children: [
            // Ikon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0D9E72)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? const Color(0xFF0D9E72)
                    : const Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 4),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: isSelected
                    ? const Color(0xFF0D9E72).withValues(alpha: 0.8)
                    : const Color(0xFF9CA3AF),
              ),
            ),

            const SizedBox(height: 10),

            // Checkmark indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF0D9E72)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0D9E72)
                      : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
