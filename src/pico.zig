const std = @import("std");
const Io = std.Io;
const root = @import("root.zig");

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
