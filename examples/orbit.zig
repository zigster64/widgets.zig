const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");
const Or = widgets_zig;

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
        \\</head>
        \\<body style="background:#0a0a1a;color:#fff;padding:24px">
        \\
    );

    const h = Or.OrbitCSS(w);

    // Nav (plain HTML since orbit is radial)
    {
        const nav = try h.html.el("nav", .{});
        defer nav.close();
        for ([_][2][]const u8{
            .{ "Home", "/" }, .{ "Pico", "pico.html" }, .{ "Daisy", "daisy.html" },
            .{ "NES", "nes.html" }, .{ "Win98", "win98.html" }, .{ "Orbit", "orbit.html" },
        }) |link| {
            const a = try h.html.el("a", .{ .href = link[1] });
            defer a.close();
            try h.html.text(link[0]);
        }
    }

    // ── Gauges ──
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
            try h.html.text("Orbit CSS");
        }
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created orbit.html ({d} bytes)", .{fw.pos});
}
