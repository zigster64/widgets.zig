const std = @import("std");
const Io = std.Io;
const Dir = Io.Dir;
const widgets_zig = @import("widgets_zig");

pub fn picoPage(io: Io) !void {
    const dir = Dir.cwd();
    const file = try Dir.createFile(dir, io, "docs/pico.html", .{});
    defer file.close(io);

    var buf: [16384]u8 = undefined;
    var fw = Io.File.Writer.init(file, io, &buf);
    const w = &fw.interface;

    // Raw header: DOCTYPE, html, head with Pico CDN, opening body
    try w.writeAll(
        \\<!DOCTYPE html>
        \\<html lang="en" data-theme="light">
        \\<head>
        \\<meta charset="utf-8">
        \\<meta name="viewport" content="width=device-width, initial-scale=1">
        \\<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
        \\<title>PicoCSS Demo</title>
        \\</head>
        \\<body>
        \\
    );

    const h = widgets_zig.PicoCSS(w);

    // Nav — demo links (same as index.html)
    {
        const n = try h.html.el("header", .{ .id = "top" });
        defer n.close();
        const nav = try h.html.el("nav", .{ .class = "menu" });
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
            .{ "Macintosh", "macintosh.html" },
            .{ "Orbit", "orbit.html" },
        }) |link| {
            const a = try h.html.el("a", .{ .href = link[1] });
            defer a.close();
            try h.html.text(link[0]);
        }
    }

    // ── Container (rest of the doc) ──
    {
        const ctr = try h.container();
        defer ctr.close();

        // Breadcrumbs
        {
            const bc = try h.breadcrumbs();
            defer bc.close();
            const li = try h.html.el("li", .{});
            defer li.close();
            const a = try h.html.el("a", .{ .href = "#" });
            defer a.close();
            try h.html.text("PicoCSS Demo");
        }

        // Page heading
        {
            const h1 = try h.html.h1("PicoCSS Widgets Demo", .{});
            defer h1.close();
        }

        // ── Theme Switcher ──
    {
        const h2 = try h.html.el("h2", .{});
        defer h2.close();
        try h.html.text("Theme");
    }
    {
        const b = try h.button("Light", .{ .onclick = "document.documentElement.setAttribute('data-theme','light')" });
        defer b.close();
    }
    {
        const b = try h.button("Dark", .{ .onclick = "document.documentElement.setAttribute('data-theme','dark')", .class = "contrast" });
        defer b.close();
    }

        // ── Nav (brand) ──
        {
            const n = try h.nav(.{});
            defer n.close();
            {
                const ul = try h.html.el("ul", .{});
                defer ul.close();
                {
                    const li = try h.html.el("li", .{});
                    defer li.close();
                    const strong = try h.html.el("strong", .{});
                    defer strong.close();
                    try h.html.text("Acme Corp");
                }
            }
            {
                const ul = try h.html.el("ul", .{});
                defer ul.close();
                const items = [_][2][]const u8{
                    .{ "About", "#" },
                    .{ "Services", "#" },
                    .{ "Products", "#" },
                };
                for (&items) |item| {
                    const li = try h.html.el("li", .{});
                    defer li.close();
                    const a = try h.html.el("a", .{ .href = item[1], .class = "contrast" });
                    defer a.close();
                    try h.html.text(item[0]);
                }
            }
        }

        // Grid of cards
        {
            const g = try h.grid();
            defer g.close();
            for ([_][]const u8{ "PicoCSS", "Semantic", "Fast CSS" }) |title| {
                const c = try h.card(.{});
                defer c.close();
                {
                    const h2 = try h.html.el("h2", .{});
                    defer h2.close();
                    try h.html.text(title);
                }
                const p = try h.html.el("p", .{});
                defer p.close();
                try h.html.text("Pico styles native HTML with zero class overhead.");
            }
        }

        // Buttons
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Buttons");
        }
        {
            const b = try h.button("Primary", .{});
            defer b.close();
        }
        {
            const b = try h.button("Secondary", .{ .class = "secondary" });
            defer b.close();
        }
        {
            const b = try h.button("Contrast", .{ .class = "contrast" });
            defer b.close();
        }
        {
            const b = try h.button("Outline", .{ .class = "outline" });
            defer b.close();
        }

        // Typography
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Typography");
        }
        {
            for ([_][]const u8{ "h1", "h2", "h3", "h4", "h5", "h6" }) |tag| {
                const el = try h.html.el(tag, .{});
                defer el.close();
                try h.html.text(tag);
            }
        }

        // Links
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Links");
        }
        {
            const a = try h.html.el("a", .{ .href = "#" });
            defer a.close();
            try h.html.text("Primary link");
        }
        {
            const a = try h.html.el("a", .{ .href = "#", .class = "secondary" });
            defer a.close();
            try h.html.text("Secondary link");
        }

        // Tooltips
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Tooltips");
        }
        for ([_][]const u8{ "Top", "Right", "Bottom", "Left" }) |pos| {
            var attrs: struct {
                @"data-tooltip": []const u8,
                @"data-placement": ?[]const u8 = null,
            } = .{ .@"data-tooltip" = pos };
            if (!std.mem.eql(u8, pos, "Top")) attrs.@"data-placement" = pos;
            const b = try h.html.el("button", attrs);
            defer b.close();
            try h.html.text(pos);
        }

        // Accordion
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Accordion");
        }
        {
            const acc = try h.accordion("Click to expand", .{});
            defer acc.close();
            const p = try h.html.el("p", .{});
            defer p.close();
            try h.html.text("Hidden content revealed on click.");
        }

        // Progress
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Progress");
        }
        {
            const pg = try h.progress(65, 100);
            defer pg.close();
        }

        // Table
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Table");
        }
        {
            const t = try h.table(.{});
            defer t.close();
            {
                const thead = try h.html.el("thead", .{});
                defer thead.close();
                const tr = try h.html.el("tr", .{});
                defer tr.close();
                for ([_][]const u8{ "Name", "Role" }) |hdr| {
                    const th = try h.html.el("th", .{ .scope = "col" });
                    defer th.close();
                    try h.html.text(hdr);
                }
            }
            {
                const tbody = try h.html.el("tbody", .{});
                defer tbody.close();
                const rows = [_][2][]const u8{
                    .{ "Zig", "Language" },
                    .{ "PicoCSS", "CSS Framework" },
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

        // Range
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Range");
        }
        try h.html.elVoid("input", .{ .@"type" = "range", .min = 0, .max = 100, .value = 50 });

        // Switch
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Switch");
        }
        {
            const label = try h.html.el("label", .{ .@"for" = "switch-demo" });
            defer label.close();
            try h.html.elVoid("input", .{ .@"type" = "checkbox", .id = "switch-demo", .role = "switch" });
            try h.html.text(" Enable notifications");
        }

        // Radios
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Radios");
        }
        {
            const f = try h.html.el("fieldset", .{});
            defer f.close();
            for ([_][]const u8{ "Option A", "Option B", "Option C" }) |opt| {
                const label = try h.html.el("label", .{ .@"for" = opt });
                defer label.close();
                try h.html.elVoid("input", .{ .@"type" = "radio", .id = opt, .name = "radios" });
                try h.html.text(" ");
                try h.html.text(opt);
            }
        }

        // Checkboxes
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Checkboxes");
        }
        {
            const f = try h.html.el("fieldset", .{});
            defer f.close();
            for ([_][]const u8{ "Check A", "Check B" }) |opt| {
                const label = try h.html.el("label", .{ .@"for" = opt });
                defer label.close();
                try h.html.elVoid("input", .{ .@"type" = "checkbox", .id = opt, .name = "checks" });
                try h.html.text(" ");
                try h.html.text(opt);
            }
        }

        // Signup Form
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Signup Form");
        }
        {
            const form = try h.html.el("form", .{});
            defer form.close();

            // Username
            {
                const label = try h.html.el("label", .{ .@"for" = "username" });
                defer label.close();
                try h.html.text("Username");
                try h.html.elVoid("input", .{
                    .@"type" = "text",
                    .id = "username",
                    .name = "username",
                    .placeholder = "Choose a username",
                    .required = true,
                });
            }

            // Password
            {
                const label = try h.html.el("label", .{ .@"for" = "password" });
                defer label.close();
                try h.html.text("Password");
                try h.html.elVoid("input", .{
                    .@"type" = "password",
                    .id = "password",
                    .name = "password",
                    .placeholder = "At least 8 characters",
                    .required = true,
                });
            }

            // Experience (range)
            {
                const label = try h.html.el("label", .{ .@"for" = "experience" });
                defer label.close();
                try h.html.text("Experience (years)");
                try h.html.elVoid("input", .{
                    .@"type" = "range",
                    .id = "experience",
                    .name = "experience",
                    .min = 0,
                    .max = 20,
                    .value = 3,
                });
            }

            // Country select
            {
                const label = try h.html.el("label", .{ .@"for" = "country" });
                defer label.close();
                try h.html.text("Country");
                const sel = try h.html.el("select", .{ .id = "country", .name = "country" });
                defer sel.close();
                for ([_][]const u8{ "United States", "Canada", "United Kingdom", "Australia" }) |c| {
                    const opt = try h.html.el("option", .{ .value = c });
                    defer opt.close();
                    try h.html.text(c);
                }
            }

            // Account type (radios)
            {
                const fs = try h.html.el("fieldset", .{});
                defer fs.close();
                {
                    const leg = try h.html.el("legend", .{});
                    defer leg.close();
                    try h.html.text("Account type");
                }
                for ([_][]const u8{ "Free", "Premium", "Enterprise" }) |plan| {
                    const label = try h.html.el("label", .{ .@"for" = plan });
                    defer label.close();
                    try h.html.elVoid("input", .{
                        .@"type" = "radio",
                        .id = plan,
                        .name = "account",
                        .value = plan,
                    });
                    try h.html.text(" ");
                    try h.html.text(plan);
                }
            }

            // Acceptance checkboxes
            {
                const fs = try h.html.el("fieldset", .{});
                defer fs.close();
                {
                    const label = try h.html.el("label", .{ .@"for" = "terms" });
                    defer label.close();
                    try h.html.elVoid("input", .{
                        .@"type" = "checkbox",
                        .id = "terms",
                        .name = "terms",
                        .required = true,
                    });
                    try h.html.text(" I agree to the Terms of Service");
                }
                {
                    const label = try h.html.el("label", .{ .@"for" = "marketing" });
                    defer label.close();
                    try h.html.elVoid("input", .{
                        .@"type" = "checkbox",
                        .id = "marketing",
                        .name = "marketing",
                    });
                    try h.html.text(" Send me product updates");
                }
            }

            // Buttons
            {
                const b = try h.button("Cancel", .{ .class = "secondary" });
                defer b.close();
            }
            {
                const b = try h.button("Sign Up", .{});
                defer b.close();
            }
        }

        // Select
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Select");
        }
        {
            const label = try h.html.el("label", .{ .@"for" = "framework" });
            defer label.close();
            try h.html.text("Framework");
            const sel = try h.html.el("select", .{ .id = "framework", .name = "framework" });
            defer sel.close();
            for ([_][]const u8{ "PicoCSS", "Bootstrap", "Tailwind" }) |opt| {
                const o = try h.html.el("option", .{ .value = opt });
                defer o.close();
                try h.html.text(opt);
            }
        }

        // Group form (fieldset role="group")
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Group");
        }
        {
            const form = try h.html.el("form", .{});
            defer form.close();
            {
                const fs = try h.html.el("fieldset", .{ .role = "group" });
                defer fs.close();
                try h.html.elVoid("input", .{ .name = "email2", .@"type" = "email", .placeholder = "Enter your email", .autocomplete = "email" });
                try h.html.elVoid("input", .{ .@"type" = "submit", .value = "Subscribe" });
            }
        }

        // Textarea
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Textarea");
        }
        {
            const label = try h.html.el("label", .{ .@"for" = "msg" });
            defer label.close();
            try h.html.text("Message");
            {
                const ta = try h.html.el("textarea", .{ .id = "msg", .name = "msg", .placeholder = "Your message..." });
                defer ta.close();
            }
        }

        // Dropdown
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Dropdown");
        }
        {
            const det = try h.html.el("details", .{ .role = "list" });
            defer det.close();
            {
                const sum = try h.html.el("summary", .{});
                defer sum.close();
                try h.html.text("Actions");
            }
            {
                const ul = try h.html.el("ul", .{});
                defer ul.close();
                for ([_][]const u8{ "Edit", "Delete", "Archive" }) |action| {
                    const li = try h.html.el("li", .{});
                    defer li.close();
                    const a = try h.html.el("a", .{ .href = "#" });
                    defer a.close();
                    try h.html.text(action);
                }
            }
        }

        // Loading
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Loading");
        }
        {
            const ld = try h.html.el("span", .{ .aria_busy = "true" });
            defer ld.close();
        }

        // Nav example
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Nav");
        }
        {
            const n = try h.nav(.{});
            defer n.close();
            {
                const ul = try h.html.el("ul", .{});
                defer ul.close();
                const li = try h.html.el("li", .{});
                defer li.close();
                const a = try h.html.el("a", .{ .href = "index.html" });
                defer a.close();
                try h.html.text("Index");
                const li2 = try h.html.el("li", .{});
                defer li2.close();
                const a2 = try h.html.el("a", .{ .href = "generated.html" });
                defer a2.close();
                try h.html.text("Generated");
            }
        }

        // Modal
        {
            const h2 = try h.html.el("h2", .{});
            defer h2.close();
            try h.html.text("Modal");
        }
        {
            const b = try h.button("Open Signup Modal", .{ .onclick = "document.getElementById('signup-modal').showModal()" });
            defer b.close();
        }
        {
            const m = try h.modal(.{ .id = "signup-modal" });
            defer m.close();
            {
                const h3 = try h.html.el("h3", .{});
                defer h3.close();
                try h.html.text("Quick Signup");
            }
            // Email in modal
            {
                const label = try h.html.el("label", .{ .@"for" = "modal-email" });
                defer label.close();
                try h.html.text("Email");
                try h.html.elVoid("input", .{
                    .@"type" = "email",
                    .id = "modal-email",
                    .name = "modal-email",
                    .placeholder = "Email",
                });
            }
            // Password in modal
            {
                const label = try h.html.el("label", .{ .@"for" = "modal-pass" });
                defer label.close();
                try h.html.text("Password");
                try h.html.elVoid("input", .{
                    .@"type" = "password",
                    .id = "modal-pass",
                    .name = "modal-pass",
                    .placeholder = "Password",
                });
            }
            // Newsletter checkbox in modal
            {
                const label = try h.html.el("label", .{ .@"for" = "modal-news" });
                defer label.close();
                try h.html.elVoid("input", .{
                    .@"type" = "checkbox",
                    .id = "modal-news",
                    .name = "modal-news",
                });
                try h.html.text(" Subscribe to newsletter");
            }
            // Buttons
            {
                const b = try h.button("Cancel", .{ .class = "secondary", .onclick = "document.getElementById('signup-modal').close()" });
                defer b.close();
            }
            {
                const b = try h.button("Register", .{ .class = "contrast" });
                defer b.close();
            }
            // Close link
            {
                const a = try h.html.el("a", .{ .href = "#", .@"data-dismiss" = "modal" });
                defer a.close();
                try h.html.text("Close");
            }
        }


    } // end container

    // Close body + html
    try w.writeAll("</body>\n</html>\n");
    try fw.flush();
    std.log.info("created pico.html ({d} bytes)", .{fw.pos});
}
