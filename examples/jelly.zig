const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");
const Jl = widgets_zig;

pub fn jellyPage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/jelly.html", .{});
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
        \\<script type="module" src="https://jelly-ui.com/package.js"></script>
        \\<title>JellyUI Demo</title>
        \\</head>
        \\<body style="padding:24px;display:flex;flex-direction:column;gap:24px;max-width:800px;margin:0 auto;font-family:system-ui">
        \\
    );

    const h = Jl.JellyUI(w);

    {
        const th = try h.theme(.auto);
        defer th.close();

        // ── Nav bar ──
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
            }) |link| {
                const a = try h.html.el("a", .{ .href = link[1] });
                defer a.close();
                {
                    const b = try h.button(link[0], .mint, .small);
                    defer b.close();
                }
            }
        }

        // ── Hero ──
        {
            const h1 = try h.html.h1("JellyUI Widgets Demo", .{});
            defer h1.close();
        }
        {
            const c = try h.card();
            defer c.close();
            {
                const h3 = try h.html.el("h3", .{});
                defer h3.close();
                try h.html.text("Soft-body physics. Real form controls. Zero dependencies.");
            }
            {
                const p = try h.html.el("p", .{});
                defer p.close();
                try h.html.text("Every component below is a native custom element rendered on a canvas-backed surface with tactile wobble. Dark mode, RTL, and WCAG AA built in.");
            }
        }

        // ── Buttons ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Buttons");
        }
        for ([_]Jl.JellyVariant{ .azure, .rose, .amber, .mint, .graphite, .platinum, .white }) |v| {
            const b = try h.button(@tagName(v), v, .medium);
            defer b.close();
        }
        {
            const b = try h.button("Large Mint", .mint, .large);
            defer b.close();
        }
        {
            const b = try h.button("Small Rose", .rose, .small);
            defer b.close();
        }

        // ── Icon buttons ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Icon Buttons");
        }
        {
            const i = try h.iconButton("Copy", .azure, .medium);
            defer i.close();
        }
        {
            const i = try h.iconButton("Trash", .rose, .medium);
            defer i.close();
        }

        // ── Badges ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Badges");
        }
        {
            const b = try h.badge("New", .mint, .small);
            defer b.close();
        }
        {
            const b = try h.badge("Hot", .rose, .small);
            defer b.close();
        }
        {
            const b = try h.badge("Beta", .amber, .small);
            defer b.close();
        }

        // ── Signup Form ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Signup Form");
        }
        {
            const inp = try h.input("Username", "text", "Choose a username", .medium);
            defer inp.close();
        }
        {
            const inp = try h.input("Email", "email", "you@example.com", .medium);
            defer inp.close();
        }
        {
            const inp = try h.input("Password", "password", null, .medium);
            defer inp.close();
        }
        {
            const sel = try h.select("Country", .medium);
            defer sel.close();
            const countries = [_][2][]const u8{
                .{ "us", "United States" },
                .{ "ca", "Canada" },
                .{ "uk", "United Kingdom" },
                .{ "au", "Australia" },
            };
            for (&countries) |c| {
                const opt = try h.option(c[0], c[1]);
                defer opt.close();
            }
        }
        {
            const rg = try h.radioGroup("Account type");
            defer rg.close();
            {
                const r = try h.radio("free", "Free", .medium);
                defer r.close();
            }
            {
                const r = try h.radio("pro", "Pro — $9/mo", .medium);
                defer r.close();
            }
            {
                const r = try h.radio("enterprise", "Enterprise", .medium);
                defer r.close();
            }
        }
        {
            const cb = try h.checkbox("I agree to the Terms of Service", .medium);
            defer cb.close();
        }
        {
            const cb = try h.checkbox("Send me product updates", .medium);
            defer cb.close();
        }
        {
            const sl = try h.slider("Experience (years)", 5, 0, 20);
            defer sl.close();
        }
        {
            const b = try h.button("Cancel", .graphite, .medium);
            defer b.close();
        }
        {
            const b = try h.button("Create Account", .mint, .large);
            defer b.close();
        }

        // ── Preferences ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Preferences");
        }
        {
            const sw = try h.toggle("Dark mode", .medium);
            defer sw.close();
        }
        {
            const sw = try h.toggle("Email notifications", .medium);
            defer sw.close();
        }
        {
            const cl = try h.color("Accent color", "#4F46E5");
            defer cl.close();
        }
        {
            const fl = try h.file("Upload avatar");
            defer fl.close();
        }

        // ── Segment group ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("View Mode");
        }
        {
            const sg = try h.segmentGroup(.small);
            defer sg.close();
            {
                const s = try h.segment("list", "List");
                defer s.close();
            }
            {
                const s = try h.segment("grid", "Grid");
                defer s.close();
            }
            {
                const s = try h.segment("map", "Map");
                defer s.close();
            }
        }

        // ── Progress ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Progress");
        }
        {
            const pg = try h.progress(72, 100, .medium, .mint);
            defer pg.close();
        }
        {
            const pg = try h.progress(45, 100, .medium, .amber);
            defer pg.close();
        }

        // ── Loading ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Loading");
        }
        {
            const ld = try h.loading();
            defer ld.close();
        }

        // ── Tabs ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Tabs");
        }
        {
            const tbs = try h.tabs();
            defer tbs.close();
            {
                const t = try h.tab("Overview");
                defer t.close();
            }
            {
                const t = try h.tab("Billing");
                defer t.close();
            }
            {
                const t = try h.tab("Team");
                defer t.close();
            }
            {
                const t = try h.tab("Settings");
                defer t.close();
            }
        }

        // ── Navigation ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Navigation");
        }
        {
            const bc = try h.breadcrumbs(.small);
            defer bc.close();
            {
                const a = try h.html.el("a", .{ .href = "#" });
                defer a.close();
                try h.html.text("Home");
            }
            {
                const a = try h.html.el("a", .{ .href = "#" });
                defer a.close();
                try h.html.text("Settings");
            }
            {
                const span = try h.html.el("span", .{});
                defer span.close();
                try h.html.text("Profile");
            }
        }

        // ── Pagination ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Pagination");
        }
        {
            const pg = try h.pagination(24, 2, .small);
            defer pg.close();
        }

        // ── Resizable ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Resizable Panes");
        }
        {
            const rz = try h.resizable("row");
            defer rz.close();
            {
                const div = try h.html.el("div", .{});
                defer div.close();
                try h.html.text("Left");
            }
            {
                const div = try h.html.el("div", .{});
                defer div.close();
                try h.html.text("Right");
            }
        }

        // ── Overlays ──
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Overlays");
        }

        // Tooltip
        {
            const tt = try h.tooltip("Copy link", .top, .small);
            defer tt.close();
            const b = try h.button("Hover for tooltip", .mint, .small);
            defer b.close();
        }

        // Popover
        {
            const po = try h.popover(.bottom, .medium, "Actions");
            defer po.close();
            {
                const b = try h.html.el("jelly-button", .{ .slot = "trigger", .variant = "mint", .size = "small" });
                defer b.close();
                try h.html.text("Options");
            }
            {
                const div = try h.html.el("div", .{ .slot = "content" });
                defer div.close();
                try h.html.text("Export, share, or delete this item.");
            }
        }

        // Menu
        {
            const m = try h.menu(.bottom, .small);
            defer m.close();
            {
                const b = try h.html.el("jelly-button", .{ .slot = "trigger", .variant = "amber", .size = "small" });
                defer b.close();
                try h.html.text("Actions");
            }
            {
                const mi = try h.menuItem("edit", "Edit");
                defer mi.close();
            }
            {
                const mi = try h.menuItem("duplicate", "Duplicate");
                defer mi.close();
            }
            {
                const mi = try h.menuItem("delete", "Delete");
                defer mi.close();
            }
        }

        // Dialog
        {
            const b = try h.button("Open Dialog", .azure, .medium);
            defer b.close();
        }
        {
            const d = try h.dialog("Delete Project");
            defer d.close();
            {
                const p = try h.html.el("p", .{});
                defer p.close();
                try h.html.text("This action is permanent and cannot be undone.");
            }
            {
                const b = try h.button("Cancel", .graphite, .small);
                defer b.close();
            }
            {
                const b = try h.button("Delete", .rose, .small);
                defer b.close();
            }
        }

        // Drawer
        {
            const b = try h.button("Open Drawer", .mint, .medium);
            defer b.close();
        }
        {
            const dr = try h.drawer("end", "Navigation Drawer");
            defer dr.close();
            {
                const h3 = try h.html.el("h3", .{});
                defer h3.close();
                try h.html.text("Dashboard");
            }
            {
                const p = try h.html.el("p", .{});
                defer p.close();
                try h.html.text("Projects, reports, and settings live here.");
            }
        }

        // Avatar
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Avatar");
        }
        {
            const av = try h.avatar("https://placehold.co/48x48", "User", .large);
            defer av.close();
        }
    }

    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created jelly.html ({d} bytes)", .{fw.pos});
}
