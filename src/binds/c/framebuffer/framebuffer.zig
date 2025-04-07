const vk = @import("../vulkan.zig");


const framebufferInitResult = extern struct {
    result: vk.VkResult,
    framebuffers: [*c] vk.VkFramebuffer,
    len: u32,
};

extern fn framebufferInit([*c]vk.VkImageView, c_int, vk.VkDevice, vk.VkRenderPass, vk.VkExtent2D) framebufferInitResult;
extern fn framebufferDeinit(vk.VkDevice, framebufferInitResult) void;


pub const errors = error{
    framebufferInitializationFailed
};


pub const framebuffer = struct {
    framebuffers: []vk.VkFramebuffer,
    result: framebufferInitResult,
    device: vk.VkDevice,

    pub fn init(views: []vk.VkImageView, dev: vk.VkDevice, renderpass: vk.VkRenderPass, extent: vk.VkExtent2D) !framebuffer {
        var fb: framebuffer = undefined;
        try fb._init(views, dev, renderpass, extent);
        return fb;
    }

    fn _init(self: *framebuffer, views: []vk.VkImageView, dev: vk.VkDevice, renderpass: vk.VkRenderPass, extent: vk.VkExtent2D) !void {
        const result = framebufferInit(views.ptr, @intCast(views.len), dev, renderpass, extent);
        if (result.result != vk.VK_SUCCESS) return errors.framebufferInitializationFailed;
        self.framebuffers.ptr = result.framebuffers;
        self.framebuffers.len = result.len;
        self.result = result;
        self.device = dev;
    }

    pub fn deinit(self: *framebuffer) void {
        framebufferDeinit(self.device, self.result);
    }
};
