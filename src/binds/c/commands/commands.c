#include "vulkan/vulkan_core.h"
#include <vulkan/vulkan.h>


typedef struct commandpoolInitResult {
	VkResult result;
	VkCommandPool commandpool;
} commandpoolInitResult;

commandpoolInitResult commandpoolInit(VkDevice dev, uint32_t graphics_index) {
	VkCommandPoolCreateInfo create_info = {
		.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
		.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
		.queueFamilyIndex = graphics_index,
	};

	commandpoolInitResult result;
	result.result = vkCreateCommandPool(dev, &create_info, NULL, &result.commandpool);
	return result;
}

void commandpoolDeinit(VkDevice dev, commandpoolInitResult result) {
	vkDestroyCommandPool(dev, result.commandpool, NULL);
}



typedef struct commandbufferInitResult {
	VkResult result;
	VkCommandBuffer commandbuffer;
} commandbufferInitResult;

commandbufferInitResult commandbufferInit(VkDevice dev, VkCommandPool commandpool) {
	VkCommandBufferAllocateInfo alloc_info = {
		.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
		.commandPool = commandpool,
		.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
		.commandBufferCount = 1
	};
	
	commandbufferInitResult result;
	result.result = vkAllocateCommandBuffers(dev, &alloc_info, &result.commandbuffer);
	return result;
}


typedef struct commandbufferRecordResult {
	VkResult result;
} commandbufferRecordResult;

commandbufferRecordResult commandbufferRecord(VkCommandBuffer cb, VkFramebuffer fb, VkRenderPass renderpass, VkPipeline pipeline, VkExtent2D extent) {
	VkCommandBufferBeginInfo begin_info = {
		.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
		.flags = 0,
		.pInheritanceInfo = NULL
	};
	commandbufferRecordResult result;
	result.result = vkBeginCommandBuffer(cb, &begin_info);
	if (result.result != VK_SUCCESS) return result;
	VkClearValue color = {{{0.0f, 0.0f, 0.0f, 1.0f}}};
	VkRenderPassBeginInfo rp_info = {
		.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
		.renderPass = renderpass,
		.framebuffer = fb,
		.renderArea = {
			.offset = {0, 0},
			.extent = extent
		},
		.clearValueCount = 1,
		.pClearValues = &color
	};
	vkCmdBeginRenderPass(cb, &rp_info, VK_SUBPASS_CONTENTS_INLINE);
	vkCmdBindPipeline(cb, VK_PIPELINE_BIND_POINT_GRAPHICS, pipeline);
	VkViewport viewport = {
		.x = 0.0f,
		.y = 0.0f,
		.width = (float) extent.width,
		.height = (float) extent.height,
		.minDepth = 0.0f,
		.maxDepth = 0.1f
	};
	vkCmdSetViewport(cb, 0, 1, &viewport);
	VkRect2D scissor = {
		.offset = {0, 0},
		.extent = extent
	};
	vkCmdSetScissor(cb, 0, 1, &scissor);
	vkCmdDraw(cb, 3, 1, 0, 0);
	vkCmdEndRenderPass(cb);
	result.result = vkEndCommandBuffer(cb);
	return result;
}
