//! One KDE color set (`[Colors:Window]`, `[Colors:View]`, ...), keys named as KDE names them
//! in snake_case (`BackgroundNormal` is `background_normal`). null: not written, so KDE's
//! default for the set applies.

const Set = @This();

const kosm = @import("kosm");
const Color = kosm.Color;

/// The set's background.
background_normal: ?Color = null,
/// Alternating rows of lists.
background_alternate: ?Color = null,
/// Text.
foreground_normal: ?Color = null,
/// Less important text: comments, subtitles.
foreground_inactive: ?Color = null,
/// Active text: pressed or hovered items, active links.
foreground_active: ?Color = null,
/// Links.
foreground_link: ?Color = null,
/// Visited links.
foreground_visited: ?Color = null,
/// Errors and other bad news.
foreground_negative: ?Color = null,
/// Warnings.
foreground_neutral: ?Color = null,
/// Success.
foreground_positive: ?Color = null,
/// The focus outline.
decoration_focus: ?Color = null,
/// The hover outline.
decoration_hover: ?Color = null,

/// A set on `background`, `alternate` for its alternating rows, with the theme's text and
/// state colors: text the foreground role, muted by the theme's emphasis when inactive, active
/// text the accent; links the link role, visited ones purple; the error, warning and success
/// roles for bad, warning and good news; the focus and hover outlines the accent.
pub fn on(theme: kosm.Theme, background: Color, alternate: Color) Set {
    const palette = theme.palette;
    const foreground = theme.roles.foreground;
    return .{
        .background_normal = background,
        .background_alternate = alternate,
        .foreground_normal = foreground,
        .foreground_inactive = theme.variations.emphasis.muted.apply(foreground),
        .foreground_active = theme.roles.accent,
        .foreground_link = theme.roles.link,
        .foreground_visited = palette.purple,
        .foreground_negative = theme.roles.@"error",
        .foreground_neutral = theme.roles.warning,
        .foreground_positive = theme.roles.success,
        .decoration_focus = theme.roles.accent,
        .decoration_hover = theme.roles.accent,
    };
}
