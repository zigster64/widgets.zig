const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");

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
        \\<link rel="stylesheet" href="https://unpkg.com/@sakofchit/system.css@2.1.1/dist/system.min.css">
        \\<title>Macintosh System 6</title>
        \\<style>
        \\  body { background: repeating-conic-gradient(#808080 0% 25%,#c0c0c0 0% 50%) 50%/4px 4px; margin:0; padding:0; min-height:100vh; }
        \\  .desktop { position:relative; width:100%; height:100vh; }
        \\  .app-window { position:absolute; width:340px; }
        \\  .app-window .window-pane { max-height:250px; overflow-y:auto; }
        \\  .app-window .window-pane p { margin:4px 0; }
        \\  .app-window .window-pane a { display:block; padding:1px 0; }
        \\  .app-window .window-pane a:hover { background:#000; color:#fff; }
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
    try w.writeAll("<div class=\"window app-window\" style=\"top:36px;left:24px;\"><div class=\"title-bar\"><span class=\"title\">Widgets Demos</span></div><div class=\"separator\"></div><div class=\"window-pane\">");
    for ([_][2][]const u8{
        .{ "📁 index", "/" }, .{ "📁 PicoCSS", "pico.html" }, .{ "📁 JellyUI", "jelly.html" },
        .{ "📁 DaisyUI", "daisy.html" }, .{ "📁 NES", "nes.html" },
        .{ "📁 Win98", "win98.html" }, .{ "📁 Orbit", "orbit.html" },
        .{ "📁 Snes", "snes.html" }, .{ "📁 TUI", "tui.html" }, .{ "📁 System 6", "macintosh.html" },
    }) |link| {
        const a = try h.html.el("a", .{ .href = link[1] });
        defer a.close();
        try h.html.text(link[0]);
    }
    try w.writeAll("</div></div>\n");

    // ── Control Panel (top-right) ──
    try w.writeAll("<div class=\"window app-window\" style=\"top:36px;right:24px;\"><div class=\"title-bar\"><span class=\"title\">Control Panel</span></div><div class=\"separator\"></div><div class=\"window-pane\">");
    {
        const fs = try h.fieldset("Display");
        defer fs.close();
        {
            const r = try h.radio("Black &amp; White", "depth");
            defer r.close();
        }
        {
            const r = try h.radio("16 Colors", "depth");
            defer r.close();
        }
        {
            const r = try h.radio("256 Colors", "depth");
            defer r.close();
        }
        {
            const r = try h.radio("Millions", "depth");
            defer r.close();
        }
    }
    {
        const fs = try h.fieldset("Mouse");
        defer fs.close();
        {
            const r = try h.radio("Slow", "speed");
            defer r.close();
        }
        {
            const r = try h.radio("Fast", "speed");
            defer r.close();
        }
        {
            const cb = try h.checkbox("Double-click to open");
            defer cb.close();
        }
    }
    try w.writeAll("</div></div>\n");

    // ── Notepad (middle-left) ──
    try w.writeAll("<div class=\"window app-window\" style=\"top:290px;left:24px;\"><div class=\"title-bar\"><span class=\"title\">Notepad</span></div><div class=\"separator\"></div><div class=\"window-pane\">");
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("Widgets.zig — Abstract Widget Toolkit");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("━━━━━━━━━━━━━━━━━━━━");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("Supports 11 CSS frameworks from a single Zig widget API:");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("• PicoCSS — Semantic classes");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("• DaisyUI — Tailwind components");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("• JellyUI — Web Components");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("• SNES/NES — Retro gaming");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("• 98.css / System 6 — Classic OS");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("• Orbit — Radial dashboards");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("• TuiCss — Terminal UI");
    }
    try w.writeAll("</div></div>\n");

    // ── Calculator (middle-right) ──
    try w.writeAll("<div class=\"window app-window\" style=\"top:290px;right:24px;width:240px;\"><div class=\"title-bar\"><span class=\"title\">Calculator</span></div><div class=\"separator\"></div><div class=\"window-pane\">");
    {
        const p = try h.html.el("p", .{ .class = "field-row" });
        defer p.close();
    }
    try w.writeAll("<div class=\"field-row\"><input type=\"text\" value=\"0\" style=\"text-align:right;font-size:18px;width:180px;\"></div>\n");
    for ([_][]const u8{ "C  ±  %  ÷", "7  8  9  ×", "4  5  6  −", "1  2  3  +", "0  .  =" }) |row_txt| {
        try w.print("<div class=\"field-row\">", .{});
        var it = std.mem.splitScalar(u8, row_txt, ' ');
        while (it.next()) |tkn| {
            if (tkn.len > 0) {
                const b = try h.button(tkn);
                defer b.close();
            }
        }
        try w.writeAll("</div>\n");
    }
    try w.writeAll("</div></div>\n");

    // ── Installer (bottom-right) ──
    try w.writeAll("<div class=\"window app-window\" style=\"bottom:24px;right:24px;width:280px;\"><div class=\"title-bar\"><span class=\"title\">Installer</span></div><div class=\"separator\"></div><div class=\"window-pane\">");
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
        try h.html.text("65% complete — 17 of 26 files");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("Currently: src/root.zig");
    }
    {
        const b = try h.button("Stop");
        defer b.close();
    }
    try w.writeAll("</div></div>\n");

    // ── Trash (bottom-left) ──
    try w.writeAll("<div class=\"window app-window\" style=\"bottom:24px;left:24px;width:200px;\"><div class=\"title-bar\"><span class=\"title\">Trash</span></div><div class=\"separator\"></div><div class=\"window-pane\">");
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("🗑️ Empty Trash");
    }
    {
        const p = try h.html.el("p", .{});
        defer p.close();
        try h.html.text("3 items");
    }
    {
        const b = try h.button("Empty");
        defer b.close();
    }
    try w.writeAll("</div></div>\n");

    // ── Shut Down dialog ──
    {
        const d = try h.dialog("Are you sure you want to shut down your computer now?");
        defer d.close();
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created macintosh.html ({d} bytes)", .{fw.pos});
}
