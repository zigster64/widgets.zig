const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");

pub fn handdrawnPage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/handdrawn.html", .{});
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
        \\<link rel="stylesheet" href="https://fxaeberhard.github.io/handdrawn.css/handdrawn.css">
        \\<title>Handdrawn Demo</title>
        \\</head>
        \\<body style="padding:24px;max-width:800px;margin:0 auto">
        \\
    );

    const h = widgets_zig.HanddrawnCSS(w);

    // Nav
    {
        const nav = try h.el("nav", .{});
        defer nav.close();
        for ([_][2][]const u8{
            .{ "Home", "/" }, .{ "Pico", "pico.html" }, .{ "Daisy", "daisy.html" },
            .{ "Jelly", "jelly.html" }, .{ "Snes", "snes.html" }, .{ "NES", "nes.html" },
            .{ "Atari", "atari.html" }, .{ "Win98", "win98.html" },
            .{ "Macintosh", "macintosh.html" }, .{ "Orbit", "orbit.html" },
            .{ "TUI", "tui.html" }, .{ "Handdrawn", "handdrawn.html" },
            .{ "Doodle", "doodle.html" },
        }) |link| {
            const a = try h.el("a", .{ .href = link[1] });
            defer a.close();
            try h.text(link[0]);
        }
    }

    // Hero
    {
        const h1 = try h.h1("Handdrawn.css Widgets Demo", .{});
        defer h1.close();
    }
    {
        const p = try h.el("p", .{});
        defer p.close();
        try h.text("Every element gets a hand-drawn sketch border. No special classes needed — just semantic HTML.");
    }

    // Buttons
    {
        const h2 = try h.el("h2", .{});
        defer h2.close();
        try h.text("Buttons");
    }
    for ([_][]const u8{ "Primary", "Success", "Warning", "Danger", "Info" }) |txt| {
        const b = try h.el("button", .{});
        defer b.close();
        try h.text(txt);
    }

    // Form
    {
        const h2 = try h.el("h2", .{});
        defer h2.close();
        try h.text("Sign Up");
    }
    {
        const fs = try h.el("fieldset", .{});
        defer fs.close();
        const l = try h.el("legend", .{});
        defer l.close();
        try h.text("Create your account");

        const label1 = try h.el("label", .{});
        defer label1.close();
        try h.text("Username");
        try h.elVoid("input", .{ .@"type" = "text", .placeholder = "username" });

        const label2 = try h.el("label", .{});
        defer label2.close();
        try h.text("Password");
        try h.elVoid("input", .{ .@"type" = "password", .placeholder = "••••••••" });

        const label3 = try h.el("label", .{});
        defer label3.close();
        try h.text("Country");
        {
            const sel = try h.el("select", .{});
            defer sel.close();
            for ([_][]const u8{ "🇦🇺 Australia", "🇨🇦 Canada", "🇬🇧 UK", "🇺🇸 USA" }) |opt| {
                const o = try h.el("option", .{});
                defer o.close();
                try h.text(opt);
            }
        }

        {
            const cont = try h.el("div", .{});
            defer cont.close();
            const box = try h.el("label", .{ .class = "checkbox" });
            defer box.close();
            try h.elVoid("input", .{ .@"type" = "checkbox" });
            try h.text("Accept terms");

            const rad1 = try h.el("label", .{});
            defer rad1.close();
            try h.elVoid("input", .{ .@"type" = "radio", .name = "plan", .value = "free" });
            try h.text("Free");

            const rad2 = try h.el("label", .{});
            defer rad2.close();
            try h.elVoid("input", .{ .@"type" = "radio", .name = "plan", .value = "pro" });
            try h.text("Pro");
        }

        {
            const b = try h.el("button", .{});
            defer b.close();
            try h.text("Sign Up");
        }
        {
            const b = try h.el("button", .{});
            defer b.close();
            try h.text("Cancel");
        }
    }

    // Table
    {
        const h2 = try h.el("h2", .{});
        defer h2.close();
        try h.text("Table");
    }
    {
        const tbl = try h.el("table", .{ .class = "lined" });
        defer tbl.close();
        const thead = try h.el("thead", .{});
        defer thead.close();
        {
            const tr = try h.el("tr", .{});
            defer tr.close();
            for ([_][]const u8{ "Render", "Framework", "Lines" }) |hdr| {
                const th = try h.el("th", .{});
                defer th.close();
                try h.text(hdr);
            }
        }
        const tbody = try h.el("tbody", .{});
        defer tbody.close();
        const rows = [_][3][]const u8{
            .{ "🖌️", "Handdrawn", "0" },
            .{ "🎨", "PicoCSS", "~100" },
            .{ "⚡", "DaisyUI", "~300" },
        };
        for (&rows) |row| {
            const tr = try h.el("tr", .{});
            defer tr.close();
            for (&row) |cell| {
                const td = try h.el("td", .{});
                defer td.close();
                try h.text(cell);
            }
        }
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created handdrawn.html ({d} bytes)", .{fw.pos});
}
