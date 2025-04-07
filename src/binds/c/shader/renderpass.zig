const vk = @import("../vulkan.zig");


const renderpassInitResult = extern struct {
    result: vk.VkResult,
    renderpass: vk.VkRenderPass,
};
extern fn renderpassInit(vk.VkDevice, vk.VkFormat) renderpassInitResult;
extern fn renderpassDeinit(vk.VkDevice, vk.VkRenderPass) void;


pub const errors = error {
    renderpassInitializationFailed
};


pub const renderpass = struct {
    renderpass: vk.VkRenderPass,
    device: vk.VkDevice,

    pub fn init(dev: vk.VkDevice, format: vk.VkFormat) !renderpass {
        var rp: renderpass = undefined;
        try rp._init(dev, format);
        return rp;
    }
   
    fn _init(self: *renderpass, dev: vk.VkDevice, format: vk.VkFormat) !void {
        const result = renderpassInit(dev, format);
        if (result.result != vk.VK_SUCCESS) {
            return errors.renderpassInitializationFailed;
        }
        self.device = dev;
        self.renderpass = result.renderpass;
    }
    
    pub fn deinit(self: *renderpass) void {
        renderpassDeinit(self.device, self.renderpass);
    }
};
