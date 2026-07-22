const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");

pub fn indexHtml(io: Io) !void {
    const html =
        \\<!DOCTYPE html>
        \\<html lang="en">
        \\<head><meta charset="utf-8">
        \\<title>Widgets Demo</title>
        \\</head>
        \\<body><header id="top"><h1>Widgets Demo</h1>
        \\<nav class="menu"><a href="/">Home</a>
        \\<a href="generated.html">Generated</a>
        \\<a href="pico.html">Pico</a>
        \\<a href="jelly.html">Jelly</a>
        \\<a href="snes.html">Snes</a>
        \\<a href="daisy.html">Daisy</a>
        \\<a href="nes.html">NES</a>
        \\<a href="win98.html">Win98</a>
        \\<a href="system.html">System</a>
        \\<a href="orbit.html">Orbit</a>
        \\</nav>
        \\</header>
        \\<main><section class="content"><p>Welcome to the <span class="highlight">widgets</span>
        \\ demo.</p>
        \\<img src="https://placehold.co/600x400" alt="Placeholder">
        \\<br>
        \\<ul><li>Fast</li>
        \\<li>Safe</li>
        \\<li>Composable</li>
        \\</ul>
        \\</section>
        \\</main>
        \\<footer><p>Built with Widgets.zig</p>
        \\</footer>
        \\</body>
        \\</html>
        \\
    ;

    const dir = Dir.cwd();
    try Dir.createDirPath(dir, io, "docs");
    const file = try Dir.createFile(dir, io, "docs/index.html", .{});
    defer file.close(io);
    try file.writeStreamingAll(io, html);
    std.log.info("created index.html ({d} bytes)", .{html.len});
}

pub fn indexGen(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/generated.html", .{});
    defer file.close(io);

    var buf: [4096]u8 = undefined;
    var fw = Io.File.Writer.init(file, io, &buf);
    const h = widgets_zig.Html(&fw.interface);

    {
        const doc = try h.html(.{ .lang = "en" });
        defer doc.close();

        {
            const head = try h.head(.{});
            defer head.close();
            try h.meta(.{ .charset = "utf-8" });
            const t = try h.title("Widgets Demo", .{});
            defer t.close();
        }

        {
            const body = try h.body(.{});
            defer body.close();

            {
                const header = try h.el("header", .{ .id = "top" });
                defer header.close();
                {
                    const h1 = try h.h1("Widgets Demo", .{});
                    defer h1.close();
                }
                {
                    const nav = try h.el("nav", .{ .class = "menu" });
                    defer nav.close();
                    {
                        const a = try h.el("a", .{ .href = "/" });
                        defer a.close();
                        try h.text("Home");
                    }
                    {
                        const a = try h.el("a", .{ .href = "generated.html" });
                        defer a.close();
                        try h.text("Generated");
                    }
                    {
                        const a = try h.el("a", .{ .href = "pico.html" });
                        defer a.close();
                        try h.text("Pico");
                    }
                    {
                        const a = try h.el("a", .{ .href = "jelly.html" });
                        defer a.close();
                        try h.text("Jelly");
                    }
                    {
                        const a = try h.el("a", .{ .href = "snes.html" });
                        defer a.close();
                        try h.text("Snes");
                    }
                    {
                        const a = try h.el("a", .{ .href = "daisy.html" });
                        defer a.close();
                        try h.text("Daisy");
                    }
                    {
                        const a = try h.el("a", .{ .href = "nes.html" });
                        defer a.close();
                        try h.text("NES");
                    }
                    {
                        const a = try h.el("a", .{ .href = "win98.html" });
                        defer a.close();
                        try h.text("Win98");
                    }
                    {
                        const a = try h.el("a", .{ .href = "system.html" });
                        defer a.close();
                        try h.text("Macintosh");
                    }
                    {
                        const a = try h.el("a", .{ .href = "orbit.html" });
                        defer a.close();
                        try h.text("Orbit");
                    }
                }
            }

            {
                const m = try h.el("main", .{});
                defer m.close();
                {
                    const section = try h.el("section", .{ .class = "content" });
                    defer section.close();
                    {
                        const p = try h.el("p", .{});
                        defer p.close();
                        try h.text("Welcome to the ");
                        {
                            const span = try h.el("span", .{ .class = "highlight" });
                            defer span.close();
                            try h.text("widgets");
                        }
                        try h.text(" demo.");
                    }
                    try h.elVoid("img", .{ .src = "https://placehold.co/600x400", .alt = "Placeholder" });
                    try h.elVoid("br", .{});
                    {
                        const ul = try h.el("ul", .{});
                        defer ul.close();
                        {
                            const li = try h.el("li", .{});
                            defer li.close();
                            try h.text("Fast");
                        }
                        {
                            const li = try h.el("li", .{});
                            defer li.close();
                            try h.text("Safe");
                        }
                        {
                            const li = try h.el("li", .{});
                            defer li.close();
                            try h.text("Composable");
                        }
                    }
                }
            }

            {
                const footer = try h.el("footer", .{});
                defer footer.close();
                const p = try h.el("p", .{});
                defer p.close();
                try h.text("Built with Widgets.zig");
            }
        }
    }
    try fw.flush();
    std.log.info("created generated.html ({d} bytes)", .{fw.pos});
}
