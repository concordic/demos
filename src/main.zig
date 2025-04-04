const std = @import("std");
const window = @import("binds/window.zig");
const instance = @import("binds/instance.zig");
const vulkan = @import("binds/c/vulkan.zig");

fn update() bool {
    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var win: window.window = undefined;
    var inst: instance.instance = undefined;
    var extensions: [1][]const u8 = .{
        vulkan.VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME
    };
    var validations: [1][]const u8 = .{
        "VK_LAYER_KHRONOS_validation"
    };

    try inst.init(allocator, 
        "Hello World", .{1, 0, 0}, 
        extensions[0..], vulkan.VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR,
        validations[0..]
    );
    defer inst.deinit();
    try win.init(allocator, 800, 600, "Vulkan");
    defer win.deinit();
    win.update(window.wrap(&update));
}
