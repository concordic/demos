const glfw = @import("../glfw.zig");
const vk = @import("../vulkan.zig");
const std = @import("std");

extern fn instanceInit(*vk.VkInstance, [*c]const u8, c_int, c_int, c_int, [*c]const [*c]const u8, c_int, c_int, [*c]const [*c]const u8, c_int) vk.VkResult;
extern fn instanceDeinit(vk.VkInstance) void;

pub const errors = error{
    instanceCreationFailed
};

pub const instance = struct {
    inst: vk.VkInstance,

    pub fn init(i: *instance, alloc: std.mem.Allocator, 
            app_name: []const u8, version: [3]u32, 
            required_extensions: [][]const u8, flags: i32,
            validation_layers: [][]const u8) !void {
        const z_app_name = try std.fmt.allocPrintZ(alloc, "{s}", .{app_name});
        var z_extensions = try alloc.alloc([*]u8, required_extensions.len);
        for (required_extensions, 0..) |extension, idx| {
            const name = try std.fmt.allocPrintZ(alloc, "{s}", .{extension});
            z_extensions[idx] = name.ptr;
        }
        var z_validations = try alloc.alloc([*]u8, validation_layers.len);
        for (validation_layers, 0..) |layer, idx| {
            const name = try std.fmt.allocPrintZ(alloc, "{s}", .{layer});
            z_validations[idx] = name.ptr;
        }
        const result = instanceInit(&i.inst, 
            z_app_name.ptr, @intCast(version[0]), @intCast(version[1]), @intCast(version[2]), 
            z_extensions.ptr, @intCast(z_extensions.len), flags,
            z_validations.ptr, @intCast(z_validations.len));
        alloc.free(z_extensions);
        if (result != vk.VK_SUCCESS) {
            return errors.instanceCreationFailed;
        }
    }

    pub fn deinit(i: *instance) void {
        instanceDeinit(i.inst);
    }
};
