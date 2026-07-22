const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");
const Sy = widgets_zig;

pub fn systemPage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/system.html", .{});
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
        \\<link rel="stylesheet" href="https://unpkg.com/@sakofchit/system.css@2.1.1/dist/system.min.css">
        \\<title>System.css Demo</title>
        \\</head>
        \\<body style="padding:24px;max-width:800px;margin:0 auto">
        \\
    );

    const h = Sy.SystemCSS(w);

    // Nav window
    {
        const win = try h.window("Navigation");
        defer win.close();
        for ([_][2][]const u8{
            .{ "Home", "/" },
            .{ "Pico", "pico.html" },
            .{ "Jelly", "jelly.html" },
            .{ "Daisy", "daisy.html" },
            .{ "NES", "nes.html" },
            .{ "Win98", "win98.html" },
            .{ "System", "system.html" },
        }) |link| {
            const a = try h.html.el("a", .{ .href = link[1] });
            defer a.close();
            const b = try h.button(link[0]);
            defer b.close();
        }
    }

    // Main window
    {
        const win = try h.window("System 6 Widgets Demo");
        defer win.close();

        // Fieldset: Buttons
        {
            const fs = try h.fieldset("Buttons");
            defer fs.close();
            for ([_][]const u8{ "OK", "Cancel", "Retry" }) |txt| {
                const b = try h.button(txt);
                defer b.close();
            }
        }

        // Fieldset: Form
        {
            const fs = try h.fieldset("Form Controls");
            defer fs.close();
            try h.input();
            try h.input();
            {
                const sel = try h.select();
                defer sel.close();
            }
            {
                const cb = try h.checkbox("Check me");
                defer cb.close();
            }
            {
                const r1 = try h.radio("A", "group");
                defer r1.close();
            }
            {
                const r2 = try h.radio("B", "group");
                defer r2.close();
            }
        }

        // Dialog
        {
            const d = try h.dialog("This is a System 6 style dialog.");
            defer d.close();
        }

        // Progress
        {
            const fs = try h.fieldset("Progress");
            defer fs.close();
            {
                const p = try h.progress(45);
                defer p.close();
            }
        }
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created system.html ({d} bytes)", .{fw.pos});
}
