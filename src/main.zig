const std = @import("std");
const glfw = @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", "");
    @cInclude("GLFW/glfw3.h");
});
const vk = @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", "");
    @cInclude("vulkan/vulkan.h");
});

pub const GlfwError = error{glfwInitFailed};
pub const VkError = error{vkInstanceCreateFailed};

fn print_extensions(exts: [*c][*c]const u8, len: usize) !void {
    const stdout = std.io.getStdOut().writer();
    for (0..len) |i| {
        const name = exts[i];
        // try stdout.print("{s}", .{name});
        try stdout.print("{c}", .{name.*});
        try stdout.print("\n", .{});
    }
}

pub const App = struct {
    window: ?*glfw.GLFWwindow,
    instance: vk.VkInstance,

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
        try app.createInstance();
    }

    fn createInstance(app: *App) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        const app_info: vk.VkApplicationInfo = .{ .sType = vk.VK_STRUCTURE_TYPE_APPLICATION_INFO, .pApplicationName = "Hello Triangle", .applicationVersion = vk.VK_MAKE_VERSION(1, 0, 0), .pEngineName = "No Engine", .engineVersion = vk.VK_MAKE_VERSION(1, 0, 0), .apiVersion = vk.VK_API_VERSION_1_0 };
        var glfw_extension_count: u32 = 0;
        var glfw_extensions: [*c][*c]const u8 = undefined;
        glfw_extensions = glfw.glfwGetRequiredInstanceExtensions(&glfw_extension_count);
        std.debug.print("{}\n", .{glfw_extension_count});
        const ext_mem = try allocator.alloc([*c]const u8, glfw_extension_count + 1);
        const new_extensions: [*c][*c]const u8 = ext_mem.ptr;
        for (0..glfw_extension_count) |idx| {
            ext_mem[idx] = glfw_extensions[idx];
        }
        const ext_name = vk.VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME;
        std.debug.print("{s}\n", .{ext_name});
        ext_mem[glfw_extension_count] = ext_name;
        var create_info: vk.VkInstanceCreateInfo = .{ .sType = vk.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO, .pApplicationInfo = &app_info, .enabledExtensionCount = glfw_extension_count + 1, .ppEnabledExtensionNames = new_extensions, .enabledLayerCount = 0 };
        create_info.flags |= vk.VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
        const result: vk.VkResult = vk.vkCreateInstance(&create_info, null, &app.instance);
        if (result != vk.VK_SUCCESS) {
            std.debug.print("{}\n", .{result});
            return VkError.vkInstanceCreateFailed;
        }
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
