#include "vulkan/vulkan_core.h"
#include <GLFW/glfw3.h>
#include <vulkan/vulkan.h>

VkResult instanceInit(VkInstance* instance) {
	VkApplicationInfo app_info = {
		.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
		.pApplicationName = "Hello Triangle",
		.applicationVersion = VK_MAKE_VERSION(1, 0, 0),
		.pEngineName = "No Engine",
		.engineVersion = VK_MAKE_VERSION(1, 0, 0),
		.apiVersion = VK_API_VERSION_1_0
	};

	uint32_t extension_count = 0;
	const char** extensions = glfwGetRequiredInstanceExtensions(&extension_count);

	VkInstanceCreateInfo create_info = {
		.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
		.pApplicationInfo = &app_info,
		.enabledExtensionCount = extension_count,
		.ppEnabledExtensionNames = extensions,
		.enabledLayerCount = 0
	};

	return vkCreateInstance(&create_info, NULL, instance);
}

void instanceDeinit(VkInstance instance) {
	vkDestroyInstance(instance, NULL);
}
