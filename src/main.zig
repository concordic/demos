const std = @import("std");
const vulkan = @import("vulkan.zig");
const glfw = @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", "");
    @cInclude("GLFW/glfw3.h");
});
const vk = @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", "");
    @cInclude("vulkan/vulkan.h");
});

pub const GlfwError = error{glfwInitFailed};

pub const App = struct {
    window: ?*glfw.GLFWwindow,
    instance: vulkan.Instance,

    fn run(app: *App) !void {
        try app.initWindow();
        defer app.cleanup();
        try app.initVulkan();
        app.mainLoop();
    }

    fn initWindow(app: *App) !void {
        const success = glfw.glfwInit();
        if (success == 0) {
            return GlfwError.glfwInitFailed;
        }
        glfw.glfwWindowHint(glfw.GLFW_CLIENT_API, glfw.GLFW_NO_API);
        app.window = glfw.glfwCreateWindow(800, 600, "Vulkan", null, null);
    }

    fn initVulkan(app: *App) !void {
        app.instance = undefined;
        const version: [3]u32 = .{ 1, 0, 0 };
        var extensions: [1][]const u8 = .{vk.VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME[0..]};
        const khronos_layer = "VK_LAYER_KHRONOS_validation";
        var validations: [1][]const u8 = .{khronos_layer[0..]};
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        try app.instance.init(allocator, "Hello", version[0..], extensions[0..], vk.VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR, validations[0..]);
    }

    fn mainLoop(app: *App) void {
        while (glfw.glfwWindowShouldClose(app.window) == 0) {
            glfw.glfwPollEvents();
        }
    }

    fn cleanup(app: *App) void {
        app.instance.deinit();
        glfw.glfwDestroyWindow(app.window);
        glfw.glfwTerminate();
    }
};

pub fn main() !void {
    var app: App = undefined;
    try app.run();
}
