const vk = @import("../vulkan.zig");
const queue = @import("../queue/queue.zig");
const instance = @import("../instance/instance.zig");
const std = @import("std");


extern fn devicePhysInit(vk.VkInstance) vk.VkPhysicalDevice;
extern fn deviceInit(*vk.VkDevice, vk.VkPhysicalDevice, vk.VkInstance, [*c]vk.VkDeviceQueueCreateInfo, c_int, [*c]const [*c]const u8, c_int, [*c]const [*c]const u8, c_int) vk.VkResult;
extern fn deviceDeinit(vk.VkDevice) void;

pub const errors = error{
    deviceCreationFailed
};

pub const device = struct {
    dev: vk.VkDevice,
    phys_dev: vk.VkPhysicalDevice,
    queues: queue.queue,

    pub fn init(alloc: std.mem.Allocator, inst: *instance.instance, features: []queue.CheckFeaturePointer, datas: []*anyopaque, extensions: [][]const u8, validation_layers: [][]const u8) !device {
        var dev: device = undefined;
        try dev._init(alloc, inst, features, datas, extensions, validation_layers);
        return dev;
    }

    fn _init(d: *device, alloc: std.mem.Allocator, inst: *instance.instance, features: []queue.CheckFeaturePointer, datas: []*anyopaque, extensions: [][]const u8, validation_layers: [][]const u8) !void {
        var z_extensions = try alloc.alloc([*]u8, extensions.len);
        for (extensions, 0..) |extension, idx| {
            const name = try std.fmt.allocPrintZ(alloc, "{s}", .{extension});
            z_extensions[idx] = name.ptr;
        }
        var z_validations = try alloc.alloc([*]u8, validation_layers.len);
        for (validation_layers, 0..) |layer, idx| {
            const name = try std.fmt.allocPrintZ(alloc, "{s}", .{layer});
            z_validations[idx] = name.ptr;
        }
        d.phys_dev = devicePhysInit(inst.inst);
        d.queues = try queue.queue.init(d, inst, features, datas);
        const result = deviceInit(&d.dev, d.phys_dev, inst.inst, 
            d.queues.create_info.ptr, @intCast(d.queues.create_info.len), 
            z_extensions.ptr, @intCast(z_extensions.len), 
            z_validations.ptr, @intCast(z_validations.len)
        );
        if (result != vk.VK_SUCCESS) {
            return errors.deviceCreationFailed;
        }
        try d.queues.get(alloc, d);
    }

    pub fn deinit(d: *device) void {
        deviceDeinit(d.dev);
    }
};
