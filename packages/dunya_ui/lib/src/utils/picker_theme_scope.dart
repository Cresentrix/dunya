import 'package:flutter/material.dart';

import '../theme/dunya_picker_theme.dart';

/// Makes [DunyaPickerTheme.of] return [theme] below [child].
///
/// Routes and overlays are built under the [Navigator], not under the
/// widget that opened them, so a theme set around a picker (a local
/// [Theme] or a widget's `theme` parameter) has to be carried into them.
Widget withPickerTheme(
  BuildContext context,
  DunyaPickerTheme theme,
  Widget child,
) {
  final data = Theme.of(context);
  return Theme(
    data: data.copyWith(
      extensions: [
        ...data.extensions.values.where((e) => e is! DunyaPickerTheme),
        theme,
      ],
    ),
    child: child,
  );
}

/// Wraps a route [builder] so its content uses [theme].
WidgetBuilder themedBuilder(DunyaPickerTheme theme, WidgetBuilder builder) {
  return (context) =>
      withPickerTheme(context, theme, Builder(builder: builder));
}
