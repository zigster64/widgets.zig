const std = @import("std");
const Io = std.Io;

pub fn Html(writer: *Io.Writer) HtmlWidget {
    return .{ .writer = writer };
}

pub const Closer = struct {
    writer: *Io.Writer,
    tag: []const u8,

    pub fn close(self: Closer) void {
        self.writer.print("</{s}>\n", .{self.tag}) catch {};
    }
};

pub const HtmlWidget = struct {
    writer: *Io.Writer,

    fn isStringLike(comptime T: type) bool {
        const ti = @typeInfo(T);
        if (ti == .optional) {
            return isStringLike(@typeInfo(T).optional.child);
        }
        return switch (ti) {
            .pointer => |p| switch (p.size) {
                .slice => p.child == u8,
                .one => if (@typeInfo(p.child) == .array) @typeInfo(p.child).array.child == u8 else false,
                else => false,
            },
            else => false,
        };
    }

    fn writeAttribs(w: *Io.Writer, attribs: anytype) !void {
        inline for (comptime std.meta.fieldNames(@TypeOf(attribs))) |name| {
            const attr_name = comptime blk: {
                if (std.mem.indexOfScalar(u8, name, '_')) |_| {
                    var buf: [name.len]u8 = undefined;
                    for (name, 0..) |c, i| buf[i] = if (c == '_') '-' else c;
                    break :blk buf;
                }
                break :blk name;
            };
            const val = @field(attribs, name);
            if (comptime @typeInfo(@TypeOf(val)) == .optional) {
                if (val) |v| {
                    if (comptime isStringLike(@TypeOf(v))) {
                        try w.print(" {s}=\"{s}\"", .{ attr_name, v });
                    } else {
                        try w.print(" {s}=\"{any}\"", .{ attr_name, v });
                    }
                }
            } else if (comptime isStringLike(@TypeOf(val))) {
                try w.print(" {s}=\"{s}\"", .{ attr_name, val });
            } else {
                try w.print(" {s}=\"{any}\"", .{ attr_name, val });
            }
        }
    }

    pub fn el(self: HtmlWidget, tag: []const u8, attribs: anytype) !Closer {
        try self.writer.print("<{s}", .{tag});
        try writeAttribs(self.writer, attribs);
        try self.writer.writeAll(">");
        return .{ .writer = self.writer, .tag = tag };
    }

    pub fn html(self: HtmlWidget, attribs: anytype) !Closer {
        try self.writer.writeAll("<!DOCTYPE html>\n<html");
        try writeAttribs(self.writer, attribs);
        try self.writer.writeAll(">\n");
        return .{ .writer = self.writer, .tag = "html" };
    }

    pub fn elVoid(self: HtmlWidget, tag: []const u8, attribs: anytype) !void {
        try self.writer.print("<{s}", .{tag});
        try writeAttribs(self.writer, attribs);
        try self.writer.writeAll(">\n");
    }

    pub fn text(self: HtmlWidget, content: []const u8) !void {
        try self.writer.writeAll(content);
    }

    pub fn head(self: HtmlWidget, attribs: anytype) !Closer {
        return self.el("head", attribs);
    }

    pub fn body(self: HtmlWidget, attribs: anytype) !Closer {
        return self.el("body", attribs);
    }

    pub fn meta(self: HtmlWidget, attribs: anytype) !void {
        try self.elVoid("meta", attribs);
    }

    pub fn title(self: HtmlWidget, txt: []const u8, attribs: anytype) !Closer {
        const c = try self.el("title", attribs);
        try self.writer.writeAll(txt);
        return c;
    }

    pub fn h1(self: HtmlWidget, txt: []const u8, attribs: anytype) !Closer {
        const c = try self.el("h1", attribs);
        try self.writer.writeAll(txt);
        return c;
    }
};

// ── PicoCSS ──

pub fn PicoCSS(writer: *Io.Writer) PicoWidget {
    return .{ .html = Html(writer) };
}

pub const PicoWidget = struct {
    html: HtmlWidget,

    /// `<article>` — Pico card
    pub fn card(self: PicoWidget, attribs: anytype) !Closer {
        return self.html.el("article", attribs);
    }

    /// `<button attribs>txt` → `</button>`
    pub fn button(self: PicoWidget, txt: []const u8, attribs: anytype) !Closer {
        const c = try self.html.el("button", attribs);
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<nav attribs>`
    pub fn nav(self: PicoWidget, attribs: anytype) !Closer {
        return self.html.el("nav", attribs);
    }

    /// `<div class="grid">`
    pub fn grid(self: PicoWidget) !Closer {
        return self.html.el("div", .{ .class = "grid" });
    }

    /// `<details attribs><summary>summary</summary>`
    pub fn accordion(self: PicoWidget, summary: []const u8, attribs: anytype) !Closer {
        const c = try self.html.el("details", attribs);
        try self.html.writer.print("<summary>{s}</summary>", .{summary});
        return c;
    }

    /// `<progress value="val" max="max">` — container, not void
    pub fn progress(self: PicoWidget, value: u32, max: u32) !Closer {
        return self.html.el("progress", .{ .value = value, .max = max });
    }

    /// `<dialog attribs><article>` —  closer emits `</article></dialog>`
    pub fn modal(self: PicoWidget, attribs: anytype) !ModalCloser {
        try self.html.writer.print("<dialog", .{});
        try HtmlWidget.writeAttribs(self.html.writer, attribs);
        try self.html.writer.writeAll(">\n<article>");
        return .{ .writer = self.html.writer };
    }

    /// `<table attribs>`
    pub fn table(self: PicoWidget, attribs: anytype) !Closer {
        return self.html.el("table", attribs);
    }

    /// `<nav aria-label="breadcrumb"><ul>`
    pub fn breadcrumbs(self: PicoWidget) !Closer {
        const c = try self.html.el("nav", .{ .aria_label = "breadcrumb" });
        try self.html.writer.writeAll("<ul>");
        return c;
    }

    /// `<div class="container">`
    pub fn container(self: PicoWidget) !Closer {
        return self.html.el("div", .{ .class = "container" });
    }
};

// ── JellyUI ──

pub const JellySize = enum { small, medium, large };
pub const JellyMode = enum { light, dark, auto };
pub const JellyPlacement = enum { top, bottom, left, right, start, end };
pub const JellyVariant = enum { azure, rose, amber, mint, graphite, platinum, white };

pub fn JellyUI(writer: *Io.Writer) JellyWidget {
    return .{ .html = Html(writer) };
}

pub const JellyWidget = struct {
    html: HtmlWidget,

    fn variantStr(v: JellyVariant) []const u8 {
        return @tagName(v);
    }

    fn sizeStr(s: JellySize) []const u8 {
        return @tagName(s);
    }

    fn modeStr(m: JellyMode) []const u8 {
        return @tagName(m);
    }

    fn placementStr(p: JellyPlacement) []const u8 {
        return @tagName(p);
    }

    /// `<jelly-theme mode="...">` — scoped theme provider
    pub fn theme(self: JellyWidget, mode: JellyMode) !Closer {
        return self.html.el("jelly-theme", .{ .mode = modeStr(mode) });
    }

    /// `<jelly-button variant="..." size="...">txt</jelly-button>`
    pub fn button(self: JellyWidget, txt: []const u8, variant: ?JellyVariant, size: ?JellySize) !Closer {
        var attrs: struct { variant: []const u8, size: ?[]const u8 = null } = .{ .variant = if (variant) |v| variantStr(v) else "mint" };
        if (size) |s| attrs.size = sizeStr(s);
        const c = try self.html.el("jelly-button", attrs);
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<jelly-icon-button variant="..." size="..." label="...">`
    pub fn iconButton(self: JellyWidget, label: []const u8, variant: ?JellyVariant, size: ?JellySize) !Closer {
        var attrs: struct { label: []const u8, variant: []const u8, size: ?[]const u8 = null } = .{
            .label = label,
            .variant = if (variant) |v| variantStr(v) else "mint",
        };
        if (size) |s| attrs.size = sizeStr(s);
        return self.html.el("jelly-icon-button", attrs);
    }

    /// `<jelly-input type="..." size="..." label="..." placeholder="...">`
    pub fn input(self: JellyWidget, label: []const u8, comptime input_type: []const u8, placeholder: ?[]const u8, size: ?JellySize) !Closer {
        var attrs: struct {
            label: []const u8,
            type: []const u8,
            size: ?[]const u8 = null,
            placeholder: ?[]const u8 = null,
        } = .{ .label = label, .type = input_type };
        if (size) |s| attrs.size = sizeStr(s);
        if (placeholder) |p| attrs.placeholder = p;
        return self.html.el("jelly-input", attrs);
    }

    /// `<jelly-textarea label="..." placeholder="..." size="...">`
    pub fn textarea(self: JellyWidget, label: []const u8, placeholder: ?[]const u8, size: ?JellySize) !Closer {
        var attrs: struct {
            label: []const u8,
            size: ?[]const u8 = null,
            placeholder: ?[]const u8 = null,
        } = .{ .label = label };
        if (size) |s| attrs.size = sizeStr(s);
        if (placeholder) |p| attrs.placeholder = p;
        return self.html.el("jelly-textarea", attrs);
    }

    /// `<jelly-select label="..." size="...">`
    pub fn select(self: JellyWidget, label: []const u8, size: ?JellySize) !Closer {
        var attrs: struct { label: []const u8, size: ?[]const u8 = null } = .{ .label = label };
        if (size) |s| attrs.size = sizeStr(s);
        return self.html.el("jelly-select", attrs);
    }

    /// `<jelly-option value="...">Label</jelly-option>`
    pub fn option(self: JellyWidget, value: []const u8, label: []const u8) !Closer {
        const c = try self.html.el("jelly-option", .{ .value = value });
        try self.html.writer.writeAll(label);
        return c;
    }

    /// `<jelly-checkbox size="..." checked? disabled?>Label</jelly-checkbox>`
    pub fn checkbox(self: JellyWidget, label: []const u8, size: ?JellySize) !Closer {
        var attrs: struct { size: ?[]const u8 = null } = .{};
        if (size) |s| attrs.size = sizeStr(s);
        const c = try self.html.el("jelly-checkbox", attrs);
        try self.html.writer.writeAll(label);
        return c;
    }

    /// `<jelly-switch size="..." label="...">`
    pub fn toggle(self: JellyWidget, label: []const u8, size: ?JellySize) !Closer {
        var attrs: struct { label: []const u8, size: ?[]const u8 = null } = .{ .label = label };
        if (size) |s| attrs.size = sizeStr(s);
        return self.html.el("jelly-switch", attrs);
    }

    /// `<jelly-radio-group label="...">`
    pub fn radioGroup(self: JellyWidget, label: []const u8) !Closer {
        return self.html.el("jelly-radio-group", .{ .label = label });
    }

    /// `<jelly-radio value="..." size="...">Label</jelly-radio>`
    pub fn radio(self: JellyWidget, value: []const u8, label: []const u8, size: ?JellySize) !Closer {
        var attrs: struct { value: []const u8, size: ?[]const u8 = null } = .{ .value = value };
        if (size) |s| attrs.size = sizeStr(s);
        const c = try self.html.el("jelly-radio", attrs);
        try self.html.writer.writeAll(label);
        return c;
    }

    /// `<jelly-card>`
    pub fn card(self: JellyWidget) !Closer {
        return self.html.el("jelly-card", .{});
    }

    /// `<jelly-badge variant="..." size="...">txt</jelly-badge>`
    pub fn badge(self: JellyWidget, txt: []const u8, variant: ?JellyVariant, size: ?JellySize) !Closer {
        var attrs: struct { variant: []const u8, size: ?[]const u8 = null } = .{ .variant = if (variant) |v| variantStr(v) else "mint" };
        if (size) |s| attrs.size = sizeStr(s);
        const c = try self.html.el("jelly-badge", attrs);
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<jelly-avatar src="..." alt="..." size="...">`
    pub fn avatar(self: JellyWidget, src: []const u8, alt: []const u8, size: ?JellySize) !Closer {
        var attrs: struct { src: []const u8, alt: []const u8, size: ?[]const u8 = null } = .{ .src = src, .alt = alt };
        if (size) |s| attrs.size = sizeStr(s);
        return self.html.el("jelly-avatar", attrs);
    }

    /// `<jelly-progress value="..." max="..." size="..." variant="...">`
    pub fn progress(self: JellyWidget, value: u32, max: u32, size: ?JellySize, variant: ?JellyVariant) !Closer {
        var attrs: struct {
            value: u32,
            max: u32,
            size: ?[]const u8 = null,
            variant: ?[]const u8 = null,
        } = .{ .value = value, .max = max };
        if (size) |s| attrs.size = sizeStr(s);
        if (variant) |v| attrs.variant = variantStr(v);
        return self.html.el("jelly-progress", attrs);
    }

    /// `<jelly-dialog label="...">`
    pub fn dialog(self: JellyWidget, label: []const u8) !Closer {
        return self.html.el("jelly-dialog", .{ .label = label });
    }

    /// `<jelly-tabs>`
    pub fn tabs(self: JellyWidget) !Closer {
        return self.html.el("jelly-tabs", .{});
    }

    /// `<jelly-tab label="...">`
    pub fn tab(self: JellyWidget, label: []const u8) !Closer {
        const c = try self.html.el("jelly-tab", .{});
        try self.html.writer.writeAll(label);
        return c;
    }

    /// `<jelly-slider label="..." value="..." min="..." max="...">`
    pub fn slider(self: JellyWidget, label: []const u8, value: u32, min: u32, max: u32) !Closer {
        return self.html.el("jelly-slider", .{ .label = label, .value = value, .min = min, .max = max });
    }

    /// `<jelly-color label="..." value="...">`
    pub fn color(self: JellyWidget, label: []const u8, value: []const u8) !Closer {
        return self.html.el("jelly-color", .{ .label = label, .value = value });
    }

    /// `<jelly-file label="...">`
    pub fn file(self: JellyWidget, label: []const u8) !Closer {
        return self.html.el("jelly-file", .{ .label = label });
    }

    /// `<jelly-loading>` — indeterminate spinner
    pub fn loading(self: JellyWidget) !Closer {
        return self.html.el("jelly-loading", .{});
    }

    /// `<jelly-segment-group size="...">`
    pub fn segmentGroup(self: JellyWidget, size: ?JellySize) !Closer {
        var attrs: struct { size: ?[]const u8 = null } = .{};
        if (size) |s| attrs.size = sizeStr(s);
        return self.html.el("jelly-segment-group", attrs);
    }

    /// `<jelly-segment value="...">Label</jelly-segment>`
    pub fn segment(self: JellyWidget, value: []const u8, label: []const u8) !Closer {
        const c = try self.html.el("jelly-segment", .{ .value = value });
        try self.html.writer.writeAll(label);
        return c;
    }

    /// `<jelly-breadcrumbs size="...">`
    pub fn breadcrumbs(self: JellyWidget, size: ?JellySize) !Closer {
        var attrs: struct { size: ?[]const u8 = null } = .{};
        if (size) |s| attrs.size = sizeStr(s);
        return self.html.el("jelly-breadcrumbs", attrs);
    }

    /// `<jelly-pagination total="..." page="..." size="...">`
    pub fn pagination(self: JellyWidget, total: u32, page: u32, size: ?JellySize) !Closer {
        var attrs: struct { total: u32, page: u32, size: ?[]const u8 = null } = .{ .total = total, .page = page };
        if (size) |s| attrs.size = sizeStr(s);
        return self.html.el("jelly-pagination", attrs);
    }

    /// `<jelly-resizable direction="...">`
    pub fn resizable(self: JellyWidget, direction: []const u8) !Closer {
        return self.html.el("jelly-resizable", .{ .direction = direction });
    }

    /// `<jelly-popover placement="..." size="..." label="...">`
    pub fn popover(self: JellyWidget, placement: ?JellyPlacement, size: ?JellySize, label: []const u8) !Closer {
        var attrs: struct {
            placement: ?[]const u8 = null,
            size: ?[]const u8 = null,
            label: []const u8,
        } = .{ .label = label };
        if (placement) |p| attrs.placement = placementStr(p);
        if (size) |s| attrs.size = sizeStr(s);
        return self.html.el("jelly-popover", attrs);
    }

    /// `<jelly-menu placement="..." size="...">`
    pub fn menu(self: JellyWidget, placement: ?JellyPlacement, size: ?JellySize) !Closer {
        var attrs: struct {
            placement: ?[]const u8 = null,
            size: ?[]const u8 = null,
        } = .{};
        if (placement) |p| attrs.placement = placementStr(p);
        if (size) |s| attrs.size = sizeStr(s);
        return self.html.el("jelly-menu", attrs);
    }

    /// `<jelly-menu-item value="...">Label</jelly-menu-item>`
    pub fn menuItem(self: JellyWidget, value: []const u8, label: []const u8) !Closer {
        const c = try self.html.el("jelly-menu-item", .{ .value = value });
        try self.html.writer.writeAll(label);
        return c;
    }

    /// `<jelly-drawer side="..." label="...">`
    pub fn drawer(self: JellyWidget, side: []const u8, label: []const u8) !Closer {
        return self.html.el("jelly-drawer", .{ .side = side, .label = label });
    }

    /// `<jelly-tooltip text="..." placement="..." size="...">`
    pub fn tooltip(self: JellyWidget, text: []const u8, placement: ?JellyPlacement, size: ?JellySize) !Closer {
        var attrs: struct {
            text: []const u8,
            placement: ?[]const u8 = null,
            size: ?[]const u8 = null,
        } = .{ .text = text };
        if (placement) |p| attrs.placement = placementStr(p);
        if (size) |s| attrs.size = sizeStr(s);
        return self.html.el("jelly-tooltip", attrs);
    }
};

// ── SNES.css ──

pub const SnesColor = enum { nature, plumber, sunshine, ocean, turquoise, phantom, rose, galaxy, ember };
pub const SnesBg = enum { @"soft-green", @"aged-yellow", @"soft-brown", @"soft-blue", @"soft-purple", @"soft-pink", @"soft-red", @"soft-grey" };

pub fn SnesCSS(writer: *Io.Writer) SnesWidget {
    return .{ .html = Html(writer) };
}

pub const SnesWidget = struct {
    html: HtmlWidget,

    fn colorClass(c: ?SnesColor) ?[]const u8 {
        return if (c) |col| blk: {
            const name = @tagName(col);
            break :blk name;
        } else null;
    }

    /// `<div class="snes-container has-...-bg">`
    pub fn container(self: SnesWidget, bg: SnesBg) !Closer {
        _ = bg; // autofix
        _ = bg; // autofix
        return self.html.el("div", .{ .class = "snes-container" });
    }

    /// `<h3 class="snes-container-title has-...-underline">`
    pub fn containerTitle(self: SnesWidget, txt: []const u8, underline: ?SnesColor) !Closer {
        var cls: [64]u8 = undefined;
        const title_class = if (underline) |c| std.fmt.bufPrint(&cls, "snes-container-title has-{s}-underline", .{@tagName(c)}) catch "snes-container-title" else "snes-container-title";
        const c = try self.html.el("h3", .{ .class = title_class });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<button class="snes-button has-...-color">txt</button>`
    pub fn button(self: SnesWidget, txt: []const u8, color: ?SnesColor) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = if (color) |c| std.fmt.bufPrint(&class_buf, "snes-button has-{s}-color", .{@tagName(c)}) catch "snes-button" else "snes-button";
        const c = try self.html.el("button", .{ .class = cls });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<a class="snes-link text-...-color">txt</a>`
    pub fn link(self: SnesWidget, txt: []const u8, color: ?SnesColor) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = if (color) |c| std.fmt.bufPrint(&class_buf, "snes-link text-{s}-color", .{@tagName(c)}) catch "snes-link" else "snes-link";
        const c = try self.html.el("a", .{ .href = "#", .class = cls });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<p class="text-...-color">txt</p>`
    pub fn text(self: SnesWidget, txt: []const u8, color: ?SnesColor) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = if (color) |c| std.fmt.bufPrint(&class_buf, "text-{s}-color", .{@tagName(c)}) catch "text-{s}-color" else "text-{s}-color";
        const c = try self.html.el("p", .{ .class = cls });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<ul class="snes-list is-...-list-color">`
    pub fn list(self: SnesWidget, color: ?SnesColor) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = if (color) |c| std.fmt.bufPrint(&class_buf, "snes-list is-{s}-list-color", .{@tagName(c)}) catch "snes-list" else "snes-list";
        return self.html.el("ul", .{ .class = cls });
    }

    /// `<input class="snes-input" type="...">`
    pub fn input(self: SnesWidget, comptime input_type: []const u8) !void {
        try self.html.elVoid("input", .{ .class = "snes-input", .type = input_type });
    }

    /// `<textarea class="snes-textarea">`
    pub fn textarea(self: SnesWidget) !Closer {
        return self.html.el("textarea", .{ .class = "snes-textarea" });
    }

    /// `<progress class="snes-progress" value="..." max="...">`
    pub fn progress(self: SnesWidget, value: u32, max: u32) !Closer {
        return self.html.el("progress", .{ .class = "snes-progress", .value = value, .max = max });
    }

    /// `<table class="snes-table">`
    pub fn table(self: SnesWidget) !Closer {
        return self.html.el("table", .{ .class = "snes-table" });
    }
};

// ── DaisyUI ──

pub const DuColor = enum { primary, secondary, accent, neutral, info, success, warning, err, ghost };
pub const DuSize = enum { xs, sm, md, lg, xl };
pub const DuBtnVariant = enum { primary, secondary, accent, neutral, ghost, link, outline, dash, soft };

pub fn DaisyUI(writer: *Io.Writer) DaisyWidget {
    return .{ .html = Html(writer) };
}

pub const DaisyWidget = struct {
    html: HtmlWidget,

    fn colorClass(c: DuColor) []const u8 {
        return switch (c) {
            .err => "error",
            else => @tagName(c),
        };
    }
    fn sizeClass(s: DuSize) []const u8 {
        return @tagName(s);
    }

    // ── Actions ──

    /// `<button class="btn btn-VARIANT btn-SIZE">txt</button>`
    pub fn button(self: DaisyWidget, txt: []const u8, variant: DuBtnVariant, size: DuSize) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = std.fmt.bufPrint(&class_buf, "btn btn-{s} btn-{s}", .{ @tagName(variant), @tagName(size) }) catch "btn";
        const c = try self.html.el("button", .{ .class = cls });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<div class="badge badge-COLOR badge-SIZE">txt</div>`
    pub fn badge(self: DaisyWidget, txt: []const u8, color: DuColor, size: DuSize) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = std.fmt.bufPrint(&class_buf, "badge badge-{s} badge-{s}", .{ colorClass(color), @tagName(size) }) catch "badge";
        const c = try self.html.el("div", .{ .class = cls });
        try self.html.writer.writeAll(txt);
        return c;
    }

    // ── Data Display ──

    /// `<div class="card bg-base-200 shadow-xl"><div class="card-body">...</div></div>`
    pub fn card(self: DaisyWidget) !Closer {
        return self.html.el("div", .{ .class = "card bg-base-200 shadow-xl" });
    }
    pub fn cardBody(self: DaisyWidget) !Closer {
        return self.html.el("div", .{ .class = "card-body" });
    }
    pub fn cardTitle(self: DaisyWidget, txt: []const u8) !Closer {
        const c = try self.html.el("h2", .{ .class = "card-title" });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<div class="alert alert-COLOR">...</div>`
    pub fn alert(self: DaisyWidget, color: DuColor) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = std.fmt.bufPrint(&class_buf, "alert alert-{s}", .{colorClass(color)}) catch "alert";
        return self.html.el("div", .{ .class = cls });
    }

    /// `<div class="avatar"><div class="w-SIZE rounded-full"><img src="..."/></div></div>`
    pub fn avatar(self: DaisyWidget, src: []const u8, size: DuSize) !Closer {
        const c = try self.html.el("div", .{ .class = "avatar" });
        var class_buf: [32]u8 = undefined;
        const size_px = @as(u32, @intFromEnum(size)) * 4 + 8;
        const inner_cls = std.fmt.bufPrint(&class_buf, "w-{d} rounded-full", .{size_px}) catch "w-12 rounded-full";
        const inner = try self.html.el("div", .{ .class = inner_cls });
        defer inner.close();
        try self.html.writer.print("<img src=\"{s}\" />", .{src});
        return c;
    }

    // ── Navigation ──

    /// `<div class="navbar bg-base-100">`
    pub fn navbar(self: DaisyWidget) !Closer {
        return self.html.el("div", .{ .class = "navbar bg-base-100" });
    }

    /// `<ul class="menu bg-base-200 rounded-box">`
    pub fn menu(self: DaisyWidget) !Closer {
        return self.html.el("ul", .{ .class = "menu bg-base-200 rounded-box" });
    }

    /// `<div class="breadcrumbs">`
    pub fn breadcrumbs(self: DaisyWidget) !Closer {
        return self.html.el("div", .{ .class = "breadcrumbs text-sm" });
    }

    /// `<ul class="steps">`
    pub fn steps(self: DaisyWidget) !Closer {
        return self.html.el("ul", .{ .class = "steps" });
    }
    pub fn step(self: DaisyWidget, txt: []const u8, active: bool) !Closer {
        const cls = if (active) "step step-primary" else "step";
        const c = try self.html.el("li", .{ .class = cls });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<div class="tabs">`
    pub fn tabs(self: DaisyWidget) !Closer {
        return self.html.el("div", .{ .class = "tabs" });
    }
    pub fn tab(self: DaisyWidget, txt: []const u8, active: bool) !Closer {
        const cls = if (active) "tab tab-active" else "tab";
        const c = try self.html.el("a", .{ .class = cls });
        try self.html.writer.writeAll(txt);
        return c;
    }

    // ── Layout ──

    /// `<div class="divider divider-COLOR">txt</div>`
    pub fn divider(self: DaisyWidget, txt: []const u8, color: ?DuColor) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = if (color) |c| std.fmt.bufPrint(&class_buf, "divider divider-{s}", .{@tagName(c)}) catch "divider" else "divider";
        const c = try self.html.el("div", .{ .class = cls });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<div class="hero bg-base-200">`
    pub fn hero(self: DaisyWidget) !Closer {
        return self.html.el("div", .{ .class = "hero bg-base-200" });
    }

    /// `<footer class="footer bg-neutral text-neutral-content p-10">`
    pub fn footer(self: DaisyWidget) !Closer {
        return self.html.el("footer", .{ .class = "footer bg-neutral text-neutral-content p-10" });
    }

    /// `<div class="stack">`
    pub fn stack(self: DaisyWidget) !Closer {
        return self.html.el("div", .{ .class = "stack" });
    }

    /// `<div class="join">`
    pub fn join(self: DaisyWidget) !Closer {
        return self.html.el("div", .{ .class = "join" });
    }

    // ── Data Input ──

    /// `<input class="input input-bordered" type="..." placeholder="...">`
    pub fn input(self: DaisyWidget, comptime input_type: []const u8, placeholder: []const u8) !void {
        try self.html.elVoid("input", .{ .class = "input input-bordered", .type = input_type, .placeholder = placeholder });
    }

    /// `<textarea class="textarea textarea-bordered" placeholder="...">`
    pub fn textarea(self: DaisyWidget, placeholder: []const u8) !Closer {
        return self.html.el("textarea", .{ .class = "textarea textarea-bordered", .placeholder = placeholder });
    }

    /// `<select class="select select-bordered">`
    pub fn select(self: DaisyWidget) !Closer {
        return self.html.el("select", .{ .class = "select select-bordered" });
    }

    /// `<input type="checkbox" class="checkbox checkbox-COLOR">`
    pub fn checkbox(self: DaisyWidget, color: ?DuColor) !void {
        var class_buf: [32]u8 = undefined;
        const cls = if (color) |c| std.fmt.bufPrint(&class_buf, "checkbox checkbox-{s}", .{@tagName(c)}) catch "checkbox" else "checkbox";
        try self.html.elVoid("input", .{ .class = cls, .type = "checkbox" });
    }

    /// `<input type="radio" class="radio radio-COLOR">`
    pub fn radio(self: DaisyWidget, color: ?DuColor) !void {
        var class_buf: [32]u8 = undefined;
        const cls = if (color) |c| std.fmt.bufPrint(&class_buf, "radio radio-{s}", .{@tagName(c)}) catch "radio" else "radio";
        try self.html.elVoid("input", .{ .class = cls, .type = "radio" });
    }

    /// `<input type="checkbox" class="toggle toggle-COLOR">`
    pub fn toggle(self: DaisyWidget, color: ?DuColor) !void {
        var class_buf: [32]u8 = undefined;
        const cls = if (color) |c| std.fmt.bufPrint(&class_buf, "toggle toggle-{s}", .{@tagName(c)}) catch "toggle" else "toggle";
        try self.html.elVoid("input", .{ .class = cls, .type = "checkbox" });
    }

    /// `<input type="range" class="range range-COLOR">`
    pub fn range(self: DaisyWidget, color: ?DuColor) !void {
        var class_buf: [32]u8 = undefined;
        const cls = if (color) |c| std.fmt.bufPrint(&class_buf, "range range-{s}", .{@tagName(c)}) catch "range" else "range";
        try self.html.elVoid("input", .{ .class = cls, .type = "range" });
    }

    // ── Feedback ──

    /// `<progress class="progress progress-COLOR w-56" value="..." max="100">`
    pub fn progress(self: DaisyWidget, value: u32, color: DuColor) !Closer {
        var class_buf: [32]u8 = undefined;
        const cls = std.fmt.bufPrint(&class_buf, "progress progress-{s} w-56", .{colorClass(color)}) catch "progress";
        return self.html.el("progress", .{ .class = cls, .value = value, .max = 100 });
    }

    /// `<span class="loading loading-SIZE loading-COLOR">`
    pub fn loading(self: DaisyWidget, size: DuSize, color: ?DuColor) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = if (color) |c| std.fmt.bufPrint(&class_buf, "loading loading-{s} loading-{s}", .{ @tagName(size), @tagName(c) }) catch "loading" else std.fmt.bufPrint(&class_buf, "loading loading-{s}", .{@tagName(size)}) catch "loading";
        return self.html.el("span", .{ .class = cls });
    }

    /// `<div class="skeleton h-4 w-full">`
    pub fn skeleton(self: DaisyWidget) !Closer {
        return self.html.el("div", .{ .class = "skeleton h-4 w-full" });
    }

    /// `<div class="tooltip" data-tip="...">`
    pub fn tooltip(self: DaisyWidget, tip: []const u8) !Closer {
        return self.html.el("div", .{ .class = "tooltip", .data_tip = tip });
    }

    /// `<div class="mockup-code"><pre><code>...</code></pre></div>`
    pub fn mockupCode(self: DaisyWidget) !Closer {
        return self.html.el("div", .{ .class = "mockup-code" });
    }

    /// `<div class="stats shadow">`
    pub fn stats(self: DaisyWidget) !Closer {
        return self.html.el("div", .{ .class = "stats shadow" });
    }
    pub fn stat(self: DaisyWidget, title: []const u8, value: []const u8, desc: []const u8) !Closer {
        const c = try self.html.el("div", .{ .class = "stat" });
        {
            const t = try self.html.el("div", .{ .class = "stat-title" });
            defer t.close();
            try self.html.writer.writeAll(title);
        }
        {
            const v = try self.html.el("div", .{ .class = "stat-value" });
            defer v.close();
            try self.html.writer.writeAll(value);
        }
        {
            const d = try self.html.el("div", .{ .class = "stat-desc" });
            defer d.close();
            try self.html.writer.writeAll(desc);
        }
        return c;
    }

    /// `<div class="collapse bg-base-200"><input type="checkbox"/><div class="collapse-title">title</div><div class="collapse-content">content</div></div>`
    pub fn collapse(self: DaisyWidget, title: []const u8, content: []const u8) !Closer {
        const c = try self.html.el("div", .{ .class = "collapse bg-base-200" });
        try self.html.elVoid("input", .{ .type = "checkbox" });
        const t = try self.html.el("div", .{ .class = "collapse-title text-xl font-medium" });
        defer t.close();
        try self.html.writer.writeAll(title);
        const ct = try self.html.el("div", .{ .class = "collapse-content" });
        defer ct.close();
        try self.html.writer.writeAll(content);
        return c;
    }

    /// `<div class="table-container"><table class="table"><thead>...</thead><tbody>...</tbody></table></div>`
    pub fn table(self: DaisyWidget) !Closer {
        return self.html.el("table", .{ .class = "table" });
    }
};

// ── NES.css ──

pub const NesVariant = enum { primary, success, warning, err, pattern };

pub fn NesCSS(writer: *Io.Writer) NesWidget {
    return .{ .html = Html(writer) };
}

pub const NesWidget = struct {
    html: HtmlWidget,

    /// `<button class="nes-btn is-VARIANT">txt</button>`
    pub fn button(self: NesWidget, txt: []const u8, variant: ?NesVariant) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = if (variant) |v| blk: {
            if (v == .pattern) break :blk "nes-btn is-pattern";
            break :blk std.fmt.bufPrint(&class_buf, "nes-btn is-{s}", .{@tagName(v)}) catch "nes-btn";
        } else "nes-btn";
        const c = try self.html.el("button", .{ .class = cls });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<div class="nes-container with-title">`
    pub fn container(self: NesWidget) !Closer {
        return self.html.el("div", .{ .class = "nes-container with-title" });
    }

    /// `<h3 class="title">`
    pub fn containerTitle(self: NesWidget, txt: []const u8) !Closer {
        const c = try self.html.el("h3", .{ .class = "title" });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<span class="nes-badge"><span class="is-VARIANT">txt</span></span>`
    pub fn badge(self: NesWidget, txt: []const u8, variant: NesVariant) !Closer {
        var class_buf: [32]u8 = undefined;
        const cls = std.fmt.bufPrint(&class_buf, "is-{s}", .{@tagName(variant)}) catch "is-primary";
        const c = try self.html.el("span", .{ .class = "nes-badge" });
        {
            const inner = try self.html.el("span", .{ .class = cls });
            defer inner.close();
            try self.html.writer.writeAll(txt);
        }
        return c;
    }

    /// `<progress class="nes-progress is-VARIANT" value="..." max="100">`
    pub fn progress(self: NesWidget, value: u32, variant: ?NesVariant) !Closer {
        var class_buf: [48]u8 = undefined;
        const cls = if (variant) |v| std.fmt.bufPrint(&class_buf, "nes-progress is-{s}", .{@tagName(v)}) catch "nes-progress" else "nes-progress";
        return self.html.el("progress", .{ .class = cls, .value = value, .max = 100 });
    }

    /// `<input class="nes-input" type="...">`
    pub fn input(self: NesWidget, comptime input_type: []const u8, placeholder: []const u8) !void {
        try self.html.elVoid("input", .{ .class = "nes-input", .type = input_type, .placeholder = placeholder });
    }

    /// `<textarea class="nes-textarea">`
    pub fn textarea(self: NesWidget, placeholder: []const u8) !Closer {
        return self.html.el("textarea", .{ .class = "nes-textarea", .placeholder = placeholder });
    }

    /// `<select class="nes-select">`
    pub fn select(self: NesWidget) !Closer {
        return self.html.el("select", .{});
    }

    /// `<label><input type="checkbox" class="nes-checkbox">txt</label>`
    pub fn checkbox(self: NesWidget, txt: []const u8) !Closer {
        const c = try self.html.el("label", .{});
        try self.html.elVoid("input", .{ .class = "nes-checkbox", .type = "checkbox" });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<label><input type="radio" class="nes-radio" name="...">txt</label>`
    pub fn radio(self: NesWidget, txt: []const u8, name: []const u8) !Closer {
        const c = try self.html.el("label", .{});
        try self.html.elVoid("input", .{ .class = "nes-radio", .type = "radio", .name = name });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<table class="nes-table is-bordered">`
    pub fn table(self: NesWidget) !Closer {
        return self.html.el("table", .{ .class = "nes-table is-bordered" });
    }

    /// `<ul class="nes-list is-disc">`
    pub fn list(self: NesWidget) !Closer {
        return self.html.el("ul", .{ .class = "nes-list is-disc" });
    }

    /// `<section class="nes-balloon from-left"><p>txt</p></section>`
    pub fn balloon(self: NesWidget, txt: []const u8) !Closer {
        const c = try self.html.el("section", .{ .class = "nes-balloon from-left" });
        const p = try self.html.el("p", .{});
        defer p.close();
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<i class="nes-icon heart">`
    pub fn icon(self: NesWidget, comptime name: []const u8) !void {
        var class_buf: [32]u8 = undefined;
        const cls = std.fmt.bufPrint(&class_buf, "nes-icon {s}", .{name}) catch "nes-icon";
        try self.html.elVoid("i", .{ .class = cls });
    }
};

// ── 98.css ──

pub fn Win98CSS(writer: *Io.Writer) Win98Widget {
    return .{ .html = Html(writer) };
}

pub const Win98Widget = struct {
    html: HtmlWidget,

    /// `<div class="window"><div class="title-bar"><div class="title-bar-text">title</div></div><div class="window-body">`
    pub fn window(self: Win98Widget, title: []const u8) !Closer {
        const c = try self.html.el("div", .{ .class = "window" });
        _ = c; // autofix
        _ = c; // autofix
        {
            const tb = try self.html.el("div", .{ .class = "title-bar" });
            defer tb.close();
            const tt = try self.html.el("div", .{ .class = "title-bar-text" });
            defer tt.close();
            try self.html.writer.writeAll(title);
        }
        return self.html.el("div", .{ .class = "window-body" });
    }

    /// `<button>txt</button>`
    pub fn button(self: Win98Widget, txt: []const u8) !Closer {
        const c = try self.html.el("button", .{});
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<fieldset><legend>title</legend>`
    pub fn fieldset(self: Win98Widget, legend: []const u8) !Closer {
        const c = try self.html.el("fieldset", .{});
        const l = try self.html.el("legend", .{});
        defer l.close();
        try self.html.writer.writeAll(legend);
        return c;
    }

    /// `<div class="field-row"><label>label</label><input type="text"></div>`
    pub fn fieldRow(self: Win98Widget, label: []const u8) !Closer {
        const c = try self.html.el("div", .{ .class = "field-row" });
        const l = try self.html.el("label", .{});
        defer l.close();
        try self.html.writer.writeAll(label);
        try self.html.elVoid("input", .{ .type = "text" });
        return c;
    }

    /// `<select><option>...</option></select>`
    pub fn dropdown(self: Win98Widget) !Closer {
        return self.html.el("select", .{});
    }

    /// `<input type="checkbox" id="..."><label for="...">txt</label>`
    pub fn checkbox(self: Win98Widget, id: []const u8, txt: []const u8) !void {
        try self.html.elVoid("input", .{ .type = "checkbox", .id = id });
        const l = try self.html.el("label", .{ .@"for" = id });
        defer l.close();
        try self.html.writer.writeAll(txt);
    }

    /// `<input type="radio" id="..." name="..."><label for="...">txt</label>`
    pub fn radio(self: Win98Widget, id: []const u8, name: []const u8, txt: []const u8) !void {
        try self.html.elVoid("input", .{ .type = "radio", .id = id, .name = name });
        const l = try self.html.el("label", .{ .@"for" = id });
        defer l.close();
        try self.html.writer.writeAll(txt);
    }

    /// `<input type="range">`
    pub fn slider(self: Win98Widget) !void {
        try self.html.elVoid("input", .{ .type = "range" });
    }

    /// `<div class="status-bar"><p class="status-bar-field">txt</p></div>`
    pub fn statusBar(self: Win98Widget, txt: []const u8) !Closer {
        const c = try self.html.el("div", .{ .class = "status-bar" });
        const p = try self.html.el("p", .{ .class = "status-bar-field" });
        defer p.close();
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<ul class="tree-view">`
    pub fn treeView(self: Win98Widget) !Closer {
        return self.html.el("ul", .{ .class = "tree-view" });
    }

    /// `<progress value="..." max="100">`
    pub fn progress(self: Win98Widget, value: u32) !Closer {
        return self.html.el("progress", .{ .value = value, .max = 100 });
    }
};

// ── System.css ──

pub fn SystemCSS(writer: *Io.Writer) SystemWidget {
    return .{ .html = Html(writer) };
}

pub const SystemWidget = struct {
    html: HtmlWidget,

    /// `<div class="window"><div class="title-bar"><span>title</span></div><div class="window-pane">`
    pub fn window(self: SystemWidget, title: []const u8) !Closer {
        const c = try self.html.el("div", .{ .class = "window" });
        {
            const tb = try self.html.el("div", .{ .class = "title-bar" });
            defer tb.close();
            const sp = try self.html.el("span", .{ .class = "title" });
            defer sp.close();
            try self.html.writer.writeAll(title);
        }
        const pane = try self.html.el("div", .{ .class = "window-pane" });
        _ = c;
        return pane;
    }

    /// `<div class="standard-dialog"><p>txt</p></div>`
    pub fn dialog(self: SystemWidget, txt: []const u8) !Closer {
        const c = try self.html.el("div", .{ .class = "standard-dialog center" });
        {
            const p = try self.html.el("p", .{ .class = "dialog-text" });
            defer p.close();
            try self.html.writer.writeAll(txt);
        }
        return c;
    }

    /// `<button class="btn">txt</button>`
    pub fn button(self: SystemWidget, txt: []const u8) !Closer {
        const c = try self.html.el("button", .{ .class = "btn" });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<div class="field-row"><input type="text"></div>`
    pub fn input(self: SystemWidget) !void {
        try self.html.elVoid("div", .{ .class = "field-row" });
        try self.html.elVoid("input", .{ .type = "text" });
    }

    /// `<fieldset><legend>title</legend>`
    pub fn fieldset(self: SystemWidget, legend: []const u8) !Closer {
        const c = try self.html.el("fieldset", .{});
        const l = try self.html.el("legend", .{});
        defer l.close();
        try self.html.writer.writeAll(legend);
        return c;
    }

    /// `<select>`
    pub fn select(self: SystemWidget) !Closer {
        return self.html.el("select", .{});
    }

    /// `<label class="checkbox"><input type="checkbox">txt</label>`
    pub fn checkbox(self: SystemWidget, txt: []const u8) !Closer {
        const c = try self.html.el("label", .{ .class = "checkbox" });
        try self.html.elVoid("input", .{ .type = "checkbox" });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<label class="radio"><input type="radio" name="...">txt</label>`
    pub fn radio(self: SystemWidget, txt: []const u8, name: []const u8) !Closer {
        const c = try self.html.el("label", .{ .class = "radio" });
        try self.html.elVoid("input", .{ .type = "radio", .name = name });
        try self.html.writer.writeAll(txt);
        return c;
    }

    /// `<progress value="..." max="100">`
    pub fn progress(self: SystemWidget, value: u32) !Closer {
        return self.html.el("progress", .{ .value = value, .max = 100 });
    }
};

// ── Orbit ──

pub fn OrbitCSS(writer: *Io.Writer) OrbitWidget {
    return .{ .html = Html(writer) };
}

pub const OrbitWidget = struct {
    html: HtmlWidget,

    pub fn bigbang(self: OrbitWidget, theme: ?[]const u8) !Closer {
        var class_buf: [64]u8 = undefined;
        const cls = if (theme) |t| std.fmt.bufPrint(&class_buf, "bigbang {s}", .{t}) catch "bigbang" else "bigbang";
        return self.html.el("div", .{ .class = cls });
    }

    pub fn gravitySpot(self: OrbitWidget) !Closer {
        return self.html.el("div", .{ .class = "gravity-spot" });
    }

    pub fn orbit(self: OrbitWidget, comptime level: u8, range_deg: u32) !Closer {
        var class_buf: [48]u8 = undefined;
        const cls = std.fmt.bufPrint(&class_buf, "orbit-{d} range-{d}", .{ level, range_deg }) catch "orbit-1";
        return self.html.el("div", .{ .class = cls });
    }

    pub fn progress(self: OrbitWidget, value: u32) !Closer {
        return self.html.el("o-progress", .{ .value = value });
    }

    pub fn arc(self: OrbitWidget, value: u32, shape: ?[]const u8) !Closer {
        if (shape) |s| return self.html.el("o-arc", .{ .value = value, .shape = s });
        return self.html.el("o-arc", .{ .value = value });
    }

    pub fn satellite(self: OrbitWidget) !Closer {
        return self.html.el("div", .{ .class = "satellite" });
    }

    pub fn capsule(self: OrbitWidget) !Closer {
        return self.html.el("div", .{ .class = "capsule" });
    }
};

pub const ModalCloser = struct {
    writer: *Io.Writer,

    pub fn close(self: ModalCloser) void {
        self.writer.writeAll("</article>\n</dialog>\n") catch {};
    }
};
