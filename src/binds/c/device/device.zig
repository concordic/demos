const vk = @import("../vulkan.zig");
const types = @import("../types.zig");
const queue = @import("../queue/queue.zig");
const physical_device = @import("physical_device.zig");
const instance = @import("../instance/instance.zig");
const std = @import("std");

const deviceInitResult = extern struct {
    result: vk.VkResult,
    device: vk.VkDevice,
};
extern fn deviceInit(*vk.VkPhysicalDevice, [*c]vk.VkDeviceQueueCreateInfo, c_int, [*c]const [*c]const u8, c_int, [*c]const [*c]const u8, c_int) deviceInitResult;
extern fn deviceDeinit(*deviceInitResult) void;

pub const errors = error{
    deviceCreationFailed
};

fn rank_func(_: vk.VkPhysicalDevice) i32 {
    return 0;
}

pub const device = struct {
    dev: vk.VkDevice,
    physical_device: physical_device.physical_device,
    queues: queue.queue,
    result: deviceInitResult,

    pub fn init(alloc: std.mem.Allocator, inst: *instance.instance, features: []queue.FeatureCallback, extensions: [][]const u8, validation_layers: [][]const u8) !device {
        var dev: device = undefined;
        try dev._init(alloc, inst, features,extensions, validation_layers);
        return dev;
    }

    fn _init(self: *device, alloc: std.mem.Allocator, inst: *instance.instance, features: []queue.FeatureCallback, extensions: [][]const u8, validation_layers: [][]const u8) !void {
        var z_extensions = try types.CStrArray.init(alloc, extensions);
        defer z_extensions.deinit();
        var z_validations = try types.CStrArray.init(alloc, validation_layers);
        defer z_validations.deinit();

        self.physical_device = physical_device.physical_device.init(inst, physical_device.wrap(&rank_func));
        self.queues = try queue.queue.init(self, features);
        const result = deviceInit(&self.physical_device.physical_device,  
            self.queues.create_info.ptr, @intCast(self.queues.create_info.len), 
            z_extensions.ptr, @intCast(z_extensions.len), 
            z_validations.ptr, @intCast(z_validations.len)
        );
        if (result.result != vk.VK_SUCCESS) {
            return errors.deviceCreationFailed;
        }
        self.dev = result.device;
        self.result = result;
        try self.queues.get(self);
    }

    pub fn deinit(d: *device) void {
        deviceDeinit(&d.result);
        d.queues.deinit();
        d.physical_device.deinit();
    }
};
