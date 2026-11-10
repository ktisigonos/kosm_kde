//! The `[WM]` colors of window title bars, named as KDE names them in snake_case
//! (`activeBackground` is `active_background`). null: not written.

const Color = @import("kosm").Color;

/// The focused window's title bar.
active_background: ?Color = null,
/// The focused window's title.
active_foreground: ?Color = null,
/// The color some decorations blend the focused title bar with.
active_blend: ?Color = null,
/// Other windows' title bars.
inactive_background: ?Color = null,
/// Other windows' titles.
inactive_foreground: ?Color = null,
/// The color some decorations blend other title bars with.
inactive_blend: ?Color = null,
