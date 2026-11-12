//! KDE's colors: a color scheme generated into `scheme`, and the same colors in a block of
//! `globals` (kdeglobals), which KDE apps outside Plasma read their colors from. The rest of
//! kdeglobals stays the user's.

const App = @This();

const std = @import("std");
const kosm = @import("kosm");

/// The color scheme file kosm owns, listed in Plasma's settings; `{name}` is filled as `files`
/// says. null: not written. Default: `~/.local/share/color-schemes/{name}.colors`.
scheme: ?[]const u8 = "~/.local/share/color-schemes/{name}.colors",
/// How `{name}` in `scheme` is filled: `kosm`, or the kosmos' name. Default: the theme's `files`.
files: kosm.Theme.Files = .shared,
/// KDE's global config, holding the block that selects the scheme and holds its colors; created
/// when missing. null: not written. Default: `~/.config/kdeglobals`.
globals: ?[]const u8 = "~/.config/kdeglobals",
/// The name Plasma's settings show for the scheme (`[General] Name`). null (default): the
/// theme's `name`, or the name kosm applies the kosmos under. KDE selects the scheme by its
/// file's name (`ColorScheme`), whatever this says.
name: ?[]const u8 = null,
/// How colors are spelled. Null fields take the adapter's: `r,g,b`.
format: kosm.Format = .{},
/// Windows and their widgets.
window: Set = .{},
/// Lists, text fields and other views.
view: Set = .{},
/// Buttons.
button: Set = .{},
/// Selected items.
selection: Set = .{},
/// Tooltips.
tooltip: Set = .{},
/// Areas drawn in contrast to the rest, such as Plasma's panels.
complementary: Set = .{},
/// Header bars and the title areas of apps that draw their own.
header: Set = .{},
/// `header` of windows without focus (`[Colors:Header][Inactive]`).
header_inactive: Set = .{},
/// Title bar colors.
window_manager: WindowManager = .{},

/// One color set.
pub const Set = @import("Set.zig");
/// Title bar colors.
pub const WindowManager = @import("WindowManager.zig");

/// Colors from the theme: windows, tooltips and the complementary set on the background role,
/// views sunken, buttons and headers raised, selections the accent with readable text from the
/// theme's `contrast.on`; title bars raised when focused.
pub fn from(theme: kosm.Theme) App {
    const variations = theme.variations;
    const foreground = theme.roles.foreground;
    const background = theme.asBackground(theme.roles.background);
    const raised = variations.surface.raised.apply(background);
    const sunken = variations.surface.sunken.apply(background);
    const overlay = variations.surface.overlay.apply(background);
    var selection: Set = .on(theme, theme.roles.accent, variations.lightness.dark.apply(theme.roles.accent));
    selection.foreground_normal = variations.contrast.on.apply(theme.roles.accent);
    selection.foreground_inactive = variations.contrast.on_muted.apply(theme.roles.accent);
    selection.foreground_active = variations.contrast.on.apply(theme.roles.accent);
    const muted = variations.emphasis.muted.apply(foreground);
    return .{
        .files = theme.files,
        .name = theme.name,
        .window = .on(theme, background, raised),
        .view = .on(theme, sunken, background),
        .button = .on(theme, raised, overlay),
        .selection = selection,
        .tooltip = .on(theme, overlay, raised),
        .complementary = .on(theme, background, raised),
        .header = .on(theme, raised, overlay),
        .header_inactive = .on(theme, background, raised),
        .window_manager = .{
            .active_background = raised,
            .active_foreground = foreground,
            .active_blend = foreground,
            .inactive_background = background,
            .inactive_foreground = muted,
            .inactive_blend = muted,
        },
    };
}

/// Generates `scheme`, then writes block `kosm` of `globals` with the same colors, selecting
/// the scheme by its file's name.
pub fn apply(self: App, output: *kosm.Output) !void {
    const scheme_file = if (self.scheme) |scheme| try output.namedFile(scheme, self.files) else null;
    const color_scheme = if (scheme_file) |scheme| std.Io.Dir.path.stem(scheme) else try output.namedFile("{name}", self.files);
    const colors = try self.sections(output.allocator);
    if (scheme_file) |scheme| {
        const general: kosm.Value.Entry = .{ .key = "General", .value = try table(output.allocator, &.{
            .{ .key = "ColorScheme", .value = .{ .string = color_scheme } },
            .{ .key = "Name", .value = .{ .string = try output.displayName(scheme, self.name) } },
        }) };
        try output.generate(.{ .file = scheme, .lang = "kde", .format = self.format }, kosm.Value{ .table = try prepend(output.allocator, general, colors) });
    }
    if (self.globals) |globals| {
        const general: kosm.Value.Entry = .{ .key = "General", .value = try table(output.allocator, &.{
            .{ .key = "ColorScheme", .value = .{ .string = color_scheme } },
        }) };
        try output.block(.{ .file = globals, .id = "kosm", .lang = "kde", .format = self.format }, kosm.Value{ .table = try prepend(output.allocator, general, colors) });
    }
}

/// Every set with a color, as `[Colors:<Set>]` sections, then `[WM]`.
fn sections(self: App, allocator: std.mem.Allocator) ![]const kosm.Value.Entry {
    var list: std.ArrayList(kosm.Value.Entry) = .empty;
    const sets = [_]struct { []const u8, Set }{
        .{ "Colors:Button", self.button },
        .{ "Colors:Complementary", self.complementary },
        .{ "Colors:Selection", self.selection },
        .{ "Colors:Tooltip", self.tooltip },
        .{ "Colors:View", self.view },
        .{ "Colors:Window", self.window },
    };
    for (sets) |set| {
        const keys = try entries(allocator, Set, set[1], .pascal);
        if (keys.len != 0) try list.append(allocator, .{ .key = set[0], .value = .{ .table = keys } });
    }
    var header: std.ArrayList(kosm.Value.Entry) = .empty;
    try header.appendSlice(allocator, try entries(allocator, Set, self.header, .pascal));
    const inactive = try entries(allocator, Set, self.header_inactive, .pascal);
    if (inactive.len != 0) try header.append(allocator, .{ .key = "Inactive", .value = .{ .table = inactive } });
    if (header.items.len != 0) try list.append(allocator, .{ .key = "Colors:Header", .value = .{ .table = header.items } });
    const window_manager = try entries(allocator, WindowManager, self.window_manager, .camel);
    if (window_manager.len != 0) try list.append(allocator, .{ .key = "WM", .value = .{ .table = window_manager } });
    return list.items;
}

/// The set colors of `colors`, keyed as KDE names them.
fn entries(allocator: std.mem.Allocator, comptime Colors: type, colors: Colors, comptime casing: Casing) ![]const kosm.Value.Entry {
    var list: std.ArrayList(kosm.Value.Entry) = .empty;
    inline for (@typeInfo(Colors).@"struct".field_names) |field| {
        if (@field(colors, field)) |color| try list.append(allocator, .{ .key = comptime keyName(field, casing), .value = .{ .color = color } });
    }
    return list.items;
}

const Casing = enum { pascal, camel };

/// `background_normal` as `BackgroundNormal` (pascal) or `active_background` as
/// `activeBackground` (camel).
fn keyName(comptime name: []const u8, comptime casing: Casing) []const u8 {
    comptime var key: []const u8 = "";
    comptime var words = std.mem.splitScalar(u8, name, '_');
    inline while (comptime words.next()) |word| {
        if (casing == .camel and key.len == 0) {
            key = word;
        } else {
            key = key ++ [_]u8{std.ascii.toUpper(word[0])} ++ word[1..];
        }
    }
    return key;
}

fn table(allocator: std.mem.Allocator, items: []const kosm.Value.Entry) !kosm.Value {
    return .{ .table = try allocator.dupe(kosm.Value.Entry, items) };
}

fn prepend(allocator: std.mem.Allocator, first: kosm.Value.Entry, rest: []const kosm.Value.Entry) ![]const kosm.Value.Entry {
    const all = try allocator.alloc(kosm.Value.Entry, rest.len + 1);
    all[0] = first;
    @memcpy(all[1..], rest);
    return all;
}

const testing = std.testing;
const adapter = @import("root.zig").adapter;

const Fixture = struct {
    tmp: testing.TmpDir,
    arena: std.heap.ArenaAllocator,
    plan: kosm.Plan,
    diagnostics: kosm.Diagnostics = .{},
    warnings: kosm.Warnings = undefined,
    home_buffer: [std.Io.Dir.max_path_bytes]u8 = undefined,
    output: kosm.Output = undefined,

    fn init(fixture: *Fixture) !void {
        fixture.* = .{ .tmp = testing.tmpDir(.{}), .arena = .init(testing.allocator), .plan = .init(testing.allocator, testing.io) };
        try fixture.tmp.dir.createDirPath(testing.io, ".config");
        try fixture.tmp.dir.writeFile(testing.io, .{ .sub_path = ".config/kdeglobals", .data = "[General]\nColorScheme=Ricer\n\n[KDE]\nwidgetStyle=Breeze\n" });
        fixture.warnings = .init(fixture.arena.allocator());
        const length = try fixture.tmp.dir.realPath(testing.io, &fixture.home_buffer);
        fixture.output = .{
            .allocator = fixture.arena.allocator(),
            .home = fixture.home_buffer[0..length],
            .adapters = &.{adapter},
            .plan = &fixture.plan,
            .diagnostics = &fixture.diagnostics,
            .warnings = &fixture.warnings,
            .app = "kde",
            .kosmos = "krystallos.dark",
        };
    }

    fn deinit(fixture: *Fixture) void {
        fixture.plan.deinit();
        fixture.arena.deinit();
        fixture.tmp.cleanup();
    }

    fn planned(fixture: *Fixture, display_path: []const u8) []const u8 {
        for (fixture.plan.files.items) |file| {
            if (std.mem.eql(u8, file.display_path, display_path)) return file.new;
        }
        return "(not planned)";
    }
};

test "the scheme and the kdeglobals block hold the set colors, sets without any are left out" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    const app: App = .{
        .window = .{ .background_normal = kosm.hex("041c26"), .foreground_normal = kosm.hex("a3c5cc") },
        .header_inactive = .{ .background_normal = kosm.hex("000000") },
        .window_manager = .{ .active_background = kosm.hex("082e3f") },
    };
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(
        \\[General]
        \\ColorScheme=kosm
        \\Name=krystallos.dark
        \\
        \\[Colors:Window]
        \\BackgroundNormal=4,28,38
        \\ForegroundNormal=163,197,204
        \\
        \\[Colors:Header][Inactive]
        \\BackgroundNormal=0,0,0
        \\
        \\[WM]
        \\activeBackground=8,46,63
        \\
    , fixture.planned("~/.local/share/color-schemes/kosm.colors"));
    const globals = fixture.planned("~/.config/kdeglobals");
    try testing.expect(std.mem.startsWith(u8, globals, "[General]\nColorScheme=Ricer\n\n[KDE]\nwidgetStyle=Breeze\n"));
    try testing.expect(std.mem.indexOf(u8, globals, "# kosm:begin kosm\n[General]\nColorScheme=kosm\n\n[Colors:Window]\nBackgroundNormal=4,28,38\n") != null);
}

test "per kosmos, the scheme is a file of the kosmos' own, selected by it and showing the theme's name" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    const app: App = .{ .files = .per_kosmos, .name = "Krystallos", .window = .{ .background_normal = kosm.hex("041c26") } };
    try app.apply(&fixture.output);
    const scheme = fixture.planned("~/.local/share/color-schemes/krystallos.dark.colors");
    try testing.expect(std.mem.startsWith(u8, scheme, "[General]\nColorScheme=krystallos.dark\nName=Krystallos\n"));
    try testing.expect(std.mem.indexOf(u8, fixture.planned("~/.config/kdeglobals"), "# kosm:begin kosm\n[General]\nColorScheme=krystallos.dark\n") != null);

    var without_scheme: Fixture = undefined;
    try without_scheme.init();
    defer without_scheme.deinit();
    const globals_only: App = .{ .scheme = null, .files = .per_kosmos };
    try globals_only.apply(&without_scheme.output);
    try testing.expect(std.mem.indexOf(u8, without_scheme.planned("~/.config/kdeglobals"), "ColorScheme=krystallos.dark\n") != null);
}

test "from fills every set, and the selection's text is readable on cyan" {
    const theme = kosm.Theme.from(.{ .palette = .{ .black = kosm.hex("041c26"), .white = kosm.hex("a3c5cc"), .cyan = kosm.hex("2e9990") }, .mode = .dark });
    const app = from(theme);
    inline for (.{ app.window, app.view, app.button, app.selection, app.tooltip, app.complementary, app.header, app.header_inactive }) |set| {
        inline for (@typeInfo(Set).@"struct".field_names) |field| try testing.expect(@field(set, field) != null);
    }
    try testing.expectEqual(theme.variations.contrast.on.apply(theme.palette.cyan), app.selection.foreground_normal.?);
    try testing.expectEqualStrings("BackgroundNormal", comptime keyName("background_normal", .pascal));
    try testing.expectEqualStrings("inactiveBlend", comptime keyName("inactive_blend", .camel));
}
