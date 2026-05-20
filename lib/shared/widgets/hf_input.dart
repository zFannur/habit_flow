import 'package:flutter/material.dart';

import '../../core/config/text_theme.dart';
import '../../core/config/tokens.dart';

/// Текстовое поле / textarea (см. design-system.html → Inputs).
/// padding 11×14, radius 12, 1.5px border (accent при фокусе).
class HFInput extends StatefulWidget {
  const HFInput({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.minLines = 1,
    this.maxLines = 1,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  State<HFInput> createState() => _HFInputState();
}

class _HFInputState extends State<HFInput> {
  final _focus = FocusNode();
  TextEditingController? _internal;
  TextEditingController get _controller =>
      widget.controller ?? (_internal ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    _internal?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final hasContent = _controller.text.isNotEmpty;
    final highlight = _focus.hasFocus || hasContent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: context.tt.labelMedium!.copyWith(
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(HFTokens.rMd),
            border: Border.all(
              color: highlight ? c.accent : c.border,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            style: context.tt.bodyMedium!.copyWith(
              color: c.textPrimary,
              height: 1.5,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: widget.hint,
              hintStyle: context.tt.bodyMedium!.copyWith(
                color: c.textTertiary,
                height: 1.5,
              ),
            ),
            cursorColor: c.accent,
          ),
        ),
      ],
    );
  }
}
