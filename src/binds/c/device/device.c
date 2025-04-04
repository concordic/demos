#include "vulkan/vulkan_core.h"
#include <vulkan/vulkan.h>
#include <stdbool.h>
#include <stdlib.h>

// TODO: turn this into a function pointer callback
bool _is_device_suitable(VkPhysicalDevice dev) {
	return true;
}

VkPhysicalDevice devicePhysInit(VkInstance instance) {
	uint32_t num_devices = 0;
	vkEnumeratePhysicalDevices(instance, &num_devices, NULL);
	VkPhysicalDevice devs[num_devices];
	vkEnumeratePhysicalDevices(instance, &num_devices, devs);
	for (int i = 0; i < num_devices; i++) {
		if (_is_device_suitable(devs[i])) {
			return devs[i];
		}
	}
	return VK_NULL_HANDLE;
}

VkResult deviceInit(VkDevice* device, VkPhysicalDevice physdev, VkInstance instance, VkDeviceQueueCreateInfo* queue_creates, int num_queues, const char** extensions, int num_extensions, const char** layers, int num_layers) {
	// VkDeviceQueueCreateInfo queue_creates[num_features];
	VkPhysicalDeviceFeatures* dev_features = malloc(sizeof(VkPhysicalDeviceFeatures));
	VkDeviceCreateInfo dev_create_info = {
		.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
		.pQueueCreateInfos = queue_creates,
		.queueCreateInfoCount = num_queues,
		.pEnabledFeatures = dev_features,
		.ppEnabledExtensionNames = extensions,
		.enabledExtensionCount = num_extensions,
		.ppEnabledLayerNames = layers,
		.enabledLayerCount = num_layers,
	};
	VkResult result = vkCreateDevice(physdev, &dev_create_info, NULL, device);
	return result;
}

void deviceDeinit(VkDevice device) {
	vkDestroyDevice(device, NULL);
}
