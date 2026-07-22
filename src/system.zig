const std = @import("std");
const Io = std.Io;
const root = @import("root.zig");

// ── System.css ──
pub fn SystemCSS(writer: *Io.Writer) SystemWidget {
    return .{ .html = Html(writer) };
}
pub const SystemWidget = struct {
    html: HtmlWidget,
    /// `<div class="window"><div class="title-bar"><span>title</span></div><div class="window-pane">`
    pub fn window(self: SystemWidget, title: []const u8) !Closer {
        const c = try self.html.el("div", .{ .class = "window" });
        {
            const tb = try self.html.el("div", .{ .class = "title-bar" });
            defer tb.close();
            const sp = try self.html.el("span", .{ .class = "title" });
            defer sp.close();
            try self.html.writer.writeAll(title);
        }
        const pane = try self.html.el("div", .{ .class = "window-pane" });
        _ = c;
        return pane;
    }
    /// `<div class="standard-dialog"><p>txt</p></div>`
    pub fn dialog(self: SystemWidget, txt: []const u8) !Closer {
        const c = try self.html.el("div", .{ .class = "standard-dialog center" });
        {
            const p = try self.html.el("p", .{ .class = "dialog-text" });
            defer p.close();
            try self.html.writer.writeAll(txt);
        }
        return c;
    }
    /// `<button class="btn">txt</button>`
    pub fn button(self: SystemWidget, txt: []const u8) !Closer {
        const c = try self.html.el("button", .{ .class = "btn" });
        try self.html.writer.writeAll(txt);
        return c;
    }
    /// `<div class="field-row"><input type="text"></div>`
    pub fn input(self: SystemWidget) !void {
        try self.html.elVoid("div", .{ .class = "field-row" });
        try self.html.elVoid("input", .{ .type = "text" });
    }
    /// `<fieldset><legend>title</legend>`
    pub fn fieldset(self: SystemWidget, legend: []const u8) !Closer {
        const c = try self.html.el("fieldset", .{});
        const l = try self.html.el("legend", .{});
        defer l.close();
        try self.html.writer.writeAll(legend);
        return c;
    }
    /// `<select>`
    pub fn select(self: SystemWidget) !Closer {
        return self.html.el("select", .{});
    }
    /// `<label class="checkbox"><input type="checkbox">txt</label>`
    pub fn checkbox(self: SystemWidget, txt: []const u8) !Closer {
        const c = try self.html.el("label", .{ .class = "checkbox" });
        try self.html.elVoid("input", .{ .type = "checkbox" });
        try self.html.writer.writeAll(txt);
        return c;
    }
    /// `<label class="radio"><input type="radio" name="...">txt</label>`
    pub fn radio(self: SystemWidget, txt: []const u8, name: []const u8) !Closer {
        const c = try self.html.el("label", .{ .class = "radio" });
        try self.html.elVoid("input", .{ .type = "radio", .name = name });
        try self.html.writer.writeAll(txt);
        return c;
    }
    /// `<progress value="..." max="100">`
    pub fn progress(self: SystemWidget, value: u32) !Closer {
        return self.html.el("progress", .{ .value = value, .max = 100 });
    }
};
