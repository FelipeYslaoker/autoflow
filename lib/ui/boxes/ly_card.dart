import 'package:autoflow/ui/ly_properties/ly_density.dart';
import 'package:flutter/material.dart';

class LyCard extends StatefulWidget {
  final Widget? header;
  final Widget? content;
  final Widget? footer;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final LyDensity density;
  final double elevation;
  final FocusNode? focusNode;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;
  final void Function()? onFocus;
  final void Function()? onFocusOut;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final double? width;
  final double? height;
  final Duration transitionDuration;
  final Widget Function(Widget, Animation<double>)? transitionBuilder;

  const LyCard({
    super.key,
    this.header,
    this.content,
    this.footer,
    this.margin,
    this.padding,
    this.density = LyDensity.normal,
    this.elevation = 1.0,
    this.focusNode,
    this.borderRadius,
    this.shape,
    this.onFocus,
    this.onFocusOut,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.transitionBuilder,
  });

  @override
  State<LyCard> createState() => _LyCardState();
}

class _LyCardState extends State<LyCard> {
  FocusNode? focusNode;
  bool hasFocus = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      focusNode = widget.focusNode;
      focusNode!.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    focusNode?.removeListener(_handleFocusChange);
    focusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      hasFocus = focusNode?.hasFocus ?? false;
    });
    if (hasFocus) {
      widget.onFocus?.call();
    } else {
      widget.onFocusOut?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.transitionDuration,
      transitionBuilder: widget.transitionBuilder ?? _defaultTransitionBuilder,
      child: Padding(
        key: ValueKey(hasFocus),
        padding: widget.margin ?? EdgeInsets.zero,
        child: Material(
          elevation: widget.elevation,
          color: hasFocus
              ? Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          shape: widget.shape ??
              RoundedRectangleBorder(
                side: hasFocus
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      )
                    : BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(.1),
                        width: 2.0,
                      ),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              ),
          child: InkWell(
            focusNode: focusNode,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding ??
                  EdgeInsets.all(
                    () {
                      switch (widget.density) {
                        case LyDensity.normal:
                          return 16.0;
                        case LyDensity.comfortable:
                          return 24.0;
                        case LyDensity.dense:
                          return 8.0;
                      }
                    }(),
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.header != null)
                    Padding(
                      padding: widget.header is Text
                          ? const EdgeInsets.only(bottom: 8)
                          : EdgeInsets.zero,
                      child: _buildHeader(context, widget.header!),
                    ),
                  if (widget.content != null) ...[
                    if (widget.header != null) const SizedBox(height: 8.0),
                    widget.content!,
                  ],
                  if (widget.footer != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                        right: 12,
                      ),
                      child: widget.footer!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Widget header) {
    if (header is Text) {
      return Text(
        header.data ?? '',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: hasFocus
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
      );
    }
    return header;
  }

  Widget _defaultTransitionBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
