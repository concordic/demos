#include <stdint.h>
#include <stdlib.h>
#include <vulkan/vulkan.h>
#include <stdbool.h>
#include <assert.h>


struct FeatureCallback {
	bool (*callback)(VkPhysicalDevice, VkQueueFamilyProperties*, int, int, void*);
	void* args;
};

static uint32_t _get_queue_family_index(VkPhysicalDevice physdev, struct FeatureCallback callback) {
	uint32_t num_queue_families = 0;
	vkGetPhysicalDeviceQueueFamilyProperties(physdev, &num_queue_families, NULL);
	VkQueueFamilyProperties queues[num_queue_families];
	vkGetPhysicalDeviceQueueFamilyProperties(physdev, &num_queue_families, queues);
	for (int i = 0; i < num_queue_families; i++) {
		if (callback.callback(physdev, queues, num_queue_families, i, callback.args)) {
			return i;
		}
	}
	assert(false); // assume unreachable
}

typedef struct queueCreatesInitResult {
	VkDeviceQueueCreateInfo* create_infos;
	float* priorities;
	uint32_t* indices;
	uint32_t* info_map;
	uint32_t len;
} queueCreatesInitResult;

queueCreatesInitResult queueCreatesInit(const VkPhysicalDevice* physdev, 
		struct FeatureCallback callbacks[], int num_features) {
	queueCreatesInitResult result;
	result.create_infos = malloc(num_features * sizeof(VkDeviceQueueCreateInfo));
	result.priorities = malloc(num_features * sizeof(float));
	result.indices = malloc(num_features * sizeof(uint32_t));
	result.info_map = malloc(num_features * sizeof(uint32_t));
	uint32_t num_uniques = 0;
	for (int i = 0; i < num_features; i++) {
		uint32_t family_index = _get_queue_family_index(*physdev, callbacks[i]);
		result.indices[i] = family_index;
		result.priorities[i] = 1.0f;
		bool broke = false;
		for (int j = 0; j < i; j++) {
			if (result.create_infos[j].queueFamilyIndex == family_index) {
				broke = true;
				break;
			}
		}
		if (broke) {
			result.info_map[i] = num_uniques - 1;
			continue;
		}
		result.create_infos[num_uniques].sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
		result.create_infos[num_uniques].queueFamilyIndex = family_index;
		result.create_infos[num_uniques].queueCount = 1;
		result.create_infos[num_uniques].pQueuePriorities = &(result.priorities[i]);
		num_uniques++;
		result.info_map[i] = num_uniques - 1;
	}
	result.len = num_uniques;
	return result;
}

typedef struct queueDeviceInitResult {
	VkQueue* queues;
	uint32_t len;
} queueDeviceInitResult;

queueDeviceInitResult queueDeviceInit(const VkDevice* dev, const queueCreatesInitResult* creates) {
	queueDeviceInitResult result;
	result.queues = malloc(creates->len * sizeof(VkQueue));
	for (int i = 0; i < creates->len; i++) {
		vkGetDeviceQueue(*dev, creates->create_infos[i].queueFamilyIndex, i, result.queues);
	}
	result.len = creates->len;
	return result;
}


void queueDeinit(const queueCreatesInitResult* result1, const queueDeviceInitResult* result2) {
	free(result2->queues);
	free(result1->priorities);
	free(result1->create_infos);
	free(result1->indices);
	free(result1->info_map);
}
