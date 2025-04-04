const std = @import("std");
const window = @import("binds/window.zig");
const instance = @import("binds/instance.zig");
const device = @import("binds/device.zig");
const vulkan = @import("binds/c/vulkan.zig");

fn update() bool {
    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    
    // creation configuration
    var extensions: [2][]const u8 = .{
        vulkan.VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME,
        vulkan.VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME,
    };
    var validations: [1][]const u8 = .{
        "VK_LAYER_KHRONOS_validation"
    };
    var dev_extensions: [1][]const u8 = .{
        "VK_KHR_portability_subset",
    };
    var features: [1]i32 = .{
        vulkan.VK_QUEUE_GRAPHICS_BIT,
    };
    const instance_flags = vulkan.VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;

    // create instance and defer free
    var inst: instance.instance = undefined;
    try inst.init(allocator, 
        "Hello World", .{1, 0, 0}, 
        extensions[0..], instance_flags,
        validations[0..]
    );
    defer inst.deinit();

    // create logical device and defer free
    var dev: device.device = undefined;
    try dev.init(allocator, inst.inst, 
        features[0..], 
        dev_extensions[0..], 
        validations[0..]
    );
    defer dev.deinit();
    
    // create window and defer free
    var win: window.window = undefined;
    try win.init(allocator, 800, 600, "Vulkan");
    defer win.deinit();

    // start window update loop
    win.update(window.wrap(&update));
}
