#include "vulkan/vulkan_core.h"
#include <stdint.h>
#include <vulkan/vulkan.h>
#include <stdlib.h>


typedef struct framebufferInitResult {
	VkResult result;
	VkFramebuffer* framebuffers;
	uint16_t len;
} framebufferInitResult;

framebufferInitResult framebufferInit(VkImageView* views, int num_views, VkDevice dev, VkRenderPass renderpass, VkExtent2D extent) {
	framebufferInitResult result;
	result.framebuffers = malloc(num_views * sizeof(VkFramebuffer));
	result.len = num_views;
	for (int i = 0 ; i < num_views; i++) {
		VkImageView* attachment = &views[i];
		VkFramebufferCreateInfo create_info = {
			.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
			.renderPass = renderpass,
			.attachmentCount = 1,
			.pAttachments = attachment,
			.width = extent.width,
			.height = extent.height,
			.layers = 1,
		};
		VkResult res = vkCreateFramebuffer(dev, &create_info, NULL, &result.framebuffers[i]);
		if (res != VK_SUCCESS) {
			result.result = res;
			return result;
		}
	}
	return result;
}


void framebufferDeinit(VkDevice dev, framebufferInitResult result) {
	for (int i = 0; i < result.len; i++) {
		vkDestroyFramebuffer(dev, result.framebuffers[i], NULL);
	}
}
