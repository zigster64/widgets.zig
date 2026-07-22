const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");
const Du = widgets_zig;

pub fn daisyPage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/daisy.html", .{});
    defer file.close(io);

    var buf: [16384]u8 = undefined;
    var fw = Io.File.Writer.init(file, io, &buf);
    const w = &fw.interface;

    try w.writeAll(
        \\<!DOCTYPE html>
        \\<html lang="en" data-theme="light">
        \\<head>
        \\<meta charset="utf-8">
        \\<meta name="viewport" content="width=device-width, initial-scale=1">
        \\<link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
        \\<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
        \\<title>DaisyUI Demo</title>
        \\</head>
        \\<body class="p-6 max-w-4xl mx-auto">
        \\
    );

    const h = Du.DaisyUI(w);

    // Nav
    {
        const nb = try h.navbar();
        defer nb.close();
        {
            const div = try h.html.el("div", .{ .class = "flex-1" });
            defer div.close();
            const a = try h.html.el("a", .{ .class = "btn btn-ghost text-xl" });
            defer a.close();
            try h.html.text("DaisyUI Demo");
        }
        {
            const div = try h.html.el("div", .{ .class = "flex-none" });
            defer div.close();
            for ([_][2][]const u8{
                .{ "Home", "/" },
                .{ "Generated", "generated.html" },
                .{ "Pico", "pico.html" },
                .{ "Jelly", "jelly.html" },
                .{ "Snes", "snes.html" },
                .{ "Daisy", "daisy.html" },
            .{ "NES", "nes.html" },
            .{ "Win98", "win98.html" },
            .{ "Macintosh", "macintosh.html" },
            .{ "Orbit", "orbit.html" },
            }) |link| {
                const a = try h.html.el("a", .{ .class = "btn btn-ghost btn-sm", .href = link[1] });
                defer a.close();
                try h.html.text(link[0]);
            }
        }
    }

    // ── Hero ──
    {
        const hero = try h.hero();
        defer hero.close();
        {
            const div = try h.html.el("div", .{ .class = "hero-content text-center" });
            defer div.close();
            {
                const h1 = try h.html.h1("DaisyUI Widgets Demo", .{ .class = "text-5xl font-bold" });
                defer h1.close();
            }
            {
                const p = try h.html.el("p", .{ .class = "py-6" });
                defer p.close();
                try h.html.text("Tailwind CSS components with semantic classes. Every component below uses DaisyUI's class-based API.");
            }
        }
    }

    // ── Buttons ──
    {
        const d = try h.divider("Buttons", .primary);
        defer d.close();
    }
    {
        const j = try h.join();
        defer j.close();
        for ([_]Du.DuBtnVariant{ .primary, .secondary, .accent, .neutral, .ghost, .link, .outline, .dash, .soft }) |v| {
            const b = try h.button(@tagName(v), v, .md);
            defer b.close();
        }
    }

    // ── Badges ──
    {
        const d = try h.divider("Badges", .secondary);
        defer d.close();
    }
    for ([_]Du.DuColor{ .primary, .secondary, .accent, .info, .success, .warning, .err }) |c| {
        const b = try h.badge(@tagName(c), c, .lg);
        defer b.close();
    }

    // ── Alerts ──
    {
        const d = try h.divider("Alerts", .info);
        defer d.close();
    }
    for ([_]Du.DuColor{ .info, .success, .warning, .err }) |c| {
        const a = try h.alert(c);
        defer a.close();
        const span = try h.html.el("span", .{});
        defer span.close();
        const txt = switch (c) {
            .info => "New update available!",
            .success => "Purchase completed successfully.",
            .warning => "Your storage is almost full.",
            .err => "Something went wrong.",
            else => "",
        };
        try h.html.text(txt);
    }

    // ── Stats ──
    {
        const d = try h.divider("Stats", .success);
        defer d.close();
    }
    {
        const st = try h.stats();
        defer st.close();
        {
            const s = try h.stat("Downloads", "2.4M", "↑ 14% in the last month");
            defer s.close();
        }
        {
            const s = try h.stat("Users", "84K", "↑ 7% vs last quarter");
            defer s.close();
        }
        {
            const s = try h.stat("Uptime", "99.9%", "↗︎ 0.1% improvement");
            defer s.close();
        }
    }

    // ── Avatar ──
    {
        const a = try h.avatar("https://placehold.co/48x48", .md);
        defer a.close();
    }

    // ── Cards ──
    {
        const d = try h.divider("Cards", .accent);
        defer d.close();
    }
    {
        const div = try h.html.el("div", .{ .class = "grid grid-cols-3 gap-4" });
        defer div.close();
        for ([_][]const u8{ "Card One", "Card Two", "Card Three" }) |title| {
            const c = try h.card();
            defer c.close();
            const body = try h.cardBody();
            defer body.close();
            {
                const ct = try h.cardTitle(title);
                defer ct.close();
            }
            {
                const p = try h.html.el("p", .{});
                defer p.close();
                try h.html.text("DaisyUI cards work with Tailwind classes for responsive layouts.");
            }
            {
                const b = try h.button("Read more", .primary, .sm);
                defer b.close();
            }
        }
    }

    // ── Form ──
    {
        const d = try h.divider("Form", .primary);
        defer d.close();
    }
    {
        const form = try h.html.el("form", .{ .class = "flex flex-col gap-4 max-w-md" });
        defer form.close();
        try h.input("text", "Username");
        try h.input("email", "Email");
        try h.input("password", "Password");
        {
            const sel = try h.select();
            defer sel.close();
        }
        {
            const ta = try h.textarea("Your message...");
            defer ta.close();
        }
        {
            const div = try h.html.el("div", .{ .class = "flex gap-2 items-center" });
            defer div.close();
            try h.checkbox(.primary);
            {
                const sp = try h.html.el("span", .{ .class = "text-sm" });
                defer sp.close();
                try h.html.text("I agree to the terms");
            }
            {
                const rd = try h.html.el("div", .{ .class = "flex gap-4 items-center" });
                defer rd.close();
                try h.radio(.secondary);
                {
                    const sp = try h.html.el("span", .{ .class = "text-sm" });
                    defer sp.close();
                    try h.html.text("Option A");
                }
                try h.radio(.accent);
                {
                    const sp = try h.html.el("span", .{ .class = "text-sm" });
                    defer sp.close();
                    try h.html.text("Option B");
                }
            }
        }
        {
            const div = try h.html.el("div", .{ .class = "flex gap-2 items-center" });
            defer div.close();
            try h.toggle(.primary);
            {
                const sp = try h.html.el("span", .{ .class = "text-sm" });
                defer sp.close();
                try h.html.text("Enable notifications");
            }
        }
        try h.range(.accent);
        {
            const div = try h.html.el("div", .{ .class = "flex gap-2" });
            defer div.close();
            const b = try h.button("Submit", .primary, .md);
            defer b.close();
            const b2 = try h.button("Cancel", .ghost, .md);
            defer b2.close();
        }
    }

    // ── Progress ──
    {
        const d = try h.divider("Progress", .warning);
        defer d.close();
    }
    {
        const pg = try h.progress(72, .primary);
        defer pg.close();
    }
    {
        const pg = try h.progress(45, .success);
        defer pg.close();
    }

    // ── Loading ──
    {
        const d = try h.divider("Loading", .info);
        defer d.close();
    }
    {
        const l = try h.loading(.lg, .primary);
        defer l.close();
    }
    {
        const l = try h.loading(.md, .accent);
        defer l.close();
    }

    // ── Steps ──
    {
        const d = try h.divider("Steps", .secondary);
        defer d.close();
    }
    {
        const st = try h.steps();
        defer st.close();
        {
            const s = try h.step("Register", true);
            defer s.close();
        }
        {
            const s = try h.step("Verify", true);
            defer s.close();
        }
        {
            const s = try h.step("Complete", false);
            defer s.close();
        }
    }

    // ── Tabs ──
    {
        const d = try h.divider("Tabs", .primary);
        defer d.close();
    }
    {
        const tbs = try h.tabs();
        defer tbs.close();
        {
            const t = try h.tab("Overview", true);
            defer t.close();
        }
        {
            const t = try h.tab("Billing", false);
            defer t.close();
        }
        {
            const t = try h.tab("Settings", false);
            defer t.close();
        }
    }

    // ── Collapse ──
    {
        const d = try h.divider("Collapse", .neutral);
        defer d.close();
    }
    {
        const cl = try h.collapse("Click to expand", "This content is hidden by default.");
        defer cl.close();
    }

    // ── Breadcrumbs / Tooltip / Skeleton ──
    {
        const d = try h.divider("More Components", .primary);
        defer d.close();
    }
    {
        const bc = try h.breadcrumbs();
        defer bc.close();
        {
            const ul = try h.html.el("ul", .{});
            defer ul.close();
            for ([_][]const u8{ "Home", "Docs", "Components" }) |txt| {
                const li = try h.html.el("li", .{});
                defer li.close();
                const a = try h.html.el("a", .{ .href = "#" });
                defer a.close();
                try h.html.text(txt);
            }
        }
    }
    {
        const tt = try h.tooltip("This is a tooltip");
        defer tt.close();
        const b = try h.button("Hover me", .primary, .sm);
        defer b.close();
    }
    {
        const sk = try h.skeleton();
        defer sk.close();
    }
    // Menu
    {
        const m = try h.menu();
        defer m.close();
        for ([_][]const u8{ "Dashboard", "Settings", "Logout" }) |item| {
            const li = try h.html.el("li", .{});
            defer li.close();
            const a = try h.html.el("a", .{ .href = "#" });
            defer a.close();
            try h.html.text(item);
        }
    }
    // Stack
    {
        const st = try h.stack();
        defer st.close();
        {
            const div = try h.html.el("div", .{ .class = "bg-primary text-primary-content p-4 rounded" });
            defer div.close();
            try h.html.text("Top");
        }
        {
            const div = try h.html.el("div", .{ .class = "bg-secondary text-secondary-content p-4 rounded" });
            defer div.close();
            try h.html.text("Bottom");
        }
    }
    // Mockup Code
    {
        const mc = try h.mockupCode();
        defer mc.close();
        {
            const pre = try h.html.el("pre", .{});
            defer pre.close();
            const code = try h.html.el("code", .{});
            defer code.close();
            try h.html.text("const h = DaisyUI(w);");
        }
    }

    // ── Table ──
    {
        const d = try h.divider("Table", .accent);
        defer d.close();
    }
    {
        const tbl = try h.table();
        defer tbl.close();
        {
            const thead = try h.html.el("thead", .{});
            defer thead.close();
            const tr = try h.html.el("tr", .{});
            defer tr.close();
            for ([_][]const u8{ "Name", "Role", "Status" }) |hdr| {
                const th = try h.html.el("th", .{});
                defer th.close();
                try h.html.text(hdr);
            }
        }
        {
            const tbody = try h.html.el("tbody", .{});
            defer tbody.close();
            const rows = [_][3][]const u8{
                .{ "Zig", "Language", "Active" },
                .{ "DaisyUI", "UI Library", "Active" },
                .{ "Widgets", "Toolkit", "Building" },
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

    // ── Footer ──
    {
        const d = try h.divider("Footer", .neutral);
        defer d.close();
    }
    {
        const ft = try h.footer();
        defer ft.close();
        {
            const aside = try h.html.el("aside", .{});
            defer aside.close();
            const p = try h.html.el("p", .{});
            defer p.close();
            try h.html.text("Built with Widgets.zig + DaisyUI");
        }
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created daisy.html ({d} bytes)", .{fw.pos});
}
