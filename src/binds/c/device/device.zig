const vk = @import("../vulkan.zig");
const std = @import("std");


extern fn deviceInit(*vk.VkDevice, [*c]vk.VkQueue, vk.VkInstance, [*c]c_int, c_int, [*c]const [*c]const u8, c_int, [*c]const [*c]const u8, c_int) vk.VkResult;
extern fn deviceDeinit(vk.VkDevice) void;

pub const errors = error{
    deviceCreationFailed
};

pub const device = struct {
    dev: vk.VkDevice,
    queue: []vk.VkQueue,

    pub fn init(d: *device, alloc: std.mem.Allocator, inst: vk.VkInstance, features: []i32, extensions: [][]const u8, validation_layers: [][]const u8) !void {
        var z_extensions = try alloc.alloc([*]u8, extensions.len);
        for (extensions, 0..) |extension, idx| {
            const name = try std.fmt.allocPrintZ(alloc, "{s}", .{extension});
            z_extensions[idx] = name.ptr;
        }
        d.queue = try alloc.alloc(vk.VkQueue, features.len);
        var z_validations = try alloc.alloc([*]u8, validation_layers.len);
        for (validation_layers, 0..) |layer, idx| {
            const name = try std.fmt.allocPrintZ(alloc, "{s}", .{layer});
            z_validations[idx] = name.ptr;
        }
        const result = deviceInit(&d.dev, d.queue.ptr, inst, 
            features.ptr, @intCast(features.len), 
            z_extensions.ptr, @intCast(z_extensions.len), 
            z_validations.ptr, @intCast(z_validations.len)
        );
        if (result != vk.VK_SUCCESS) {
            return errors.deviceCreationFailed;
        }
    }

    pub fn deinit(d: *device) void {
        deviceDeinit(d.dev);
    }
};
