#include "vulkan/vulkan_core.h"
#include <vulkan/vulkan.h>


typedef struct semaphoreInitResult {
	VkResult result;
	VkSemaphore semaphore;
} semaphoreInitResult;

semaphoreInitResult semaphoreInit(VkDevice dev) {
	VkSemaphoreCreateInfo create_info = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
	};
	semaphoreInitResult result;
	result.result = vkCreateSemaphore(dev, &create_info, NULL, &result.semaphore);
	return result;
}
void semaphoreDeinit(VkDevice dev, semaphoreInitResult result) {
	vkDestroySemaphore(dev, result.semaphore, NULL);
}

typedef struct fenceInitResult {
	VkResult result;
	VkFence fence;
} fenceInitResult;

fenceInitResult fenceInit(VkDevice dev) {
	VkFenceCreateInfo create_info = {
		.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
		.flags = VK_FENCE_CREATE_SIGNALED_BIT,
	};
	fenceInitResult result;
	result.result = vkCreateFence(dev, &create_info, NULL, &result.fence);
	return result;
}
void fenceDeinit(VkDevice dev, fenceInitResult result) {
	vkDestroyFence(dev, result.fence, NULL);
}
