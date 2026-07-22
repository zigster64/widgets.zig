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
        \\<title>System 6 Desktop</title>
        \\<style>
        \\  body { background:#c0c0c0; margin:0; padding:24px; max-width:900px; margin-left:auto; margin-right:auto; }
        \\  .window + .window { margin-top: 16px; }
        \\</style>
        \\</head>
        \\<body>
        \\
    );

    const h = Sy.SystemCSS(w);

    // Menu bar
    try w.writeAll(
        \\<nav class="menu-bar"><ul class="menu-bar-items">
        \\<li class="apple-menu"><span>🍎</span></li>
        \\<li>File</li><li>Edit</li><li>View</li><li>Special</li>
        \\</ul></nav>
        \\
    );

    // Nav window
    {
        const win = try h.window("Widgets Demos");
        defer win.close();
        for ([_][2][]const u8{
            .{ "📄 Home", "/" }, .{ "📄 Pico", "pico.html" }, .{ "📄 Jelly", "jelly.html" },
            .{ "📄 Daisy", "daisy.html" }, .{ "📄 NES", "nes.html" },
            .{ "📄 Win98", "win98.html" }, .{ "📄 Orbit", "orbit.html" },
            .{ "📄 Snes", "snes.html" }, .{ "📄 TUI", "tui.html" },
        }) |link| {
            const a = try h.html.el("a", .{ .href = link[1] });
            defer a.close();
            try h.html.text(link[0]);
        }
    }

    // Control Panel
    {
        const win = try h.window("Control Panel");
        defer win.close();
        {
            const fs = try h.fieldset("Display");
            defer fs.close();
            {
                const r = try h.radio("Black & White", "depth");
                defer r.close();
            }
            {
                const r = try h.radio("256 Colors", "depth");
                defer r.close();
            }
            {
                const r = try h.radio("Thousands", "depth");
                defer r.close();
            }
        }
        {
            const fs = try h.fieldset("Sound");
            defer fs.close();
            {
                const cb = try h.checkbox("Alert sounds");
                defer cb.close();
            }
            try h.html.elVoid("input", .{ .@"type" = "range" });
        }
    }

    // Notepad
    {
        const win = try h.window("Notepad");
        defer win.close();
        {
            const p = try h.html.el("p", .{});
            defer p.close();
            try h.html.text("Widgets.zig is an Abstract Widget Toolkit for Zig.");
        }
        {
            const p = try h.html.el("p", .{});
            defer p.close();
            try h.html.text("It maps abstract widget calls to framework-specific HTML — PicoCSS, DaisyUI, JellyUI, NES, 98, System 6, and more.");
        }
    }

    // Installer
    {
        const win = try h.window("Installer");
        defer win.close();
        {
            const p = try h.html.el("p", .{});
            defer p.close();
            try h.html.text("Copying files...");
        }
        {
            const pb = try h.progress(65);
            defer pb.close();
        }
        {
            const p = try h.html.el("p", .{});
            defer p.close();
            try h.html.text("65% — 42 files remaining");
        }
        {
            const b = try h.button("Stop");
            defer b.close();
        }
    }

    // Shut Down dialog
    {
        const d = try h.dialog("Are you sure you want to shut down your computer now?");
        defer d.close();
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created system.html ({d} bytes)", .{fw.pos});
}
