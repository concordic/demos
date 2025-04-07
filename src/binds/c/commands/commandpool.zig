const vk = @import("../vulkan.zig");


const commandpoolInitResult = extern struct {
    result: vk.VkResult,
    commandpool: vk.VkCommandPool,
};
extern fn commandpoolInit(vk.VkDevice, u32) commandpoolInitResult;
extern fn commandpoolDeinit(vk.VkDevice, commandpoolInitResult) void;


pub const errors = error{
    commandpoolInitializationFailed
};


pub const commandpool = struct {
    commandpool: vk.VkCommandPool,
    result: commandpoolInitResult,
    device: vk.VkDevice,

    pub fn init(dev: vk.VkDevice, graphics_index: u32) !commandpool {
        var cp: commandpool = undefined;
        try cp._init(dev, graphics_index);
        return cp;
    }

    fn _init(self: *commandpool, dev: vk.VkDevice, graphics_index: u32) !void {
        const result = commandpoolInit(dev, graphics_index);
        if (result.result != vk.VK_SUCCESS) {
            return errors.commandpoolInitializationFailed;
        }
        self.commandpool = result.commandpool;
        self.result = result;
        self.device = dev;
    }

    pub fn deinit(self: *commandpool) void {
        commandpoolDeinit(self.device, self.result);
    }
};
