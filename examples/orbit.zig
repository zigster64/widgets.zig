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

    // Nav
    {
        const nav = try h.html.el("nav", .{});
        defer nav.close();
        for ([_][2][]const u8{
            .{ "Home", "/" }, .{ "Pico", "pico.html" }, .{ "Daisy", "daisy.html" },
            .{ "Jelly", "jelly.html" }, .{ "Snes", "snes.html" },
            .{ "NES", "nes.html" }, .{ "Win98", "win98.html" },
            .{ "Macintosh", "macintosh.html" }, .{ "Orbit", "orbit.html" },
        }) |link| {
            const a = try h.html.el("a", .{ .href = link[1] });
            defer a.close();
            try h.html.text(link[0]);
        }
    }

    // ── Dashboard row ──
    {
        const row = try h.html.el("div", .{ .class = "display:flex;gap:24px" });
        defer row.close();

        // Gauge 1: Progress ring
        {
            const bb = try h.bigbang("theme-cyan");
            defer bb.close();
            const gs = try h.gravitySpot();
            defer gs.close();
            {
                const o = try h.orbit(2, 270);
                defer o.close();
                const p = try h.progress(72);
                defer p.close();
            }
            {
                const o = try h.orbit(3, 270);
                defer o.close();
                const p = try h.progress(45);
                defer p.close();
            }
            {
                const s = try h.satellite();
                defer s.close();
                const cp = try h.capsule();
                defer cp.close();
                try h.html.text("CPU");
            }
        }

        // Gauge 2: Full circle
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
                try h.html.text("RAM");
            }
        }

        // Gauge 3: Arc with arrow shape
        {
            const bb = try h.bigbang("theme-cyan");
            defer bb.close();
            const gs = try h.gravitySpot();
            defer gs.close();
            {
                const o = try h.orbit(3, 180);
                defer o.close();
                const a = try h.arc(55, "arrow");
                defer a.close();
            }
            {
                const s = try h.satellite();
                defer s.close();
                const cp = try h.capsule();
                defer cp.close();
                try h.html.text("Speed");
            }
        }
    }

    // ── Large single gauge ──
    {
        const section = try h.html.el("div", .{ .class = "margin-top:24px;display:flex;justify-content:center" });
        defer section.close();
        {
            const bb = try h.bigbang("theme-cyan");
            defer bb.close();
            const gs = try h.gravitySpot();
            defer gs.close();
            {
                const o = try h.orbit(4, 270);
                defer o.close();
                const p = try h.progress(82);
                defer p.close();
            }
            {
                const o = try h.orbit(5, 270);
                defer o.close();
                const a = try h.arc(35, null);
                defer a.close();
            }
            {
                const s = try h.satellite();
                defer s.close();
                const cp = try h.capsule();
                defer cp.close();
                try h.html.text("Orbit CSS");
            }
        }
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created orbit.html ({d} bytes)", .{fw.pos});
}
