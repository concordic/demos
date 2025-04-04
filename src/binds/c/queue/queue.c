#include "vulkan/vulkan_core.h"
#include <stdint.h>
#include <stdlib.h>
#include <vulkan/vulkan.h>
#include <stdbool.h>
#include <wchar.h>


// TODO: turn the set of features into a set of function pointers that take the device, queue index, queue families and returns whether the feature is present
uint32_t _get_queue_family_index(VkPhysicalDevice physdev, void* data, bool (*check_feature)(VkPhysicalDevice, VkQueueFamilyProperties*, int, int, void*)) {
	uint32_t num_queue_families = 0;
	vkGetPhysicalDeviceQueueFamilyProperties(physdev, &num_queue_families, NULL);
	VkQueueFamilyProperties queues[num_queue_families];
	vkGetPhysicalDeviceQueueFamilyProperties(physdev, &num_queue_families, queues);
	for (int i = 0; i < num_queue_families; i++) {
		if (check_feature(physdev, queues, num_queue_families, i, data)) {
			return i;
		}
	}
	return -1;
}

VkDeviceQueueCreateInfo* queueCreatesInit(VkPhysicalDevice physdev, VkInstance instance, 
		bool(*check_features[])(VkPhysicalDevice, VkQueueFamilyProperties*, int, int, void*), int num_features, int* num_queues, void** data) {
	VkDeviceQueueCreateInfo* queue_creates = malloc(num_features * sizeof(VkDeviceQueueCreateInfo));
	int num_uniques = 0;
	for (int i = 0; i < num_features; i++) {
		float* priority = malloc(sizeof(float));
		*priority = 1.0f;
		uint32_t family_index = _get_queue_family_index(physdev, data[i], check_features[i]);
		bool broke = false;
		for (int j = 0; j < i; j++) {
			if (queue_creates[j].queueFamilyIndex == family_index) {
				broke = true;
				break;
			}
		}
		if (broke) continue;
		queue_creates[num_uniques].sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
		queue_creates[num_uniques].queueFamilyIndex = family_index;
		queue_creates[num_uniques].queueCount = 1;
		queue_creates[num_uniques].pQueuePriorities = priority;
		num_uniques++;
	}
	*num_queues = num_uniques;
	return queue_creates;
}

void queueDeviceInit(VkQueue* queue, VkDevice dev, VkDeviceQueueCreateInfo* queue_creates, int num_queues) {
	for (int i = 0; i < num_queues; i++) {
		vkGetDeviceQueue(dev, queue_creates[i].queueFamilyIndex, i, queue);
	}
}
