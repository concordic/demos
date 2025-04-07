const vk = @import("../vulkan.zig");
const device = @import("../device/device.zig");
const instance = @import("../instance/instance.zig");
const std = @import("std");


pub const FeatureCallback = extern struct {
    callback: *const fn (vk.VkPhysicalDevice, [*c]vk.VkQueueFamilyProperties, c_int, c_int, *anyopaque) callconv(.c) bool,
    args: *anyopaque
};
const queueCreatesInitResult = extern struct {
    create_infos: [*c]vk.VkDeviceQueueCreateInfo,
    priorities: [*c]f32,
    indices: [*c]u32,
    info_map: [*c]u32,
    len: u32,
};
const queueDeviceInitResult = extern struct {
    queues: [*c]vk.VkQueue,
    len: u32,
};
extern fn queueCreatesInit(*const vk.VkPhysicalDevice, [*c]FeatureCallback, c_int) queueCreatesInitResult;
extern fn queueDeviceInit(*const vk.VkDevice, *const queueCreatesInitResult) queueDeviceInitResult;
extern fn queueDeinit(*const queueCreatesInitResult, *const queueDeviceInitResult) void;


pub fn wrap(comptime func: *const fn (vk.VkPhysicalDevice, []vk.VkQueueFamilyProperties, u32, *anyopaque) bool, args: *anyopaque) FeatureCallback {
    var callback: FeatureCallback = undefined;
    callback.args = args;
    callback.callback = struct {
        pub fn inner(physdev: vk.VkPhysicalDevice, props: [*c]vk.VkQueueFamilyProperties, num_props: c_int, idx: c_int, data: *anyopaque) callconv(.c) bool {
            var arr: []vk.VkQueueFamilyProperties = undefined;
            arr.ptr = props;
            arr.len = @intCast(num_props);
            return func(physdev, arr, @intCast(idx), data);
}
    }.inner;
    return callback;
}

pub const queue = struct {
    queues: []vk.VkQueue,
    create_info: []vk.VkDeviceQueueCreateInfo,
    indicies: []u32,
    info_map: []u32, // the nth element of this array tells you which index of queues and create_info that family is
    init_result: queueCreatesInitResult,
    get_result: queueDeviceInitResult,

    pub fn init(dev: *device.device, check_features: []FeatureCallback) !queue {
        var q: queue = undefined;
        try q._pre_dev_init(dev.physical_device.physical_device,  check_features);
        return q;
    }

    fn _pre_dev_init(q: *queue, physdev: vk.VkPhysicalDevice, check_features: []FeatureCallback) !void {
        const result = queueCreatesInit(&physdev, check_features.ptr, @intCast(check_features.len));
        q.create_info.ptr = result.create_infos;
        q.create_info.len = result.len;
        q.indicies.ptr = result.indices;
        q.indicies.len = check_features.len;
        q.info_map.ptr = result.info_map;
        q.info_map.len = check_features.len;
        q.init_result = result;
    }
    
    pub fn get(q: *queue, dev: *device.device) !void {
        const result = queueDeviceInit(&dev.dev, &q.init_result);
        q.queues.ptr = result.queues;
        q.queues.len = result.len;
        q.get_result = result;
    }

    pub fn deinit(q: *queue) void {
        queueDeinit(&q.init_result, &q.get_result);
    }
};
