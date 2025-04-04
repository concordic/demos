const vk = @import("../vulkan.zig");
const glfw = @import("../glfw.zig");
const instance = @import("../instance/instance.zig");
const window = @import("../window/window.zig");
const std = @import("std");


extern fn surfaceInit(*vk.VkSurfaceKHR, vk.VkInstance, *glfw.GLFWwindow) vk.VkResult;
extern fn surfaceDeinit(vk.VkSurfaceKHR, vk.VkInstance) void;

pub const errors = error{
    windowSurfaceCreateFailed
};

pub const surface = struct {
    surf: vk.VkSurfaceKHR,
    inst: vk.VkInstance,

    pub fn init(alloc: std.mem.Allocator, inst: *instance.instance, win: *window.window) !surface {
        var sf: surface = undefined;
        try sf._init(alloc, inst.inst, win.obj);
        return sf;
    }

    fn _init(s: *surface, alloc: std.mem.Allocator, inst: vk.VkInstance, win: *glfw.GLFWwindow) !void {
        _ = alloc;
        s.inst = inst;
        const result = surfaceInit(&s.surf, inst, win);
        if (result != vk.VK_SUCCESS) {
            return errors.windowSurfaceCreateFailed;
        }
    }

    pub fn deinit(s: *surface) void {
        surfaceDeinit(s.surf, s.inst);
    }
};
