import 'package:flutter/material.dart';

/// Clean user avatar with network support and deterministic initial/color fallback.
///
/// Reliably handles edge cases like short usernames (`1`), emails, or empty values.
class UserAvatar extends StatelessWidget {
  final String? name;
  final String? email;
  final String? avatarUrl;
  final double radius;

  const UserAvatar({
    super.key,
    this.name,
    this.email,
    this.avatarUrl,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = avatarUrl?.trim() ?? '';
    final hasValidUrl =
        cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://');

    if (hasValidUrl) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Image.network(
            cleanUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildFallback(),
          ),
        ),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    final effectiveText = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()
        : (email != null && email!.trim().isNotEmpty)
        ? email!.trim()
        : 'Reader';

    final initial = effectiveText.isNotEmpty
        ? effectiveText[0].toUpperCase()
        : 'U';

    final color = _getColorFromText(effectiveText);

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColorFromText(String text) {
    const colors = [
      Color(0xFF0D9488), // Teal
      Color(0xFF4F46E5), // Indigo
      Color(0xFF7C3AED), // Purple
      Color(0xFFDB2777), // Pink
      Color(0xFFD97706), // Amber
      Color(0xFF0284C7), // Sky Blue
      Color(0xFF059669), // Emerald
      Color(0xFFDC2626), // Rose Red
    ];
    final hash = text.hashCode.abs();
    return colors[hash % colors.length];
  }
}
