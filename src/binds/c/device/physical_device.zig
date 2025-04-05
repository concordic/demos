const vk = @import("../vulkan.zig");
const inst = @import("../instance/instance.zig");


const physdevInitResult = extern struct {
    physical_device: vk.VkPhysicalDevice
};
extern fn physdevInit(*const vk.VkInstance, *const fn (vk.VkPhysicalDevice) callconv(.c) c_int) physdevInitResult;


pub const RankCallback = *const fn (vk.VkPhysicalDevice) callconv(.c) c_int;


pub fn wrap(comptime func: *const fn (vk.VkPhysicalDevice) i32) RankCallback {
    return struct {
        pub fn inner(physdev: vk.VkPhysicalDevice) callconv(.c) c_int {
            return func(physdev);
        }
    }.inner;
}


pub const physical_device = struct {
    physical_device: vk.VkPhysicalDevice,
    result: physdevInitResult,

    pub fn init(instance: *inst.instance, rank_func: RankCallback) physical_device {
        var physdev: physical_device = undefined;
        physdev._init(instance.inst, rank_func);
        return physdev;
    }

    fn _init(self: *physical_device, instance: vk.VkInstance, rank_func: RankCallback) void {
        const result = physdevInit(&instance, rank_func);
        self.physical_device = result.physical_device;
        self.result = result;
    }
    
    pub fn deinit(_: *physical_device) void {
        return;
    }
};
