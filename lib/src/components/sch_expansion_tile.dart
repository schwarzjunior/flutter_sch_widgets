import 'package:flutter/material.dart';

const Duration _kExpand = Duration(milliseconds: 200);

/// A single-line [ListTile] with a trailing button that expands or collapses
/// the tile to reveal or hide the [children].
///
/// This widget is typically used with [ListView] to create an
/// "expand / collapse" list entry. When used with scrolling widgets like
/// [ListView], a unique [PageStorageKey] must be specified to enable the
/// [SchExpansionTile] to save and restore its expanded state when it is scrolled
/// in and out of view.
///
/// See also:
///
///  * [ListTile], useful for creating expansion tile [children] when the
///    expansion tile represents a sublist.
///  * The "Expand/collapse" section of
///    <https://material.io/guidelines/components/lists-controls.html>.
class SchExpansionTile extends StatefulWidget {
  const SchExpansionTile({
    Key key,
    this.leading,
    @required this.title,
    this.children = const <Widget>[],
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.margin = const EdgeInsets.symmetric(vertical: 0.0),
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 8.0),
    this.contentPadding = const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
    this.trailingIcon = Icons.expand_more,
    this.trailingVisibility = true,
    this.trailingRotation = true,
    this.decoration = const SchExpansionTileDecoration(),
  })  : assert(initiallyExpanded != null),
        assert(margin != null),
        assert(headerPadding != null),
        assert(contentPadding != null),
        assert(trailingIcon != null),
        assert(trailingVisibility != null),
        assert(trailingRotation != null),
        super(key: key);

  /// A widget to display before the title.
  ///
  /// Typically a [CircleAvatar] widget.
  final Widget leading;

  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget> children;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool> onExpansionChanged;

  /// The margin of the widget.
  final EdgeInsetsGeometry margin;

  /// The padding of the tile header.
  final EdgeInsetsGeometry headerPadding;

  /// The padding of the tile's children.
  final EdgeInsetsGeometry contentPadding;

  /// The icon to display after the title.
  final IconData trailingIcon;

  /// The visibility of the trailing icon.
  final bool trailingVisibility;

  /// If the trailing icon must rotate on expand.
  final bool trailingRotation;

  /// The decoration of [ListTile].
  final SchExpansionTileDecoration decoration;

  @override
  _SchExpansionTileState createState() => _SchExpansionTileState();
}

class _SchExpansionTileState extends State<SchExpansionTile> with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween = CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  AnimationController _controller;
  Animation<double> _iconTurns;
  Animation<double> _heightFactor;
  Animation<Color> _borderColor;
  Animation<Color> _headerColor;
  Animation<Color> _iconColor;
  Animation<Color> _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    _borderColor = _controller.drive(_borderColorTween.chain(_easeOutTween));
    _headerColor = _controller.drive(_headerColorTween.chain(_easeInTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_easeInTween));
    _backgroundColor = _controller.drive(_backgroundColorTween.chain(_easeOutTween));

    _isExpanded = PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null) widget.onExpansionChanged(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    final Color borderSideColor = _borderColor.value ?? Colors.transparent;

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: _backgroundColor.value ?? Colors.transparent,
        border: Border.fromBorderSide(
          BorderSide(color: borderSideColor, width: widget?.decoration?.borderWidth),
        ),
        borderRadius: BorderRadius.all(Radius.circular(widget?.decoration?.borderRadius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme.merge(
            iconColor: _iconColor.value,
            textColor: _headerColor.value,
            child: ListTile(
              contentPadding: widget.headerPadding,
              onTap: _handleTap,
              leading: widget.leading,
              title: widget.title,
              trailing: !widget.trailingVisibility
                  ? null
                  : widget.trailingRotation
                      ? RotationTransition(
                          turns: _iconTurns,
                          child: Icon(widget.trailingIcon),
                        )
                      : Icon(widget.trailingIcon),
            ),
          ),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _borderColorTween
      ..begin = widget?.decoration?.borderColorBegin ?? theme.dividerColor
      ..end = widget?.decoration?.borderColorEnd ?? theme.dividerColor;
    _headerColorTween
      ..begin = widget?.decoration?.headerColorBegin ?? theme.textTheme.subhead.color
      ..end = widget?.decoration?.headerColorEnd ?? theme.accentColor;
    _iconColorTween
      ..begin = widget?.decoration?.iconColorBegin ?? theme.unselectedWidgetColor
      ..end = widget?.decoration?.iconColorEnd ?? theme.accentColor;
    _backgroundColorTween
      ..begin = widget?.decoration?.backgroundColorBegin ?? Colors.transparent
      ..end = widget?.decoration?.backgroundColorEnd ?? widget?.decoration?.backgroundColorBegin ?? Colors.transparent;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed
          ? null
          : Padding(
              padding: widget.contentPadding,
              child: Column(children: widget.children),
            ),
    );
  }
}

///
/// The decoration properties of a [SchExpansionTile] widget.
///
class SchExpansionTileDecoration {
  const SchExpansionTileDecoration({
    this.backgroundColorBegin,
    this.backgroundColorEnd,
    this.borderColorBegin,
    this.borderColorEnd,
    this.headerColorBegin,
    this.headerColorEnd,
    this.iconColorBegin,
    this.iconColorEnd,
    this.borderWidth = 1.0,
    this.borderRadius = 8.0,
  })  : assert(borderWidth != null),
        assert(borderRadius != null);

  /// Them begin animation color of the background.
  final Color backgroundColorBegin;

  /// The end animation color of the background.
  final Color backgroundColorEnd;

  /// The begin animation color of the border.
  final Color borderColorBegin;

  /// The end animation color of the border.
  final Color borderColorEnd;

  /// The begin animation color of the header.
  final Color headerColorBegin;

  /// The end animation color of the header.
  final Color headerColorEnd;

  /// The begin animation color of the icon.
  final Color iconColorBegin;

  /// The end animation color of the icon.
  final Color iconColorEnd;

  /// The width of the border.
  final double borderWidth;

  /// The radius of the border.
  final double borderRadius;
}
