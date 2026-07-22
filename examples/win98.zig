const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");
const W98 = widgets_zig;

pub fn win98Page(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/win98.html", .{});
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
        \\<link rel="stylesheet" href="https://unpkg.com/98.css">
        \\<title>98.css Demo</title>
        \\</head>
        \\<body style="background:#008080;padding:24px;max-width:800px;margin:0 auto">
        \\
    );

    const h = W98.Win98CSS(w);

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
        }) |link| {
            const a = try h.html.el("a", .{ .href = link[1] });
            defer a.close();
            const b = try h.button(link[0]);
            defer b.close();
        }
    }

    // Main window
    {
        const win = try h.window("Windows 98 Widgets Demo");
        defer win.close();

        // Fieldset: Buttons
        {
            const fs = try h.fieldset("Standard Buttons");
            defer fs.close();
            for ([_][]const u8{ "OK", "Cancel", "Apply" }) |txt| {
                const b = try h.button(txt);
                defer b.close();
            }
        }

        // Fieldset: Form
        {
            const fs = try h.fieldset("Form Controls");
            defer fs.close();
            {
                const fr = try h.fieldRow("Name:");
                defer fr.close();
            }
            {
                const fr = try h.fieldRow("Email:");
                defer fr.close();
            }
            {
                const dd = try h.dropdown();
                defer dd.close();
            }
            try h.checkbox("cb1", "Enable feature");
            try h.radio("r1", "group1", "Option A");
            try h.radio("r2", "group1", "Option B");
            try h.slider();
        }

        // Fieldset: Tree View
        {
            const fs = try h.fieldset("Tree View");
            defer fs.close();
            {
                const tv = try h.treeView();
                defer tv.close();
                for ([_][]const u8{ "Desktop", "My Computer", "Recycle Bin" }) |item| {
                    const li = try h.html.el("li", .{});
                    defer li.close();
                    try h.html.text(item);
                }
            }
        }

        // Fieldset: Progress
        {
            const fs = try h.fieldset("Progress");
            defer fs.close();
            {
                const p = try h.progress(65);
                defer p.close();
            }
        }

        // Status bar
        {
            const sb = try h.statusBar("Ready");
            defer sb.close();
        }
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created win98.html ({d} bytes)", .{fw.pos});
}
