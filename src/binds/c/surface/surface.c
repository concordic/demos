#include "vulkan/vulkan_core.h"
#include <GLFW/glfw3.h>
#include <stdio.h>
#include <vulkan/vulkan.h>

VkResult surfaceInit(VkSurfaceKHR* surface, VkInstance instance, GLFWwindow* window) {
	VkResult result = glfwCreateWindowSurface(instance, window, NULL, surface);
	printf("%d", result);
	return result;
}

void surfaceDeinit(VkSurfaceKHR surface, VkInstance instance) {
	vkDestroySurfaceKHR(instance, surface, NULL);
}
