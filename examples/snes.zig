const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");
const Sn = widgets_zig;

pub fn snesPage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/snes.html", .{});
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
        \\<link rel="stylesheet" href="https://unpkg.com/snes.css@1.0.1/dist/snes.min.css">
        \\<title>SNES.css Demo</title>
        \\</head>
        \\<body style="padding:24px;max-width:900px;margin:0 auto;font-family:system-ui">
        \\
    );

    const h = Sn.SnesCSS(w);

    // Nav
    {
        const n = try h.html.el("nav", .{});
        defer n.close();
        for ([_][2][]const u8{
            .{ "Home", "/" },
            .{ "Generated", "generated.html" },
            .{ "Pico", "pico.html" },
            .{ "Jelly", "jelly.html" },
            .{ "Snes", "snes.html" },
            .{ "Daisy", "daisy.html" },
            .{ "NES", "nes.html" },
            .{ "Atari", "atari.html" },
            .{ "Win98", "win98.html" },
            .{ "Macintosh", "macintosh.html" },
            .{ "Orbit", "orbit.html" },
        }) |link| {
            const a = try h.html.el("a", .{ .href = link[1] });
            defer a.close();
            const b = try h.button(link[0], null);
            defer b.close();
        }
    }

    // Hero
    {
        const h1 = try h.html.h1("SNES.css Widgets Demo", .{});
        defer h1.close();
    }

    // ── Container: Texts ──
    {
        const ctr = try h.container(.@"soft-green");
        defer ctr.close();
        {
            const t = try h.containerTitle("Text Colors", .nature);
            defer t.close();
        }
        for ([_]Sn.SnesColor{ .nature, .plumber, .sunshine, .ocean, .turquoise, .phantom, .rose, .galaxy, .ember }) |c| {
            const p = try h.text(@tagName(c), c);
            defer p.close();
        }
    }

    // ── Container: Links ──
    {
        const ctr = try h.container(.@"soft-blue");
        defer ctr.close();
        {
            const t = try h.containerTitle("Links", .ocean);
            defer t.close();
        }
        for ([_][]const u8{ "New Game", "Continue", "Load", "Gallery", "Exit" }) |txt| {
            const a = try h.link(txt, null);
            defer a.close();
        }
    }

    // ── Container: Buttons ──
    {
        const ctr = try h.container(.@"aged-yellow");
        defer ctr.close();
        {
            const t = try h.containerTitle("Buttons", .ember);
            defer t.close();
        }
        for ([_]Sn.SnesColor{ .nature, .plumber, .sunshine, .ocean, .turquoise, .phantom, .rose, .galaxy, .ember }) |c| {
            const b = try h.button(@tagName(c), c);
            defer b.close();
        }
    }

    // ── Container: Lists ──
    {
        const ctr = try h.container(.@"soft-pink");
        defer ctr.close();
        {
            const t = try h.containerTitle("Lists", .rose);
            defer t.close();
        }
        {
            const ul = try h.list(.plumber);
            defer ul.close();
            for ([_][]const u8{ "Sorry, Mario", "But the Princess", "Is in another castle" }) |txt| {
                const li = try h.html.el("li", .{});
                defer li.close();
                try h.html.text(txt);
            }
        }
        {
            const ul = try h.list(.nature);
            defer ul.close();
            for ([_][]const u8{ "Ma'am, you're mistaken.", "I'm not a pet.", "I'm a Knight.", "And master swordsman." }) |txt| {
                const li = try h.html.el("li", .{});
                defer li.close();
                try h.html.text(txt);
            }
        }
    }

    // ── Container: Inputs ──
    {
        const ctr = try h.container(.@"soft-brown");
        defer ctr.close();
        {
            const t = try h.containerTitle("Inputs", .sunshine);
            defer t.close();
        }
        try h.input("text");
        try h.input("email");
        try h.input("password");
        {
            const ta = try h.textarea();
            defer ta.close();
        }
    }

    // ── Container: Progress ──
    {
        const ctr = try h.container(.@"soft-purple");
        defer ctr.close();
        {
            const t = try h.containerTitle("Progress", .phantom);
            defer t.close();
        }
        {
            const pg = try h.progress(65, 100);
            defer pg.close();
        }
        {
            const pg = try h.progress(30, 100);
            defer pg.close();
        }
    }

    // ── Container: Table ──
    {
        const ctr = try h.container(.@"soft-grey");
        defer ctr.close();
        {
            const t = try h.containerTitle("Table", .galaxy);
            defer t.close();
        }
        {
            const tbl = try h.table();
            defer tbl.close();
            {
                const thead = try h.html.el("thead", .{});
                defer thead.close();
                const tr = try h.html.el("tr", .{});
                defer tr.close();
                for ([_][]const u8{ "Character", "Game", "Year" }) |hdr| {
                    const th = try h.html.el("th", .{});
                    defer th.close();
                    try h.html.text(hdr);
                }
            }
            {
                const tbody = try h.html.el("tbody", .{});
                defer tbody.close();
                const rows = [_][3][]const u8{
                    .{ "Mario", "Super Mario World", "1990" },
                    .{ "Link", "A Link to the Past", "1991" },
                    .{ "Samus", "Super Metroid", "1994" },
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
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created snes.html ({d} bytes)", .{fw.pos});
}
