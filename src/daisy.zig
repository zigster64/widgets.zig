const std = @import("std");
const Io = std.Io;
const root = @import("root.zig");

// ── DaisyUI ──
pub const DuColor = enum { primary, secondary, accent, neutral, info, success, warning, err, ghost };
pub const DuSize = enum { xs, sm, md, lg, xl };
pub const DuBtnVariant = enum { primary, secondary, accent, neutral, ghost, link, outline, dash, soft };
pub fn DaisyUI(writer: *Io.Writer) DaisyWidget {
    return .{ .html = Html(writer) };
}
pub const DaisyWidget = struct {
    html: HtmlWidget,
    fn colorClass(c: DuColor) []const u8 {
        return switch (c) {
            .err => "error",
            else => @tagName(c),
        };
    }
    fn sizeClass(s: DuSize) []const u8 {
        return @tagName(s);
    }
