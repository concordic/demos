const vk = @import("../vulkan.zig");
const std = @import("std");


pub const CheckFeaturePointer = *const fn (vk.VkPhysicalDevice, [*c]vk.VkQueueFamilyProperties, c_int, c_int) callconv(.c) bool;
extern fn queueCreatesInit(vk.VkPhysicalDevice, vk.VkInstance, [*c]CheckFeaturePointer, c_int, [*c]c_int) [*c]vk.VkDeviceQueueCreateInfo;
extern fn queueDeviceInit([*c]vk.VkQueue, vk.VkDevice, [*c]vk.VkDeviceQueueCreateInfo, c_int) void;




pub fn wrap(comptime func: *const fn (vk.VkPhysicalDevice, []vk.VkQueueFamilyProperties, u32) bool) CheckFeaturePointer {
    return struct {
        pub fn inner(physdev: vk.VkPhysicalDevice, props: [*c]vk.VkQueueFamilyProperties, num_props: c_int, idx: c_int) callconv(.c) bool {
            var arr: []vk.VkQueueFamilyProperties = undefined;
            arr.ptr = props;
            arr.len = @intCast(num_props);
            return func(physdev, arr, @intCast(idx));
        }
    }.inner;
}


pub const queue = struct {
    queues: []vk.VkQueue,
    create_info: []vk.VkDeviceQueueCreateInfo,

    pub fn init(physdev: vk.VkPhysicalDevice, inst: vk.VkInstance, check_features: []CheckFeaturePointer) !queue {
        var q: queue = undefined;
        try q._pre_dev_init(physdev, inst, check_features);
        return q;
    }

    fn _pre_dev_init(q: *queue, physdev: vk.VkPhysicalDevice, inst: vk.VkInstance, check_features: []CheckFeaturePointer) !void {
        var len: i32 = undefined;
        q.create_info.ptr = queueCreatesInit(physdev, inst, check_features.ptr, @intCast(check_features.len), &len);
        q.create_info.len = @intCast(len);
    }
    
    pub fn get(q: *queue, alloc: std.mem.Allocator, device: vk.VkDevice) !void {
        q.queues = try alloc.alloc(vk.VkQueue, q.create_info.len);
        queueDeviceInit(q.queues.ptr, device, q.create_info.ptr, @intCast(q.create_info.len));
    }
};
