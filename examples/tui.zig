const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");
const Tu = widgets_zig;

pub fn tuiPage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/tui.html", .{});
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
        \\<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tuicss@2.1.2">
        \\<title>TuiCss Demo</title>
        \\</head>
        \\<body style="background:#000;padding:16px;max-width:900px;margin:0 auto">
        \\
    );

    const h = Tu.TuiCSS(w);

    // Nav panel
    {
        const p = try h.panel("Widgets Demos");
        defer p.close();
        for ([_][2][]const u8{
            .{ "Home", "/" }, .{ "Pico", "pico.html" }, .{ "Jelly", "jelly.html" },
            .{ "Daisy", "daisy.html" },
            .{ "Snes", "snes.html" }, .{ "NES", "nes.html" },
            .{ "Atari", "atari.html" },
            .{ "Handdrawn", "handdrawn.html" },
            .{ "Doodle", "doodle.html" },
            .{ "Win98", "win98.html" }, .{ "Macintosh", "macintosh.html" },
            .{ "Orbit", "orbit.html" }, .{ "TUI", "tui.html" },
        }) |link| {
            const a = try h.html.el("a", .{ .href = link[1] });
            defer a.close();
            const b = try h.button(link[0], .cyan);
            defer b.close();
        }
    }

    // Buttons panel
    {
        const p = try h.panel("Buttons");
        defer p.close();
        for ([_]Tu.TuiColor{ .cyan, .green, .yellow, .red, .white, .blue, .magenta }) |c| {
            const b = try h.button(@tagName(c), c);
            defer b.close();
        }
    }

    // Form panel
    {
        const p = try h.panel("Form");
        defer p.close();
        try h.textbox("Username:");
        try h.textbox("Password:");
        {
            const fs = try h.fieldset("Options");
            defer fs.close();
            {
                const cb = try h.checkbox("Remember me");
                defer cb.close();
            }
            {
                const cb = try h.checkbox("Dark mode");
                defer cb.close();
            }
            {
                const r1 = try h.radio("Tabs", "mode");
                defer r1.close();
            }
            {
                const r2 = try h.radio("Spaces", "mode");
                defer r2.close();
            }
        }
        {
            const b = try h.button("Submit", .green);
            defer b.close();
        }
        {
            const b = try h.button("Cancel", .red);
            defer b.close();
        }
    }

    // Progress panel
    {
        const p = try h.panel("Progress");
        defer p.close();
        {
            const pg = try h.progress(75);
            defer pg.close();
        }
        {
            const pg = try h.progress(45);
            defer pg.close();
        }
    }

    // Table panel
    {
        const p = try h.panel("Processes");
        defer p.close();
        {
            const tbl = try h.table();
            defer tbl.close();
            const thead = try h.html.el("thead", .{});
            defer thead.close();
            {
                const tr = try h.html.el("tr", .{});
                defer tr.close();
                for ([_][]const u8{ "PID", "Name", "CPU", "MEM" }) |hdr| {
                    const th = try h.html.el("th", .{});
                    defer th.close();
                    try h.html.text(hdr);
                }
            }
            const tbody = try h.html.el("tbody", .{});
            defer tbody.close();
            const rows = [_][4][]const u8{
                .{ "1234", "zig build", "42%", "128M" },
                .{ "5678", "widgets.zig", "15%", "64M" },
                .{ "9012", "pico.css", "3%", "32M" },
            };
            for (&rows) |row| {
                const tr = try h.html.el("tr", .{});
                defer tr.close();
                for (&row) |cell| {
                    const td = try h.html.el("td", .{});
                    defer td.close();
                    try h.html.text(cell);
                }
            }
        }
    }

    // Status bar
    {
        const sb = try h.statusbar(&[_][]const u8{ "Widgets.zig v0.0.0", "10 frameworks", "1 file" });
        defer sb.close();
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created tui.html ({d} bytes)", .{fw.pos});
}
