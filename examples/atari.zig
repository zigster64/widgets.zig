const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");

pub fn atariPage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/atari.html", .{});
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
        \\<link rel="stylesheet" href="https://unpkg.com/nes.css@2.3.0/css/nes.min.css">
        \\<link rel="stylesheet" href="https://raw.githubusercontent.com/littleli/atari.css-showcase/main/style.css">
        \\<title>Atari ST Demo</title>
        \\</head>
        \\<body style="padding:24px;max-width:900px;margin:0 auto;background:#1a1a2e;color:#e0e0e0">
        \\
    );

    const h = widgets_zig.AtariCSS(w);

    // Nav
    {
        const nav = try h.html.el("nav", .{});
        defer nav.close();
        for ([_][2][]const u8{
            .{ "Home", "/" }, .{ "Pico", "pico.html" }, .{ "Daisy", "daisy.html" },
            .{ "Jelly", "jelly.html" }, .{ "Snes", "snes.html" }, .{ "NES", "nes.html" },
            .{ "Atari", "atari.html" },
            .{ "Handdrawn", "handdrawn.html" },
            .{ "Doodle", "doodle.html" }, .{ "Win98", "win98.html" },
            .{ "Macintosh", "macintosh.html" }, .{ "Orbit", "orbit.html" }, .{ "TUI", "tui.html" },
        }) |link| {
            const a = try h.html.el("a", .{ .href = link[1] });
            defer a.close();
            const b = try h.button(link[0], null);
            defer b.close();
        }
    }

    // Containers
    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("Atari ST Widgets Demo");
            defer t.close();
        }
        {
            const p = try h.html.el("p", .{});
            defer p.close();
            try h.html.text("Atari.css brings the 16-bit Atari ST aesthetic. Built on NES.css with custom fonts and palette.");
        }
    }

    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("Buttons");
            defer t.close();
        }
        for ([_]widgets_zig.NesVariant{ .primary, .success, .warning, .err }) |v| {
            const b = try h.button(@tagName(v), v);
            defer b.close();
        }
        {
            const b = try h.button("Default", null);
            defer b.close();
        }
    }

    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("Badges");
            defer t.close();
        }
        for ([_]widgets_zig.NesVariant{ .primary, .success, .warning, .err }) |v| {
            const b = try h.badge(@tagName(v), v);
            defer b.close();
        }
    }

    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("Progress");
            defer t.close();
        }
        {
            const p = try h.progress(75, .primary);
            defer p.close();
        }
        {
            const p = try h.progress(40, .warning);
            defer p.close();
        }
    }

    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("Form");
            defer t.close();
        }
        try h.input("text", "Character name");
        try h.input("email", "games@atari.st");
        {
            const ta = try h.textarea("High score message...");
            defer ta.close();
        }
        {
            const sel = try h.select();
            defer sel.close();
            for ([_][]const u8{ "Dungeon Master", "Xenon 2", "Lemmings" }) |opt| {
                const o = try h.html.el("option", .{ .value = opt });
                defer o.close();
                try h.html.text(opt);
            }
        }
        {
            const cb = try h.checkbox("Save progress");
            defer cb.close();
        }
        {
            const r1 = try h.radio("MIDI", "music");
            defer r1.close();
        }
        {
            const r2 = try h.radio("YM2149", "music");
            defer r2.close();
        }
    }

    {
        const b = try h.balloon("Atari ST power without the price.");
        defer b.close();
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created atari.html ({d} bytes)", .{fw.pos});
}
