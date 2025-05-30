import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool showCounter;
  final EdgeInsetsGeometry? contentPadding;

  const CustomInputField({
    super.key,
    required this.controller,
    this.onChanged,
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.showCounter = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final int currentLength = controller.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            if (maxLength != null && showCounter)
              Text(
                '$currentLength/$maxLength',
                style: TextStyle(
                  color: currentLength > maxLength! ? Colors.red : Colors.grey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffixIcon,
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
