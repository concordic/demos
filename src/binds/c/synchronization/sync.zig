const vk = @import("../vulkan.zig");


const semaphoreInitResult = extern struct {
    result: vk.VkResult,
    semaphore: vk.VkSemaphore,
};
const fenceInitResult = extern struct {
    result: vk.VkResult,
    fence: vk.VkFence,
};
extern fn semaphoreInit(vk.VkDevice) semaphoreInitResult;
extern fn semaphoreDeinit(vk.VkDevice, semaphoreInitResult) void;
extern fn fenceInit(vk.VkDevice) fenceInitResult;
extern fn fenceDeinit(vk.VkDevice, fenceInitResult) void;


pub const errors = error {
    semaphoreInitializationFailed,
    fenceInitializationFailed,
};


pub const semaphore = struct {
    semaphore: vk.VkSemaphore,
    device: vk.VkDevice,
    result: semaphoreInitResult,

    pub fn init(dev: vk.VkDevice) !semaphore {
        var s: semaphore = undefined;
        try s._init(dev);
        return s;
    }

    fn _init(self: *semaphore, dev: vk.VkDevice) !void {
        const result = semaphoreInit(dev);
        if (result.result != vk.VK_SUCCESS) return errors.semaphoreInitializationFailed;
        self.semaphore = result.semaphore;
        self.device = dev;
        self.result = result;
    }

    pub fn deinit(self: *semaphore) void {
        semaphoreDeinit(self.device, self.result);
    }
};

pub const fence = struct {
    fence: vk.VkFence,
    device: vk.VkDevice,
    result: fenceInitResult,

    pub fn init(dev: vk.VkDevice) !fence {
        var f: fence = undefined;
        try f._init(dev);
        return f;
    }

    fn _init(self: *fence, dev: vk.VkDevice) !void {
        const result = fenceInit(dev);
        if (result.result != vk.VK_SUCCESS) return errors.fenceInitializationFailed;
        self.fence = result.fence;
        self.device = dev;
        self.result = result;
    }

    pub fn deinit(self: *fence) void {
        fenceDeinit(self.device, self.result);
    }
};
