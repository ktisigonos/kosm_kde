//! KDE: the theme's colors as a color scheme, and in kdeglobals for apps outside Plasma.

const std = @import("std");
const kosm_ini = @import("kosm_ini");

/// KDE's colors; build one with `from`.
pub const App = @import("App.zig");
/// Colors from the theme.
pub const from = App.from;
/// KDE's INI: `key=value`, `[A][B]` nested groups, `#` comments and `r,g,b` colors.
pub const adapter = kosm_ini.dialect(.{
    .name = "kde",
    .extensions = &.{".colors"},
    .default_format = .{ .color = .init("{},{},{}", &.{ .red_255, .green_255, .blue_255 }), .boolean = .true_false },
    .comments = &.{"#"},
    .top_level_keys = false,
    .separator = "=",
});

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(App);
}
