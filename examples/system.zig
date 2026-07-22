const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");

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
        \\  body { background: repeating-conic-gradient(#808080 0% 25%, #c0c0c0 0% 50%) 50% / 4px 4px; margin:0; padding:0; min-height:100vh; }
        \\  .win { position:absolute; width:360px; }
        \\</style>
        \\</head>
        \\<body>
        \\
    );

    const h = widgets_zig.SystemCSS(w);

    // ── Menu bar ──
    try w.writeAll(
        \\<nav class="menu-bar"><ul class="menu-bar-items">
        \\<li class="apple-menu"><span>🍎</span></li>
        \\<li>File</li><li>Edit</li><li>View</li><li>Special</li>
        \\</ul></nav>
        \\
    );

    // ── Finder (top-left) ──
    try w.writeAll("<div class=\"window win\" style=\"top:40px;left:40px;\"><div class=\"title-bar\"><span class=\"title\">Widgets Demos</span></div><div class=\"separator\"></div><div class=\"window-pane\">");
    for ([_][2][]const u8{
        .{ "📄 index", "/" }, .{ "📄 PicoCSS", "pico.html" }, .{ "📄 JellyUI", "jelly.html" },
        .{ "📄 DaisyUI", "daisy.html" }, .{ "📄 NES", "nes.html" },
        .{ "📄 Win98", "win98.html" }, .{ "📄 Orbit", "orbit.html" },
        .{ "📄 Snes", "snes.html" },
    }) |link| {
        const a = try h.html.el("a", .{ .href = link[1] });
        defer a.close();
        try h.html.text(link[0]);
    }
    try w.writeAll("</div></div>\n");

    // ── Control Panel (top-right) ──
    try w.writeAll("<div class=\"window win\" style=\"top:40px;right:40px;\"><div class=\"title-bar\"><span class=\"title\">Control Panel</span></div><div class=\"separator\"></div><div class=\"window-pane\">");
    {
        const fs = try h.fieldset("Display");
        defer fs.close();
        {
            const r1 = try h.radio("Black & White", "depth");
            defer r1.close();
        }
        {
            const r2 = try h.radio("256 Colors", "depth");
            defer r2.close();
        }
        {
            const r3 = try h.radio("Thousands", "depth");
            defer r3.close();
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
    try w.writeAll("</div></div>\n");

    // ── Notepad (middle) ──
    try w.writeAll("<div class=\"window win\" style=\"top:280px;left:100px;\"><div class=\"title-bar\"><span class=\"title\">Notepad</span></div><div class=\"separator\"></div><div class=\"window-pane\">");
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("Widgets.zig generates HTML for multiple CSS frameworks from one API.");
    }
    try w.writeAll("</div></div>\n");

    // ── Installer (bottom-right) ──
    try w.writeAll("<div class=\"window win\" style=\"bottom:40px;right:100px;\"><div class=\"title-bar\"><span class=\"title\">Installer</span></div><div class=\"separator\"></div><div class=\"window-pane\">");
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
    try w.writeAll("</div></div>\n");

    // ── Trash (bottom-left) ──
    try w.writeAll("<div class=\"window win\" style=\"bottom:40px;left:40px;width:200px;\"><div class=\"title-bar\"><span class=\"title\">Trash</span></div><div class=\"separator\"></div><div class=\"window-pane\">");
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("🗑️ 3 items");
    }
    try w.writeAll("</div></div>\n");

    // ── Shut Down dialog ──
    {
        const d = try h.dialog("Are you sure you want to shut down your computer now?");
        defer d.close();
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created system.html ({d} bytes)", .{fw.pos});
}
