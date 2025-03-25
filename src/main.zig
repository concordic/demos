const std = @import("std");
const instance = @import("instance.zig");
const device = @import("device.zig");
const glfw = @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", "");
    @cInclude("GLFW/glfw3.h");
});

pub const GlfwError = error{glfwInitFailed};

pub const App = struct {
    window: ?*glfw.GLFWwindow,
    instance: instance.Instance,
    device: device.Device,

    fn run(app: *App) !void {
        try app.initWindow();
        defer app.cleanup();
        try app.initVulkan();
        defer app.instance.deinit();
        defer app.device.deinit();
        app.mainLoop();
    }

    fn initWindow(app: *App) !void {
        const success = glfw.glfwInit();
        if (success == 0) {
            return GlfwError.glfwInitFailed;
        }
        glfw.glfwWindowHint(glfw.GLFW_CLIENT_API, glfw.GLFW_NO_API);
        app.window = glfw.glfwCreateWindow(
            800, 600, 
            "Vulkan", null, null
        );
    }

    fn initVulkan(app: *App) !void {
        app.instance = undefined;
        const version: [3]u32 = .{ 1, 0, 0 };
        const portability_name = "VK_KHR_portability_enumeration";
        var extensions: [1][]const u8 = .{
            portability_name[0..]
        };
        const khronos_layer = "VK_LAYER_KHRONOS_validation";
        var validations: [1][]const u8 = .{
            khronos_layer[0..]
        };
        const flags = 1;
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        try app.instance.init(
            allocator, 
            "Hello", version[0..], 
            extensions[0..], flags, 
            validations[0..]
        );
        app.device = undefined;
        try app.device.init(allocator, &app.instance);
    }

    fn mainLoop(app: *App) void {
        while (glfw.glfwWindowShouldClose(app.window) == 0) {
            glfw.glfwPollEvents();
        }
    }

    fn cleanup(app: *App) void {
        glfw.glfwDestroyWindow(app.window);
        glfw.glfwTerminate();
    }
};

pub fn main() !void {
    var app: App = undefined;
    try app.run();
}
