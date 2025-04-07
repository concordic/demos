#include "vulkan/vulkan_core.h"
#include <stdint.h>
#include <vulkan/vulkan.h>


typedef struct shaderModuleInitResult {
	VkResult result;
	VkShaderModule shader;
} shaderModuleInitResult;

shaderModuleInitResult shaderModuleInit(VkDevice dev, const uint32_t* code, uint32_t len) {
	shaderModuleInitResult result;
	VkShaderModuleCreateInfo create_info = {
		.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
		.codeSize = len,
		.pCode = code,
	};
	result.result = vkCreateShaderModule(dev, &create_info, NULL, &result.shader);
	return result;
}

void shaderModuleDeinit(VkDevice dev, shaderModuleInitResult result) {
	vkDestroyShaderModule(dev, result.shader, NULL);
}

typedef struct pipelineInitResult {
	VkResult result;
	VkPipelineLayout layout;
} pipelineInitResult;

pipelineInitResult pipelineInit(VkShaderModule vertex, VkShaderModule fragment, VkExtent2D extent, VkFormat format, VkDevice dev) {
	VkPipelineShaderStageCreateInfo vert_create_info = {
		.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
		.module = vertex,
		.stage = VK_SHADER_STAGE_VERTEX_BIT,
		.pName = "main"
	};
	VkPipelineShaderStageCreateInfo frag_create_info = {
		.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
		.module = fragment,
		.stage = VK_SHADER_STAGE_FRAGMENT_BIT,
		.pName = "main"
	};
	VkDynamicState dynamic_states[2] = {
		VK_DYNAMIC_STATE_VIEWPORT,
		VK_DYNAMIC_STATE_SCISSOR,
	};
	VkPipelineDynamicStateCreateInfo state_create_info = {
		.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO,
		.dynamicStateCount = 2,
		.pDynamicStates = dynamic_states
	};
	VkPipelineVertexInputStateCreateInfo vert_in_create_info = {
		.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
		.vertexBindingDescriptionCount = 0,
		.pVertexBindingDescriptions = NULL,
		.vertexAttributeDescriptionCount = 0,
		.pVertexAttributeDescriptions = NULL
	};
	VkPipelineInputAssemblyStateCreateInfo in_asm_create_info = {
		.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
		.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST,
		.primitiveRestartEnable = VK_FALSE
	};
	VkViewport viewport = {
		.x = 0.0f,
		.y = 0.0f,
		.width = (float) extent.width,
		.height = (float) extent.height,
		.minDepth = 0.0f,
		.maxDepth = 1.0f
	};
	VkRect2D scissor = {
		.offset = { 0, 0 },
		.extent = extent
	};
	VkPipelineViewportStateCreateInfo viewport_create_info = {
		.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
		.viewportCount = 1,
		.pViewports = &viewport,
		.scissorCount = 1,
		.pScissors = &scissor,
	};
	VkPipelineRasterizationStateCreateInfo rasterize_create_info = {
		.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
		.depthClampEnable = VK_FALSE,
		.rasterizerDiscardEnable = VK_FALSE,
		.polygonMode = VK_POLYGON_MODE_FILL,
		.lineWidth = 1.0f,
		.cullMode = VK_CULL_MODE_BACK_BIT,
		.frontFace = VK_FRONT_FACE_CLOCKWISE,
		.depthBiasEnable = VK_FALSE,
		.depthBiasConstantFactor = 0.0f,
		.depthBiasClamp = 0.0f,
		.depthBiasSlopeFactor = 0.0f
	};
	VkPipelineMultisampleStateCreateInfo multisample_create_info = {
		.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
		.sampleShadingEnable = VK_FALSE,
		.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT,
		.minSampleShading = 1.0f,
		.pSampleMask = NULL,
		.alphaToCoverageEnable = VK_FALSE,
		.alphaToOneEnable = VK_FALSE,
	};
	VkPipelineColorBlendAttachmentState colorblend = {
		.colorWriteMask = VK_COLOR_COMPONENT_R_BIT | VK_COLOR_COMPONENT_G_BIT | VK_COLOR_COMPONENT_B_BIT | VK_COLOR_COMPONENT_A_BIT,
		.blendEnable = VK_FALSE,
		.srcColorBlendFactor = VK_BLEND_FACTOR_ONE,
		.dstColorBlendFactor = VK_BLEND_FACTOR_ZERO,
		.colorBlendOp = VK_BLEND_OP_ADD,
		.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE,
		.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO,
		.alphaBlendOp = VK_BLEND_OP_ADD
	};
	VkPipelineColorBlendStateCreateInfo color_state = {
		.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
		.logicOpEnable = VK_FALSE,
		.logicOp = VK_LOGIC_OP_COPY,
		.attachmentCount = 1,
		.pAttachments = &colorblend,
		.blendConstants = {
			0.0f,
			0.0f,
			0.0f,
			0.0f,
		}
	};
	VkPipelineLayoutCreateInfo layout_create_info = {
		.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
		.setLayoutCount = 0,
		.pSetLayouts = NULL,
		.pushConstantRangeCount = 0,
		.pPushConstantRanges = NULL
	};
	pipelineInitResult result;
	result.result = vkCreatePipelineLayout(dev, &layout_create_info, NULL, &result.layout);
	return result;
}

void pipelineDeinit(VkDevice dev, VkPipelineLayout layout) {
	vkDestroyPipelineLayout(dev, layout, NULL);
}


typedef struct renderpassInitResult {
	VkResult result;
	VkRenderPass renderpass;
} renderpassInitResult;

renderpassInitResult renderpassInit(VkDevice dev, VkFormat format) {
	VkAttachmentDescription attach = {
		.format = format,
		.samples = VK_SAMPLE_COUNT_1_BIT,
		.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR,
		.storeOp = VK_ATTACHMENT_STORE_OP_STORE,
		.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE,
		.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE,
		.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED,
		.finalLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
	};
	VkAttachmentReference attach_ref = {
		.attachment = 0,
		.layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
	};
	// probably need to malloc this
	VkSubpassDescription subpass = {
		.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS,
		.colorAttachmentCount = 1,
		.pColorAttachments = &attach_ref
	};

	VkRenderPassCreateInfo render_create_info = {
		.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
		.attachmentCount = 1,
		.pAttachments = &attach,
		.subpassCount = 1,
		.pSubpasses = &subpass
	};
	renderpassInitResult result;
	result.result = vkCreateRenderPass(dev, &render_create_info, NULL, &result.renderpass);
	return result;
}

void renderpassDeinit(VkDevice dev, VkRenderPass renderpass) {
	vkDestroyRenderPass(dev, renderpass, NULL);
}
