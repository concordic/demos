const std = @import("std");
const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});

pub fn main() !void {
    _ = glfw.glfwInit();
    glfw.glfwWindowHint(glfw.GLFW_CLIENT_API, glfw.GLFW_NO_API);
    const window: ?*glfw.GLFWwindow = glfw.glfwCreateWindow(800, 600, "Vulkan", null, null);
    while (glfw.glfwWindowShouldClose(window) == 0) {
        glfw.glfwPollEvents();
    }
    glfw.glfwDestroyWindow(window);
    glfw.glfwTerminate();
}
