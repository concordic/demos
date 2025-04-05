#include <GLFW/glfw3.h>
#include <vulkan/vulkan.h>
#include <stdlib.h>

typedef struct str_arr {
	int len;
	const char** arr;
} StrArr;

static StrArr _wrangle_extensions(StrArr required_extensions) {
	uint32_t extension_count = 0;
	const char** extensions = glfwGetRequiredInstanceExtensions(&extension_count);
	StrArr combined;
	combined.arr = malloc((extension_count + required_extensions.len) * sizeof(const char*));
	for (int i = 0; i < extension_count + required_extensions.len; i++) {
		if (i < extension_count) {
			combined.arr[i] = extensions[i];
		}
		else {
			combined.arr[i] = required_extensions.arr[i-extension_count];
		}
	}
	combined.len = extension_count + required_extensions.len;
	return combined;
}

typedef struct instanceInitResult {
	VkResult result;
	VkInstance instance;
} instanceInitResult;

instanceInitResult instanceInit(
		const char* app_name, int major, int minor, int patch, 
		const char** required_extensions, int num_extensions, int flags,
		const char** validation_layers, int num_layers
	) {
	StrArr reqd_exts = { .len = num_extensions, .arr = required_extensions };
	StrArr vald_lays = { .len = num_layers, .arr = validation_layers };
	VkApplicationInfo app_info = {
		.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
		.pApplicationName = app_name,
		.applicationVersion = VK_MAKE_VERSION(major, minor, patch),
		.pEngineName = "No Engine",
		.engineVersion = VK_MAKE_VERSION(major, minor, patch),
		.apiVersion = VK_API_VERSION_1_0
	};

	StrArr extensions = _wrangle_extensions(reqd_exts);
	VkInstanceCreateInfo create_info = {
		.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
		.pApplicationInfo = &app_info,
		.enabledExtensionCount = extensions.len,
		.ppEnabledExtensionNames = extensions.arr,
		.enabledLayerCount = vald_lays.len,
		.ppEnabledLayerNames = vald_lays.arr,
		.flags = flags
	};

	instanceInitResult result;
	result.result = vkCreateInstance(&create_info, NULL, &result.instance);
	free(extensions.arr);
	return result;
}

void instanceDeinit(const instanceInitResult* instance) {
	vkDestroyInstance(instance->instance, NULL);
}
