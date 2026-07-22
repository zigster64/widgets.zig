const std = @import("std");
const Io = std.Io;
const root = @import("root.zig");

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
pub const ModalCloser = struct {
    writer: *Io.Writer,

    pub fn close(self: ModalCloser) void {
        self.writer.writeAll("</article>\n</dialog>\n") catch {};
    }
};
