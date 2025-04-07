const vk = @import("../vulkan.zig");
const glfw = @import("../glfw.zig");
const device = @import("../device/device.zig");
const surface = @import("../surface/surface.zig");
const window = @import("../window/window.zig");
const queue = @import("../queue/queue.zig");
const std = @import("std");


const swapchainInitResult = extern struct {
    res: vk.VkResult,
    swapchain: vk.VkSwapchainKHR,
    create_info: vk.VkSwapchainCreateInfoKHR,
    images: [*c]vk.VkImage,
    views: [*c]vk.VkImageView,
    len: u32
};

extern fn swapchainInit(vk.VkPhysicalDevice, vk.VkDevice, vk.VkSurfaceKHR, *glfw.GLFWwindow, [*c]u32, u32) swapchainInitResult;
extern fn swapchainDeinit(*vk.VkDevice, *swapchainInitResult) void;


pub const errors = error{
    swapchainInitFailed
};


pub const swapchain = struct {
    sc: vk.VkSwapchainKHR,
    dev: vk.VkDevice,
    create_info: vk.VkSwapchainCreateInfoKHR,
    images: []vk.VkImage,
    views: []vk.VkImageView,
    result: swapchainInitResult,
   
    pub fn init(alloc: std.mem.Allocator, dev: *device.device, surf: *surface.surface, win: *window.window) !swapchain {
        var sc: swapchain = undefined;
        try sc._init(alloc, dev.physical_device.physical_device, dev.dev, surf.surf, win.obj, dev.queues.create_info);
        return sc;
    }

    fn _init(s: *swapchain, alloc: std.mem.Allocator, physdev: vk.VkPhysicalDevice, dev: vk.VkDevice, surf: vk.VkSurfaceKHR, win: *glfw.GLFWwindow, queues: []vk.VkDeviceQueueCreateInfo) !void {
        var indices: []u32 = try alloc.alloc(u32, queues.len);
        for (queues, 0..) |q, idx| {
            indices[idx] = q.queueFamilyIndex;
        }
        const result = swapchainInit(physdev, dev, surf, win, indices.ptr, @intCast(indices.len));
        alloc.free(indices);
        if (result.res != vk.VK_SUCCESS) return errors.swapchainInitFailed;
        s.create_info = result.create_info;
        s.sc = result.swapchain;
        s.images.ptr = result.images;
        s.views.ptr = result.views;
        s.images.len = result.len;
        s.views.len = result.len;
        s.dev = dev;
        s.result = result;
    }

    pub fn deinit(s: *swapchain) void {
        swapchainDeinit(&s.dev, &s.result);
    }
};
