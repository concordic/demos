const vk = @import("../vulkan.zig");


const commandbufferInitResult = extern struct {
    result: vk.VkResult,
    commandbuffer: vk.VkCommandBuffer,
};
const commandbufferRecordResult = extern struct {
    result: vk.VkResult
};
extern fn commandbufferInit(vk.VkDevice, vk.VkCommandPool) commandbufferInitResult;
extern fn commandbufferRecord(vk.VkCommandBuffer, vk.VkFramebuffer, vk.VkRenderPass, vk.VkPipeline, vk.VkExtent2D) commandbufferRecordResult;


pub const errors = error {
    commandbufferInitializationFailed,
    commandbufferRecordFailed,
};


pub const commandbuffer = struct {
    cb: vk.VkCommandBuffer,
    cp: vk.VkCommandPool,
    device: vk.VkDevice,
    fbs: []vk.VkFramebuffer,
    rpass: vk.VkRenderPass,
    pipeline: vk.VkPipeline,
    extent: vk.VkExtent2D,

    pub fn init(commandpool: vk.VkCommandPool, dev: vk.VkDevice, fbs: []vk.VkFramebuffer, rpass: vk.VkRenderPass, pipeline: vk.VkPipeline, extent: vk.VkExtent2D) !commandbuffer {
        var cb: commandbuffer = undefined;
        try cb._init(commandpool, dev, fbs, rpass, pipeline, extent);
        return cb;
    }

    fn _init(self: *commandbuffer, commandpool: vk.VkCommandPool, dev: vk.VkDevice, fbs: []vk.VkFramebuffer, rpass: vk.VkRenderPass, pipeline: vk.VkPipeline, extent: vk.VkExtent2D) !void {
        const result = commandbufferInit(dev, commandpool);
        if (result.result != vk.VK_SUCCESS) return errors.commandbufferInitializationFailed;
        self.cb = result.commandbuffer;
        self.cp = commandpool;
        self.device = dev;
        self.fbs = fbs;
        self.rpass = rpass;
        self.pipeline = pipeline;
        self.extent = extent;
    }

    pub fn record(self: *commandbuffer, img_idx: u32) !void {
        const result = commandbufferRecord(self.cb, self.fbs[img_idx], self.rpass, self.pipeline, self.extent);
        if (result.result != vk.VK_SUCCESS) return errors.commandbufferRecordFailed;
    }

    pub fn deinit(_: *commandbuffer) void {
        return;
    }
};
