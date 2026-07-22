const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");
const Ns = widgets_zig;

pub fn nesPage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/nes.html", .{});
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
        \\<link rel="stylesheet" href="https://unpkg.com/nes.css@2.3.0/css/nes.min.css">
        \\<title>NES.css Demo</title>
        \\</head>
        \\<body style="padding:24px;max-width:800px;margin:0 auto">
        \\
    );

    const h = Ns.NesCSS(w);

    // Nav
    {
        const nav = try h.html.el("nav", .{});
        defer nav.close();
        for ([_][2][]const u8{
            .{ "Home", "/" },
            .{ "Generated", "generated.html" },
            .{ "Pico", "pico.html" },
            .{ "Jelly", "jelly.html" },
            .{ "Snes", "snes.html" },
            .{ "Daisy", "daisy.html" },
            .{ "NES", "nes.html" },
            .{ "Win98", "win98.html" },
        }) |link| {
            const a = try h.html.el("a", .{ .href = link[1] });
            defer a.close();
            const b = try h.button(link[0], null);
            defer b.close();
        }
    }

    // Containers
    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("Buttons");
            defer t.close();
        }
        for ([_]Ns.NesVariant{ .primary, .success, .warning, .err }) |v| {
            const b = try h.button(@tagName(v), v);
            defer b.close();
        }
        {
            const b = try h.button("Pattern", .pattern);
            defer b.close();
        }
    }

    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("Badges");
            defer t.close();
        }
        for ([_]Ns.NesVariant{ .primary, .success, .warning, .err }) |v| {
            const b = try h.badge(@tagName(v), v);
            defer b.close();
        }
    }

    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("Progress");
            defer t.close();
        }
        {
            const p = try h.progress(70, .primary);
            defer p.close();
        }
        {
            const p = try h.progress(40, .success);
            defer p.close();
        }
    }

    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("Inputs");
            defer t.close();
        }
        try h.input("text", "Name");
        try h.input("email", "Email");
        {
            const ta = try h.textarea("Message...");
            defer ta.close();
        }
        {
            const sel = try h.select();
            defer sel.close();
        }
        {
            const cb = try h.checkbox("Remember me");
            defer cb.close();
        }
        {
            const r1 = try h.radio("Yes", "choice");
            defer r1.close();
        }
        {
            const r2 = try h.radio("No", "choice");
            defer r2.close();
        }
    }

    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("List & Table");
            defer t.close();
        }
        {
            const ul = try h.list();
            defer ul.close();
            for ([_][]const u8{ "Mario", "Luigi", "Peach" }) |name| {
                const li = try h.html.el("li", .{});
                defer li.close();
                try h.html.text(name);
            }
        }
        {
            const tbl = try h.table();
            defer tbl.close();
            const tr = try h.html.el("tr", .{});
            defer tr.close();
            for ([_][]const u8{ "1-1", "1-2", "1-3" }) |lvl| {
                const td = try h.html.el("td", .{});
                defer td.close();
                try h.html.text(lvl);
            }
        }
    }

    {
        const b = try h.balloon("Thank you Mario! But our princess is in another castle.");
        defer b.close();
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created nes.html ({d} bytes)", .{fw.pos});
}
