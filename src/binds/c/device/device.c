#include "vulkan/vulkan_core.h"
#include <limits.h>
#include <vulkan/vulkan.h>
#include <stdbool.h>
#include <stdlib.h>

typedef struct physdevInitResult {
	VkPhysicalDevice physical_device;
} physdevInitResult;

physdevInitResult physdevInit(const VkInstance* instance, int (*suitability_check)(VkPhysicalDevice)) {
	uint32_t num_devices = 0;
	vkEnumeratePhysicalDevices(*instance, &num_devices, NULL);
	VkPhysicalDevice devs[num_devices];
	vkEnumeratePhysicalDevices(*instance, &num_devices, devs);
	int most_suitable = INT_MIN;
	VkPhysicalDevice best_device = VK_NULL_HANDLE;
	for (int i = 0; i < num_devices; i++) {
		if (suitability_check(devs[i]) > most_suitable) {
			best_device = devs[i];
		}
	}
	physdevInitResult result;
	result.physical_device = best_device;
	return result;
}

typedef struct deviceInitResult {
	VkResult result;
	VkDevice device;
} deviceInitResult;

deviceInitResult deviceInit(const VkPhysicalDevice* physdev, 
		const VkDeviceQueueCreateInfo* queue_creates, int num_queues, 
		const char** extensions, int num_extensions, 
		const char** layers, int num_layers) {
	deviceInitResult result;
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
	result.result = vkCreateDevice(*physdev, &dev_create_info, NULL, &result.device);
	free(dev_features);
	return result;
}

void deviceDeinit(deviceInitResult* result) {
	vkDestroyDevice(result->device, NULL);
}
