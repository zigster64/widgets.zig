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
        \\<body style="padding:24px;max-width:900px;margin:0 auto">
        \\
    );

    const h = Ns.NesCSS(w);

    // Nav
    {
        const nav = try h.html.el("nav", .{});
        defer nav.close();
        for ([_][2][]const u8{
            .{ "Home", "/" }, .{ "Generated", "generated.html" }, .{ "Pico", "pico.html" },
            .{ "Jelly", "jelly.html" }, .{ "Snes", "snes.html" }, .{ "Daisy", "daisy.html" },
            .{ "NES", "nes.html" }, .{ "Win98", "win98.html" },
            .{ "Macintosh", "system.html" }, .{ "Orbit", "orbit.html" },
        }) |link| {
            const a = try h.html.el("a", .{ .href = link[1] });
            defer a.close();
            const b = try h.button(link[0], null);
            defer b.close();
        }
    }

    // Hero
    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("NES.css Widgets Demo");
            defer t.close();
        }
        {
            const p = try h.html.el("p", .{});
            defer p.close();
            try h.html.text("An 8-bit retro CSS framework inspired by the Nintendo Entertainment System.");
        }
    }

    // Buttons
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
        {
            const b = try h.button("Default", null);
            defer b.close();
        }
    }

    // Balloon
    {
        const b = try h.balloon("Thank you Mario! But our princess is in another castle.");
        defer b.close();
    }

    // Two-column: Badges + Progress
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
        {
            const p = try h.progress(90, .err);
            defer p.close();
        }
    }

    // Form section
    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("Sign Up");
            defer t.close();
        }
        {
            const p = try h.html.el("label", .{});
            defer p.close();
            try h.html.text("Name");
        }
        try h.input("text", "Mario");
        {
            const p = try h.html.el("label", .{});
            defer p.close();
            try h.html.text("Email");
        }
        try h.input("email", "mario@mushroomkingdom.com");
        {
            const p = try h.html.el("label", .{});
            defer p.close();
            try h.html.text("Bio");
        }
        {
            const ta = try h.textarea("It's-a me...");
            defer ta.close();
        }
        {
            const sel = try h.select();
            defer sel.close();
            for ([_][]const u8{ "Mushroom Kingdom", "Sarasaland", "Yoshi's Island" }) |opt| {
                const o = try h.html.el("option", .{ .value = opt });
                defer o.close();
                try h.html.text(opt);
            }
        }
        {
            const cb = try h.checkbox("Remember me");
            defer cb.close();
        }
        {
            const r1 = try h.radio("1 Player", "players");
            defer r1.close();
        }
        {
            const r2 = try h.radio("2 Player", "players");
            defer r2.close();
        }
        {
            const b = try h.button("Start Game", .primary);
            defer b.close();
        }
    }

    // Table + List
    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("High Scores");
            defer t.close();
        }
        {
            const tbl = try h.table();
            defer tbl.close();
            const thead = try h.html.el("thead", .{});
            defer thead.close();
            {
                const tr = try h.html.el("tr", .{});
                defer tr.close();
                for ([_][]const u8{ "Rank", "Player", "Score" }) |hdr| {
                    const th = try h.html.el("th", .{});
                    defer th.close();
                    try h.html.text(hdr);
                }
            }
            const tbody = try h.html.el("tbody", .{});
            defer tbody.close();
            const rows = [_][3][]const u8{
                .{ "1st", "Mario", "9999990" },
                .{ "2nd", "Luigi", "8887750" },
                .{ "3rd", "Toad", "7776540" },
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

    {
        const ctr = try h.container();
        defer ctr.close();
        {
            const t = try h.containerTitle("Power-ups");
            defer t.close();
        }
        {
            const ul = try h.list();
            defer ul.close();
            for ([_][]const u8{ "Super Mushroom", "Fire Flower", "Super Star", "1-Up Mushroom" }) |item| {
                const li = try h.html.el("li", .{});
                defer li.close();
                try h.html.text(item);
            }
        }
    }

    // Closing balloon
    {
        const b = try h.balloon("Press Start to continue...");
        defer b.close();
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created nes.html ({d} bytes)", .{fw.pos});
}
