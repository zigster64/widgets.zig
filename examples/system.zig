const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");

fn winOpen(w: *Io.Writer, title: []const u8) !void {
    try w.print("<div class=\"window\"><div class=\"title-bar\"><button class=\"close\"></button><h1 class=\"title\">{s}</h1><button class=\"resize\"></button></div><div class=\"separator\"></div><div class=\"window-pane\">", .{title});
}

pub fn systemPage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/macintosh.html", .{});
    defer file.close(io);

    var buf: [24576]u8 = undefined;
    var fw = Io.File.Writer.init(file, io, &buf);
    const w = &fw.interface;

    try w.writeAll(
        \\<!DOCTYPE html>
        \\<html lang="en">
        \\<head>
        \\<meta charset="utf-8">
        \\<meta name="viewport" content="width=device-width, initial-scale=1">
        \\<link rel="stylesheet" href="https://sakofchit.github.io/system.css/system.css">
        \\<title>Macintosh System 6</title>
        \\</head>
        \\<body style="background:#c0c0c0; margin:0; padding:0;">
        \\
    );

    const h = widgets_zig.SystemCSS(w);

    // Menu bar
    try w.writeAll(
        \\<ul role="menu-bar">
        \\  <li role="menu-item" tabindex="0" aria-haspopup="true">File
        \\    <ul role="menu">
        \\      <li role="menu-item"><a href="/">Home</a></li>
        \\      <li role="menu-item"><a href="pico.html">PicoCSS</a></li>
        \\      <li role="menu-item"><a href="daisy.html">DaisyUI</a></li>
        \\    </ul>
        \\  </li>
        \\  <li role="menu-item" tabindex="0" aria-haspopup="true">Demos
        \\    <ul role="menu">
        \\      <li role="menu-item"><a href="jelly.html">JellyUI</a></li>
        \\      <li role="menu-item"><a href="snes.html">SNES.css</a></li>
        \\      <li role="menu-item"><a href="nes.html">NES.css</a></li>
        \\      <li role="menu-item"><a href="orbit.html">Orbit</a></li>
        \\      <li role="menu-item"><a href="atari.html">Atari</a></li>
        \\      <li role="menu-item"><a href="handdrawn.html">Handdrawn</a></li>
        \\    </ul>
        \\  </li>
        \\  <li role="menu-item" tabindex="0" aria-haspopup="true">Retro
        \\    <ul role="menu">
        \\      <li role="menu-item"><a href="win98.html">Win98</a></li>
        \\      <li role="menu-item"><a href="tui.html">TuiCss</a></li>
        \\      <li role="menu-item"><a href="nes.html">NES</a></li>
        \\      <li role="menu-item"><a href="snes.html">SNES</a></li>
        \\    </ul>
        \\  </li>
        \\</ul>
        \\
    );

    // Desktop icons
    try w.writeAll("<div style=\"display:flex; gap:12px; padding:16px; flex-wrap:wrap\">\n");
    for ([_][3][]const u8{
        .{ "🖥️", "PicoCSS", "pico.html" },
        .{ "🖥️", "JellyUI", "jelly.html" },
        .{ "🖥️", "DaisyUI", "daisy.html" },
        .{ "🖥️", "NES", "nes.html" },
        .{ "🖥️", "Win98", "win98.html" },
        .{ "🖥️", "Orbit", "orbit.html" },
        .{ "🖥️", "Snes", "snes.html" },
        .{ "🖥️", "TUI", "tui.html" },
        .{ "🖥️", "Atari", "atari.html" },
        .{ "🖥️", "Handdrawn", "handdrawn.html" },
        .{ "🗑️", "Trash", "#" },
    }) |icon| {
        try w.print("<a href=\"{s}\" style=\"text-align:center;width:64px;text-decoration:none;color:#000;display:inline-block\"><div style=\"font-size:24px;line-height:1.2\">{s}</div><div style=\"font-size:9px;line-height:1.1;word-wrap:break-word\">{s}</div></a>\n", .{ icon[2], icon[0], icon[1] });
    }
    try w.writeAll("</div>\n");

    // ── Widgets Demo window ──
    try winOpen(w, "Widgets.zig");
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("Abstract Widget Toolkit — generates HTML for 11 CSS frameworks from a single API.");
    }
    {
        const fs = try h.fieldset("Frameworks");
        defer fs.close();
        for ([_][]const u8{ "PicoCSS", "DaisyUI", "JellyUI", "SNES.css", "NES.css", "98.css", "System.css", "Orbit", "TuiCss" }) |fwidget| {
            const cb = try h.checkbox(fwidget);
            defer cb.close();
        }
    }
    try w.writeAll("</div></div>\n");

    // ── Control Panel ──
    try winOpen(w, "Control Panel");
    {
        const fs = try h.fieldset("Desktop Pattern");
        defer fs.close();
        {
            const r = try h.radio("8-color", "pattern");
            defer r.close();
        }
        {
            const r = try h.radio("Gray", "pattern");
            defer r.close();
        }
    }
    {
        const fs = try h.fieldset("Mouse");
        defer fs.close();
        {
            const r = try h.radio("Very Slow", "speed");
            defer r.close();
        }
        {
            const r = try h.radio("Slow", "speed");
            defer r.close();
        }
        {
            const r = try h.radio("Fast", "speed");
            defer r.close();
        }
        {
            const cb = try h.checkbox("Double-Click Speed");
            defer cb.close();
        }
    }
    try w.writeAll("</div></div>\n");

    // ── Notepad ──
    try winOpen(w, "Notepad");
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("Supports 11 CSS frameworks:");
    }
    for ([_][]const u8{ "PicoCSS — Semantic", "DaisyUI — Tailwind", "JellyUI — Web Components", "SNES.css — 16-bit", "NES.css — 8-bit", "98.css — Windows", "System.css — Macintosh", "Orbit — Radial", "TuiCss — Terminal" }) |line| {
        {
            const p = try h.html.el("p", .{});
            defer p.close();
            try h.html.text(line);
        }
    }
    try w.writeAll("</div></div>\n");

    // ── Installer ──
    try winOpen(w, "Installer");
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("Installing Widgets.zig v0.1.0");
    }
    {
        const pb = try h.progress(65);
        defer pb.close();
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("Items remaining to be installed: 17");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("Installing: src/root.zig...");
    }
    {
        const b = try h.button("Stop");
        defer b.close();
    }
    {
        const b = try h.button("Pause");
        defer b.close();
    }
    try w.writeAll("</div></div>\n");

    // ── Shut Down dialog ──
    try w.writeAll("<div class=\"standard-dialog center\"><p class=\"dialog-text\">Are you sure you want to shut down your computer now?</p><div class=\"dialog-actions\"><button class=\"btn\">Restart</button><button class=\"btn\">Cancel</button><button class=\"btn\">Shut Down</button></div></div>\n");

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created macintosh.html ({d} bytes)", .{fw.pos});
}
