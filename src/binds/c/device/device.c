#include "vulkan/vulkan_core.h"
#include <stdint.h>
#include <vulkan/vulkan.h>
#include <stdbool.h>
#include <stdlib.h>

bool _is_device_suitable(VkPhysicalDevice dev) {
	return true;
}

VkPhysicalDevice _phys_device_init(VkInstance instance) {
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

int _get_queue_family_index(VkPhysicalDevice physdev, int feature) {
	uint32_t num_queue_families = 0;
	vkGetPhysicalDeviceQueueFamilyProperties(physdev, &num_queue_families, NULL);
	VkQueueFamilyProperties queues[num_queue_families];
	vkGetPhysicalDeviceQueueFamilyProperties(physdev, &num_queue_families, queues);
	for (int i = 0; i < num_queue_families; i++) {
		if (queues[i].queueFlags & feature) {
			return i;
		}
	}
	return -1;
}

VkResult deviceInit(VkDevice* device, VkQueue* queue, VkInstance instance, int* features, int num_features, const char** extensions, int num_extensions, const char** layers, int num_layers) {
	VkPhysicalDevice physdev = _phys_device_init(instance);
	VkDeviceQueueCreateInfo* queue_creates = malloc(num_features * sizeof(VkDeviceQueueCreateInfo));
	for (int i = 0; i < num_features; i++) {
		float* priority = malloc(sizeof(float));
		*priority = 1.0f;
		queue_creates[i].sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
		queue_creates[i].queueFamilyIndex = _get_queue_family_index(physdev, features[i]);
		queue_creates[i].queueCount = 1;
		queue_creates[i].pQueuePriorities = priority;
	}
	VkPhysicalDeviceFeatures* dev_features = malloc(sizeof(VkPhysicalDeviceFeatures));
	VkDeviceCreateInfo dev_create_info = {
		.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
		.pQueueCreateInfos = queue_creates,
		.queueCreateInfoCount = num_features,
		.pEnabledFeatures = dev_features,
		.ppEnabledExtensionNames = extensions,
		.enabledExtensionCount = num_extensions,
		.ppEnabledLayerNames = layers,
		.enabledLayerCount = num_layers,
	};
	VkResult result = vkCreateDevice(physdev, &dev_create_info, NULL, device);
	if (result == VK_SUCCESS) {
		for (int i = 0; i < num_features; i++) {
			vkGetDeviceQueue(*device, queue_creates[i].queueFamilyIndex, i, queue);
		}
	}
	return result;
}

void deviceDeinit(VkDevice device) {
	vkDestroyDevice(device, NULL);
}
