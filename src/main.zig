const std = @import("std");
const window = @import("binds/window.zig");

fn nothing() bool {
    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var win: window.window = undefined;
    try win.init(allocator, 800, 600, "Vulkan");
    defer win.deinit();
    win.update(window.wrap(&nothing));
}
