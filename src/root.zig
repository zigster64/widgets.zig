const std = @import("std");
const Io = std.Io;

pub fn Html(writer: *Io.Writer) HtmlWidget {
    return .{ .writer = writer };
}

pub const Closer = struct {
    writer: *Io.Writer,
    tag: []const u8,

    pub fn close(self: Closer) void {
        self.writer.print("</{s}>\n", .{self.tag}) catch {};
    }
};

pub const HtmlWidget = struct {
    writer: *Io.Writer,

    fn isStringLike(comptime T: type) bool {
        const ti = @typeInfo(T);
        if (ti == .optional) {
            return isStringLike(@typeInfo(T).optional.child);
        }
        return switch (ti) {
            .pointer => |p| switch (p.size) {
                .slice => p.child == u8,
                .one => if (@typeInfo(p.child) == .array) @typeInfo(p.child).array.child == u8 else false,
                else => false,
            },
            else => false,
        };
    }

    fn writeAttribs(w: *Io.Writer, attribs: anytype) !void {
        inline for (comptime std.meta.fieldNames(@TypeOf(attribs))) |name| {
            const attr_name = comptime blk: {
                if (std.mem.indexOfScalar(u8, name, '_')) |_| {
                    var buf: [name.len]u8 = undefined;
                    for (name, 0..) |c, i| buf[i] = if (c == '_') '-' else c;
                    break :blk buf;
                }
                break :blk name;
            };
            const val = @field(attribs, name);
            if (comptime @typeInfo(@TypeOf(val)) == .optional) {
                if (val) |v| {
                    if (comptime isStringLike(@TypeOf(v))) {
                        try w.print(" {s}=\"{s}\"", .{ attr_name, v });
                    } else {
                        try w.print(" {s}=\"{any}\"", .{ attr_name, v });
                    }
                }
            } else if (comptime isStringLike(@TypeOf(val))) {
                try w.print(" {s}=\"{s}\"", .{ attr_name, val });
            } else {
                try w.print(" {s}=\"{any}\"", .{ attr_name, val });
            }
        }
    }

    pub fn el(self: HtmlWidget, tag: []const u8, attribs: anytype) !Closer {
        try self.writer.print("<{s}", .{tag});
        try writeAttribs(self.writer, attribs);
        try self.writer.writeAll(">");
        return .{ .writer = self.writer, .tag = tag };
    }

    pub fn html(self: HtmlWidget, attribs: anytype) !Closer {
        try self.writer.writeAll("<!DOCTYPE html>\n<html");
        try writeAttribs(self.writer, attribs);
        try self.writer.writeAll(">\n");
        return .{ .writer = self.writer, .tag = "html" };
    }

    pub fn elVoid(self: HtmlWidget, tag: []const u8, attribs: anytype) !void {
        try self.writer.print("<{s}", .{tag});
        try writeAttribs(self.writer, attribs);
        try self.writer.writeAll(">\n");
    }

    pub fn text(self: HtmlWidget, content: []const u8) !void {
        try self.writer.writeAll(content);
    }

    pub fn head(self: HtmlWidget, attribs: anytype) !Closer {
        return self.el("head", attribs);
    }

    pub fn body(self: HtmlWidget, attribs: anytype) !Closer {
        return self.el("body", attribs);
    }

    pub fn meta(self: HtmlWidget, attribs: anytype) !void {
        try self.elVoid("meta", attribs);
    }

    pub fn title(self: HtmlWidget, txt: []const u8, attribs: anytype) !Closer {
        const c = try self.el("title", attribs);
        try self.writer.writeAll(txt);
        return c;
    }

    pub fn h1(self: HtmlWidget, txt: []const u8, attribs: anytype) !Closer {
        const c = try self.el("h1", attribs);
        try self.writer.writeAll(txt);
        return c;
    }
};

// ── PicoCSS ──

pub fn PicoCSS(writer: *Io.Writer) PicoWidget {
    return .{ .html = Html(writer) };
}

pub const PicoWidget = struct {
    html: HtmlWidget,

    /// `<article>` — Pico card
    pub fn card(self: PicoWidget, attribs: anytype) !Closer {
        return self.html.el("article", attribs);
    }

    /// `<button attribs>txt` → `</button>`
    pub fn button(self: PicoWidget, txt: []const u8, attribs: anytype) !Closer {
        const c = try self.html.el("button", attribs);
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<nav attribs>`
    pub fn nav(self: PicoWidget, attribs: anytype) !Closer {
        return self.html.el("nav", attribs);
    }

    /// `<div class="grid">`
    pub fn grid(self: PicoWidget) !Closer {
        return self.html.el("div", .{ .class = "grid" });
    }

    /// `<details attribs><summary>summary</summary>`
    pub fn accordion(self: PicoWidget, summary: []const u8, attribs: anytype) !Closer {
        const c = try self.html.el("details", attribs);
        try self.html.writer.print("<summary>{s}</summary>", .{summary});
        return c;
    }

    /// `<progress value="val" max="max">` — container, not void
    pub fn progress(self: PicoWidget, value: u32, max: u32) !Closer {
        return self.html.el("progress", .{ .value = value, .max = max });
    }

    /// `<dialog attribs><article>` —  closer emits `</article></dialog>`
    pub fn modal(self: PicoWidget, attribs: anytype) !ModalCloser {
        try self.html.writer.print("<dialog", .{});
        try HtmlWidget.writeAttribs(self.html.writer, attribs);
        try self.html.writer.writeAll(">\n<article>");
        return .{ .writer = self.html.writer };
    }

    /// `<table attribs>`
    pub fn table(self: PicoWidget, attribs: anytype) !Closer {
        return self.html.el("table", attribs);
    }

    /// `<nav aria-label="breadcrumb"><ul>`
    pub fn breadcrumbs(self: PicoWidget) !Closer {
        const c = try self.html.el("nav", .{ .aria_label = "breadcrumb" });
        try self.html.writer.writeAll("<ul>");
        return c;
    }

    /// `<div class="container">`
    pub fn container(self: PicoWidget) !Closer {
        return self.html.el("div", .{ .class = "container" });
    }
};

pub const ModalCloser = struct {
    writer: *Io.Writer,

    pub fn close(self: ModalCloser) void {
        self.writer.writeAll("</article>\n</dialog>\n") catch {};
    }
};
