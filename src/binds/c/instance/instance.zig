const glfw = @import("../glfw.zig");
const vk = @import("../vulkan.zig");

extern fn instanceInit(instance: *vk.VkInstance) vk.VkResult;
extern fn instanceDeinit(instance: vk.VkInstance) void;

pub const errors = error{
    instanceCreationFailed
};

pub const instance = struct {
    inst: vk.VkInstance,

    pub fn init(i: *instance) !void {
        const result = instanceInit(&i.inst);
        if (result != vk.VK_SUCCESS) {
            return errors.instanceCreationFailed;
        }
    }

    pub fn deinit(i: *instance) void {
        instanceDeinit(i.inst);
    }
};
