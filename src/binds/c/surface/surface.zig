const vk = @import("../vulkan.zig");
const glfw = @import("../glfw.zig");
const instance = @import("../instance/instance.zig");
const window = @import("../window/window.zig");
const std = @import("std");

const surfaceInitResult = extern struct {
    result: vk.VkResult,
    surface: vk.VkSurfaceKHR,
    instance: *vk.VkInstance,
};
extern fn surfaceInit(*vk.VkInstance, *glfw.GLFWwindow) surfaceInitResult;
extern fn surfaceDeinit(*const surfaceInitResult) void;

pub const errors = error{
    windowSurfaceCreateFailed
};

pub const surface = struct {
    surf: vk.VkSurfaceKHR,
    result: surfaceInitResult,

    pub fn init(inst: *instance.instance, win: *window.window) !surface {
        var sf: surface = undefined;
        try sf._init(inst.inst, win.obj);
        return sf;
    }

    fn _init(self: *surface, inst: vk.VkInstance, win: *glfw.GLFWwindow) !void {
        const result = surfaceInit(@constCast(&inst), win);
        if (result.result != vk.VK_SUCCESS) {
            return errors.windowSurfaceCreateFailed;
        }
        self.surf = result.surface;
        self.result = result;
    }

    pub fn deinit(s: *surface) void {
        surfaceDeinit(&s.result);
    }
};
