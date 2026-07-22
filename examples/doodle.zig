const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");

pub fn doodlePage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/doodle.html", .{});
    defer file.close(io);
    var buf: [16384]u8 = undefined;
    var fw = Io.File.Writer.init(file, io, &buf);
    const w = &fw.interface;
    try w.writeAll(
        \\<!DOCTYPE html>
        \\<html lang="en">
        \\<head>
        \\<meta charset="utf-8">
        \\<meta name="viewport" content="width=device-width, initial-scale=1">
        \\<link rel="stylesheet" href="https://chr15m.github.io/DoodleCSS/doodle.css">
        \\<title>DoodleCSS Demo</title>
        \\</head>
        \\<body style="padding:24px;max-width:800px;margin:0 auto">
        \\
    );
    const h = widgets_zig.DoodleCSS(w);
    // Nav
    {
        const nav = try h.el("nav", .{});
        defer nav.close();
        for ([_][2][]const u8{
            .{ "Home", "/" }, .{ "Pico", "pico.html" }, .{ "Daisy", "daisy.html" },
            .{ "Jelly", "jelly.html" }, .{ "Snes", "snes.html" }, .{ "NES", "nes.html" },
            .{ "Atari", "atari.html" }, .{ "Win98", "win98.html" },
            .{ "Macintosh", "macintosh.html" }, .{ "Orbit", "orbit.html" },
            .{ "TUI", "tui.html" }, .{ "Handdrawn", "handdrawn.html" },
            .{ "Doodle", "doodle.html" },
        }) |link| {
            const a = try h.el("a", .{ .href = link[1] });
            defer a.close();
            try h.text(link[0]);
        }
    }
    {
        const h1 = try h.h1("DoodleCSS Widgets Demo", .{});
        defer h1.close();
    }
    {
        const h2 = try h.el("h2", .{});
        defer h2.close();
        try h.text("Buttons");
    }
    for ([_][]const u8{ "Click me", "Also click", "Don't click" }) |txt| {
        const b = try h.el("button", .{});
        defer b.close();
        try h.text(txt);
    }
    {
        const h2 = try h.el("h2", .{});
        defer h2.close();
        try h.text("Form");
    }
    try h.elVoid("input", .{ .@"type" = "text", .placeholder = "Name" });
    try h.elVoid("input", .{ .@"type" = "email", .placeholder = "Email" });
    {
        const sel = try h.el("select", .{});
        defer sel.close();
        for ([_][]const u8{ "Option 1", "Option 2" }) |opt| {
            const o = try h.el("option", .{});
            defer o.close();
            try h.text(opt);
        }
    }
    {
        const lbl = try h.el("label", .{});
        defer lbl.close();
        try h.elVoid("input", .{ .@"type" = "checkbox" });
        try h.text("Check me out");
    }
    {
        const lbl = try h.el("label", .{});
        defer lbl.close();
        try h.elVoid("input", .{ .@"type" = "radio", .name = "r" });
        try h.text("Radio Ga Ga");
    }
    {
        const h2 = try h.el("h2", .{});
        defer h2.close();
        try h.text("Table");
    }
    {
        const tbl = try h.el("table", .{});
        defer tbl.close();
        const tr = try h.el("tr", .{});
        defer tr.close();
        for ([_][]const u8{ "Doodle", "CSS", "Rocks" }) |cell| {
            const td = try h.el("td", .{});
            defer td.close();
            try h.text(cell);
        }
    }
    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created doodle.html ({d} bytes)", .{fw.pos});
}
