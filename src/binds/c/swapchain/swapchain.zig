const vk = @import("../vulkan.zig");
const glfw = @import("../glfw.zig");
const device = @import("../device/device.zig");
const surface = @import("../surface/surface.zig");
const window = @import("../window/window.zig");
const queue = @import("../queue/queue.zig");
const std = @import("std");


extern fn swapchainInit(*vk.VkSwapchainKHR, vk.VkPhysicalDevice, vk.VkDevice, vk.VkSurfaceKHR, *glfw.GLFWwindow, [*c]u32, u32) vk.VkResult;
extern fn swapchainDeinit(vk.VkSwapchainKHR, vk.VkDevice) void;


pub const errors = error{
    swapchainInitFailed
};


pub const swapchain = struct {
    sc: vk.VkSwapchainKHR,
    dev: vk.VkDevice,
   
    pub fn init(alloc: std.mem.Allocator, dev: *device.device, surf: *surface.surface, win: *window.window) !swapchain {
        var sc: swapchain = undefined;
        try sc._init(alloc, dev.phys_dev, dev.dev, surf.surf, win.obj, dev.queues.create_info);
        return sc;
    }

    fn _init(s: *swapchain, alloc: std.mem.Allocator, physdev: vk.VkPhysicalDevice, dev: vk.VkDevice, surf: vk.VkSurfaceKHR, win: *glfw.GLFWwindow, queues: []vk.VkDeviceQueueCreateInfo) !void {
        var indices: []u32 = try alloc.alloc(u32, queues.len);
        for (queues, 0..) |q, idx| {
            indices[idx] = q.queueFamilyIndex;
        }
        const result = swapchainInit(&s.sc, physdev, dev, surf, win, indices.ptr, @intCast(indices.len));
        if (result != vk.VK_SUCCESS) return errors.swapchainInitFailed;
        s.dev = dev;
    }

    pub fn deinit(s: *swapchain) void {
        swapchainDeinit(s.sc, s.dev);
    }
};
