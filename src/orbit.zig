const std = @import("std");
const Io = std.Io;
const root = @import("root.zig");

// ── Orbit ──
pub fn OrbitCSS(writer: *Io.Writer) OrbitWidget {
    return .{ .html = Html(writer) };
}
pub const OrbitWidget = struct {
    html: HtmlWidget,
    pub fn bigbang(self: OrbitWidget, theme: ?[]const u8) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = if (theme) |t| std.fmt.bufPrint(&class_buf, "bigbang {s}", .{t}) catch "bigbang" else "bigbang";
        return self.html.el("div", .{ .class = cls });
    }
    pub fn gravitySpot(self: OrbitWidget) !Closer {
        return self.html.el("div", .{ .class = "gravity-spot" });
    }
    pub fn orbit(self: OrbitWidget, comptime level: u8, range_deg: u32) !Closer {
        var class_buf: [48]u8 = undefined;
        const cls = std.fmt.bufPrint(&class_buf, "orbit-{d} range-{d}", .{ level, range_deg }) catch "orbit-1";
        return self.html.el("div", .{ .class = cls });
    }
    pub fn progress(self: OrbitWidget, value: u32) !Closer {
        return self.html.el("o-progress", .{ .value = value });
    }
    pub fn arc(self: OrbitWidget, value: u32, shape: ?[]const u8) !Closer {
        if (shape) |s| return self.html.el("o-arc", .{ .value = value, .shape = s });
        return self.html.el("o-arc", .{ .value = value });
    }
    pub fn satellite(self: OrbitWidget) !Closer {
        return self.html.el("div", .{ .class = "satellite" });
    }
    pub fn capsule(self: OrbitWidget) !Closer {
        return self.html.el("div", .{ .class = "capsule" });
    }
};
