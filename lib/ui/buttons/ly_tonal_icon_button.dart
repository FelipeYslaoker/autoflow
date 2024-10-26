import 'package:autoflow/ui/ly_properties/ly_density.dart';
import 'package:flutter/material.dart';

class LyTonalIconButton extends StatefulWidget {
  final double? iconSize;
  final Size? fixedSize;
  final EdgeInsetsGeometry? margin;
  final LyDensity density;
  final double elevation;
  final FocusNode? focusNode;
  final void Function()? onFocus;
  final void Function()? onFocusOut;
  final void Function()? onPressed;
  final Widget? icon;
  final Widget? label;
  final double iconSpacing;

  const LyTonalIconButton({
    super.key,
    this.icon,
    this.label,
    this.iconSpacing = 8,
    this.onPressed,
    this.onFocus,
    this.onFocusOut,
    this.density = LyDensity.dense,
    this.elevation = 0,
    this.focusNode,
    this.margin,
    this.iconSize,
    this.fixedSize,
  });

  @override
  State<LyTonalIconButton> createState() => _LyTonalIconButtonState();
}

class _LyTonalIconButtonState extends State<LyTonalIconButton> {
  late final FocusNode focusNode;
  bool hasFocus = false;

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(() {
      setState(() {
        hasFocus = focusNode.hasFocus;
      });
      if (focusNode.hasFocus) {
        widget.onFocus?.call();
      } else {
        widget.onFocusOut?.call();
      }
    });
  }

  Size _getButtonSize() {
    switch (widget.density) {
      case LyDensity.dense:
        return widget.fixedSize ?? const Size(40.0, 40.0);
      case LyDensity.normal:
        return widget.fixedSize ?? const Size(46.0, 46.0);
      case LyDensity.comfortable:
        return widget.fixedSize ?? const Size(55.0, 55.0);
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.density) {
      case LyDensity.dense:
        return const EdgeInsets.all(4.0);
      case LyDensity.normal:
        return const EdgeInsets.all(6.0);
      case LyDensity.comfortable:
        return const EdgeInsets.all(12.0);
    }
  }

  double _getIconSize() {
    switch (widget.density) {
      case LyDensity.dense:
        return widget.iconSize ?? 20.0;
      case LyDensity.normal:
        return widget.iconSize ?? 24.0;
      case LyDensity.comfortable:
        return widget.iconSize ?? 28.0;
      default:
        return widget.iconSize ?? 24.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;
    final Size buttonSize = _getButtonSize();

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: MaterialButton(
        elevation: isDisabled ? 0 : widget.elevation,
        focusNode: focusNode,
        visualDensity: VisualDensity.compact,
        focusElevation: 0,
        padding: _getPadding(),
        onPressed: widget.onPressed,
        shape: widget.label != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(300),
                side: hasFocus && !isDisabled
                    ? BorderSide(
                        width: 2,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : const BorderSide(
                        color: Colors.transparent,
                      ),
              )
            : CircleBorder(
                side: hasFocus && !isDisabled
                    ? BorderSide(
                        width: 2,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : const BorderSide(
                        color: Colors.transparent,
                      ),
              ),
        disabledColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        color: (hasFocus
            ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest),
        minWidth: buttonSize.width, // Largura dinâmica do botão
        height: buttonSize.height, // Altura dinâmica do botão
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.label != null ? 12 : 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (context) {
                  if (widget.icon != null) {
                    if (widget.icon is Icon) {
                      final Icon originalIcon = widget.icon as Icon;
                      return Icon(
                        originalIcon.icon,
                        size:
                            _getIconSize(), // Usa o tamanho do ícone baseado na densidade
                        color: isDisabled
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.38)
                            : (hasFocus
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                      );
                    }
                    return widget.icon!;
                  }
                  return const SizedBox.shrink();
                },
              ),
              if (widget.icon != null && widget.label != null)
                SizedBox(width: widget.iconSpacing),
              if (widget.label != null)
                Builder(
                  builder: (context) {
                    if (widget.label is Text &&
                        (widget.label as Text).style == null) {
                      final Text originalText = widget.label as Text;
                      return Text(
                        originalText.data ?? '',
                        style: TextStyle(
                          color: isDisabled
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.38)
                              : hasFocus
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                        ),
                        strutStyle: originalText.strutStyle,
                        textAlign: originalText.textAlign,
                        textDirection: originalText.textDirection,
                        locale: originalText.locale,
                        softWrap: originalText.softWrap,
                        overflow: originalText.overflow,
                        textScaler: originalText.textScaler,
                        maxLines: originalText.maxLines,
                        semanticsLabel: originalText.semanticsLabel,
                        textWidthBasis: originalText.textWidthBasis,
                        textHeightBehavior: originalText.textHeightBehavior,
                        selectionColor: originalText.selectionColor,
                      );
                    }
                    return widget.label ?? const SizedBox.shrink();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
