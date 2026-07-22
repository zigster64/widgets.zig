const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");

pub fn orbitPage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/orbit.html", .{});
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
        \\<link rel="stylesheet" href="https://unpkg.com/@zumer/orbit@latest/dist/orbit.css">
        \\<script src="https://unpkg.com/@zumer/orbit@latest/dist/orbit.js"></script>
        \\<title>Orbit Demo</title>
        \\<style>
        \\  body { background:#0a0a1a; color:#ccc; padding:24px; font-family:system-ui; margin:0; }
        \\  h1 { font-size:28px; margin-bottom:24px; color:#fff; }
        \\  .dashboard { display:flex; gap:24px; flex-wrap:wrap; }
        \\  .gauge { width:200px; height:200px; }
        \\  .gauge.big { width:280px; height:280px; }
        \\  .gauge-label { text-align:center; margin-top:8px; font-size:13px; text-transform:uppercase; letter-spacing:1px; }
        \\  nav { margin-bottom:24px; display:flex; gap:12px; flex-wrap:wrap; }
        \\  nav a { color:#6cf; text-decoration:none; padding:4px 10px; border-radius:4px; }
        \\  nav a:hover { background:#1a1a3a; }
        \\</style>
        \\</head>
        \\<body>
        \\
    );

    // Nav
    try w.writeAll("<nav>");
    for ([_][2][]const u8{
        .{ "Home", "/" }, .{ "Pico", "pico.html" }, .{ "Daisy", "daisy.html" },
        .{ "Jelly", "jelly.html" }, .{ "Snes", "snes.html" },
        .{ "NES", "nes.html" },
            .{ "Atari", "atari.html" },
            .{ "Handdrawn", "handdrawn.html" },
            .{ "Doodle", "doodle.html" }, .{ "Win98", "win98.html" },
        .{ "Macintosh", "macintosh.html" }, .{ "Orbit", "orbit.html" },
    }) |link| {
        try w.print("<a href=\"{s}\">{s}</a>", .{ link[1], link[0] });
    }
    try w.writeAll("</nav>\n");

    try w.writeAll("<h1>Orbit Radial Dashboard</h1>\n");
    try w.writeAll("<div class=\"dashboard\">\n");

    const h = widgets_zig.OrbitCSS(w);

    // Gauge: CPU
    try w.writeAll("<div><div class=\"gauge\">");
    {
        const bb = try h.bigbang("theme-cyan");
        defer bb.close();
        const gs = try h.gravitySpot();
        defer gs.close();
        {
            const o = try h.orbit(1, 270);
            defer o.close();
            const p = try h.progress(72);
            defer p.close();
        }
        {
            const o = try h.orbit(2, 270);
            defer o.close();
            const p = try h.progress(45);
            defer p.close();
        }
        {
            const s = try h.satellite();
            defer s.close();
            const cp = try h.capsule();
            defer cp.close();
            try h.html.text("CPU 72%");
        }
    }
    try w.writeAll("</div><div class=\"gauge-label\">CPU Usage</div></div>\n");

    // Gauge: RAM
    try w.writeAll("<div><div class=\"gauge\">");
    {
        const bb = try h.bigbang("theme-cyan");
        defer bb.close();
        const gs = try h.gravitySpot();
        defer gs.close();
        {
            const o = try h.orbit(1, 360);
            defer o.close();
            const p = try h.progress(88);
            defer p.close();
        }
        {
            const o = try h.orbit(2, 360);
            defer o.close();
            const p = try h.progress(60);
            defer p.close();
        }
        {
            const s = try h.satellite();
            defer s.close();
            const cp = try h.capsule();
            defer cp.close();
            try h.html.text("RAM 88%");
        }
    }
    try w.writeAll("</div><div class=\"gauge-label\">Memory</div></div>\n");

    // Gauge: Disk
    try w.writeAll("<div><div class=\"gauge\">");
    {
        const bb = try h.bigbang("theme-cyan");
        defer bb.close();
        const gs = try h.gravitySpot();
        defer gs.close();
        {
            const o = try h.orbit(2, 180);
            defer o.close();
            const a = try h.arc(55, "arrow");
            defer a.close();
        }
        {
            const s = try h.satellite();
            defer s.close();
            const cp = try h.capsule();
            defer cp.close();
            try h.html.text("Disk 55%");
        }
    }
    try w.writeAll("</div><div class=\"gauge-label\">Disk Space</div></div>\n");

    // Gauge: Network (larger)
    try w.writeAll("<div><div class=\"gauge big\">");
    {
        const bb = try h.bigbang("theme-cyan");
        defer bb.close();
        const gs = try h.gravitySpot();
        defer gs.close();
        {
            const o = try h.orbit(2, 240);
            defer o.close();
            const p = try h.progress(35);
            defer p.close();
        }
        {
            const o = try h.orbit(3, 240);
            defer o.close();
            const a = try h.arc(65, null);
            defer a.close();
        }
        {
            const s = try h.satellite();
            defer s.close();
            const cp = try h.capsule();
            defer cp.close();
            try h.html.text("Network");
        }
    }
    try w.writeAll("</div><div class=\"gauge-label\">Network I/O</div></div>\n");

    try w.writeAll("</div>\n"); // close dashboard

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created orbit.html ({d} bytes)", .{fw.pos});
}
