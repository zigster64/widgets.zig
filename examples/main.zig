const std = @import("std");
const Io = std.Io;

const index_demo = @import("index_demo.zig");
const pico = @import("pico.zig");
const daisy = @import("daisy.zig");
const jelly = @import("jelly.zig");
const snes = @import("snes.zig");
const nes = @import("nes.zig");
const win98 = @import("win98.zig");
const system = @import("system.zig");
const orbit = @import("orbit.zig");
const tui = @import("tui.zig");
const atari = @import("atari.zig");
const handdrawn = @import("handdrawn.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    try index_demo.indexHtml(io);
    try index_demo.indexGen(io);
    try pico.picoPage(io);
    try jelly.jellyPage(io);
    try snes.snesPage(io);
    try daisy.daisyPage(io);
    try nes.nesPage(io);
    try win98.win98Page(io);
    try system.systemPage(io);
    try orbit.orbitPage(io);
    try tui.tuiPage(io);
    try atari.atariPage(io);
    try handdrawn.handdrawnPage(io);
    try doodle.doodlePage(io);
}
