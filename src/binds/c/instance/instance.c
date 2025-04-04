#include <GLFW/glfw3.h>
#include <vulkan/vulkan.h>
#include <stdlib.h>

VkResult instanceInit(
		VkInstance* instance, const char* app_name, int major, int minor, int patch, 
		const char** required_extensions, int num_extensions, int flags,
		const char** validation_layers, int num_layers
	) {
	VkApplicationInfo app_info = {
		.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
		.pApplicationName = app_name,
		.applicationVersion = VK_MAKE_VERSION(major, minor, patch),
		.pEngineName = "No Engine",
		.engineVersion = VK_MAKE_VERSION(major, minor, patch),
		.apiVersion = VK_API_VERSION_1_0
	};

	uint32_t extension_count = 0;
	const char** extensions = glfwGetRequiredInstanceExtensions(&extension_count);
	const char** combined_extensions = malloc((extension_count + num_extensions) * sizeof(const char*));
	for (int i = 0; i < extension_count + num_extensions; i++) {
		if (i < extension_count) {
			combined_extensions[i] = extensions[i];
		}
		else {
			combined_extensions[i] = required_extensions[i-extension_count];
		}
	}

	VkInstanceCreateInfo create_info = {
		.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
		.pApplicationInfo = &app_info,
		.enabledExtensionCount = extension_count + num_extensions,
		.ppEnabledExtensionNames = combined_extensions,
		.enabledLayerCount = num_layers,
		.ppEnabledLayerNames = validation_layers,
		.flags = flags
	};

	return vkCreateInstance(&create_info, NULL, instance);
}

void instanceDeinit(VkInstance instance) {
	vkDestroyInstance(instance, NULL);
}
