#include "vulkan/vulkan_core.h"
#include <GLFW/glfw3.h>
#include <stdio.h>
#include <vulkan/vulkan.h>
#include <assert.h>


typedef struct surfaceInitResult {
	VkResult result;
	VkSurfaceKHR surface;
	VkInstance instance;
} surfaceInitResult;

surfaceInitResult surfaceInit(const VkInstance* instance, GLFWwindow* window) {
	assert(window);
	surfaceInitResult result;
	result.result = glfwCreateWindowSurface(*instance, window, NULL, &result.surface);
	result.instance = *instance;
	return result;
}

void surfaceDeinit(const surfaceInitResult* result) {
	vkDestroySurfaceKHR(result->instance, result->surface, NULL);
}
