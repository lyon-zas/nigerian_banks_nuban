import 'package:flutter/material.dart';
import '../models/bank.dart';

/// A widget that displays a bank's logo with built-in error handling and fallback.
class BankLogo extends StatelessWidget {
  /// The bank whose logo to display.
  final Bank? bank;

  /// The size of the logo (both width and height).
  final double size;

  /// A custom fallback widget when the logo is not available.
  /// If null, a default icon is shown.
  final Widget? fallback;

  /// Border radius for the logo container.
  final double borderRadius;

  /// Background color for the logo container.
  final Color? backgroundColor;

  /// Box fit for the image.
  final BoxFit fit;

  const BankLogo({
    super.key,
    required this.bank,
    this.size = 40,
    this.fallback,
    this.borderRadius = 8,
    this.backgroundColor,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (bank == null) {
      return _buildFallback(context);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        bank!.logo,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(context);
        },
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    if (fallback != null) {
      return fallback!;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.account_balance,
        size: size * 0.5,
        color: Colors.grey.shade600,
      ),
    );
  }
}
