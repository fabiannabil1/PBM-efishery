// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final double? elevation;
  final TextStyle? titleStyle;
  final Widget? leading;
  final double? toolbarHeight;
  final Widget? flexibleSpace;
  final bool enableShadow;
  final IconThemeData? iconTheme;
  final bool showCheckButton;
  final VoidCallback? onCheckPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.gradientColors,
    this.elevation,
    this.titleStyle,
    this.leading,
    this.toolbarHeight,
    this.flexibleSpace,
    this.enableShadow = true,
    this.iconTheme,
    this.showCheckButton = false,
    this.onCheckPressed,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradientColors =
        gradientColors ??
        [
          const Color(0xFF1E3A8A), // blue-800
          const Color(0xFF2563EB), // blue-600
          const Color(0xFF3B82F6), // blue-500
          const Color(0xFF60A5FA), // blue-400
        ];

    final defaultTitleStyle =
        titleStyle ??
        GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        );

    final defaultIconTheme =
        iconTheme ?? const IconThemeData(color: Colors.white, size: 24);

    return Container(
      decoration:
          enableShadow
              ? BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              )
              : null,
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: _buildLeading(context),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: defaultTitleStyle,
          child: Text(title),
        ),
        centerTitle: centerTitle,
        actions: _buildActions(context),
        elevation: elevation ?? 0,
        toolbarHeight: toolbarHeight ?? kToolbarHeight,
        iconTheme: defaultIconTheme,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        flexibleSpace:
            flexibleSpace ??
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: defaultGradientColors,
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton && Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> actionWidgets = [];

    if (showCheckButton) {
      actionWidgets.add(
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: onCheckPressed,
          tooltip: 'Confirm',
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
        ),
      );
    }

    if (actions != null) {
      actionWidgets.addAll(
        actions!.map((action) {
          if (action is IconButton) {
            return IconButton(
              onPressed: action.onPressed,
              icon: action.icon,
              tooltip: action.tooltip,
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
            );
          }
          return action;
        }).toList(),
      );
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
}

// Variant dengan design modern dan glassmorphism effect
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final double blur;
  final double opacity;
  final bool showCheckButton;
  final VoidCallback? onCheckPressed;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.showCheckButton = false,
    this.onCheckPressed,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> actionWidgets = [];

    if (showCheckButton) {
      actionWidgets.add(
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: onCheckPressed,
          tooltip: 'Confirm',
          color: Colors.white,
        ),
      );
    }

    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 6,
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: AppBar(
            automaticallyImplyLeading: false,
            leading:
                showBackButton && Navigator.of(context).canPop()
                    ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed:
                          onBackPressed ?? () => Navigator.of(context).pop(),
                      color: Colors.white,
                    )
                    : null,
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: centerTitle,
            actions: actionWidgets.isNotEmpty ? actionWidgets : null,
            backgroundColor: (backgroundColor ?? Colors.white).withAlpha(
              (opacity * 255).toInt(),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
