const std = @import("std");
const Io = std.Io;
const root = @import("root.zig");

// ── TuiCss ──
pub const TuiColor = enum { cyan, green, yellow, red, white, blue, magenta };
pub fn TuiCSS(writer: *Io.Writer) TuiWidget {
    return .{ .html = Html(writer) };
}
pub const TuiWidget = struct {
    html: HtmlWidget,
    pub fn panel(self: TuiWidget, title: []const u8) !Closer {
        const c = try self.html.el("div", .{ .class = "tui-panel" });
        defer c.close();
        {
            const hd = try self.html.el("div", .{ .class = "tui-panel-header" });
            defer hd.close();
            try self.html.writer.writeAll(title);
        }
        return self.html.el("div", .{ .class = "tui-panel-content" });
    }
    pub fn button(self: TuiWidget, txt: []const u8, color: ?TuiColor) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = if (color) |c| std.fmt.bufPrint(&class_buf, "tui-button {s}-168", .{@tagName(c)}) catch "tui-button" else "tui-button";
        const c = try self.html.el("button", .{ .class = cls });
        try self.html.writer.writeAll(txt);
        return c;
    }
    pub fn textbox(self: TuiWidget, label: []const u8) !void {
        {
            const l = try self.html.el("label", .{ .class = "tui-textbox-label" });
            defer l.close();
            try self.html.writer.writeAll(label);
        }
        try self.html.elVoid("input", .{ .class = "tui-textbox", .type = "text" });
    }
    pub fn checkbox(self: TuiWidget, txt: []const u8) !Closer {
        const c = try self.html.el("label", .{ .class = "tui-checkbox" });
        defer c.close();
        try self.html.elVoid("input", .{ .type = "checkbox" });
        try self.html.writer.writeAll(txt);
        return c;
    }
    pub fn radio(self: TuiWidget, txt: []const u8, name: []const u8) !Closer {
        const c = try self.html.el("label", .{ .class = "tui-radio" });
        defer c.close();
        try self.html.elVoid("input", .{ .type = "radio", .name = name });
        try self.html.writer.writeAll(txt);
        return c;
    }
    pub fn fieldset(self: TuiWidget, legend: []const u8) !Closer {
        const c = try self.html.el("fieldset", .{ .class = "tui-fieldset" });
        const l = try self.html.el("legend", .{ .class = "tui-fieldset-legend" });
        defer l.close();
        try self.html.writer.writeAll(legend);
        return c;
    }
    pub fn progress(self: TuiWidget, value: u32) !Closer {
        return self.html.el("progress", .{ .class = "tui-progress", .value = value, .max = 100 });
    }
    pub fn table(self: TuiWidget) !Closer {
        return self.html.el("table", .{ .class = "tui-table" });
    }
    pub fn statusbar(self: TuiWidget, items: []const []const u8) !Closer {
        const c = try self.html.el("div", .{ .class = "tui-statusbar" });
        for (items) |item| {
            const span = try self.html.el("span", .{ .class = "tui-statusbar-text" });
            defer span.close();
            try self.html.writer.writeAll(item);
        }
        return c;
    }
};
pub const ModalCloser = struct {
    writer: *Io.Writer,
    pub fn close(self: ModalCloser) void {
        self.writer.writeAll("</article>\n</dialog>\n") catch {};
    }
};
