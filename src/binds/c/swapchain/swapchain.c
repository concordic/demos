#include "GLFW/glfw3.h"
#include "vulkan/vulkan_core.h"
#include <stdint.h>
#include <vulkan/vulkan.h>
#include <stdlib.h>


struct swapChainSupport {
	VkSurfaceCapabilitiesKHR capabilities;
	VkSurfaceFormatKHR* formats;
	uint32_t num_formats;
	VkPresentModeKHR* modes;
	uint32_t num_modes;
};


struct swapChainSupport _get_swapchain_support(VkPhysicalDevice device, VkSurfaceKHR surface) {
	struct swapChainSupport details;
	vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, surface, &details.capabilities);
	vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &details.num_formats, NULL);
	details.formats = malloc(details.num_formats * sizeof(VkSurfaceFormatKHR));
	vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &details.num_formats, details.formats);
	vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &details.num_modes, NULL);
	details.modes = malloc(details.num_formats * sizeof(VkPresentModeKHR));
	vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &details.num_formats, details.modes);
	return details;
}

VkSurfaceFormatKHR _choose_surface_format(VkSurfaceFormatKHR* formats, uint32_t num_formats) {
	for (int i = 0; i < num_formats; i++) {
		if (formats[i].format == VK_FORMAT_B8G8R8A8_SRGB && formats[i].colorSpace == VK_COLORSPACE_SRGB_NONLINEAR_KHR) {
			return formats[i];
		}
	}
	return formats[0];
}

VkPresentModeKHR _choose_present_mode(VkPresentModeKHR* modes, uint32_t num_modes) {
	return VK_PRESENT_MODE_FIFO_KHR;
}

VkExtent2D _choose_extent(VkSurfaceCapabilitiesKHR capabilities, GLFWwindow* window) {
	int width, height;
	glfwGetFramebufferSize(window, &width, &height);
	if (width > capabilities.maxImageExtent.width) width = capabilities.maxImageExtent.width;
	if (width < capabilities.minImageExtent.width) width = capabilities.minImageExtent.width;
	if (height > capabilities.maxImageExtent.height) height = capabilities.maxImageExtent.height;
	if (height < capabilities.minImageExtent.height) height = capabilities.minImageExtent.height;
	VkExtent2D ext = {
		(uint32_t)width,
		(uint32_t)height
	};
	return ext;
}


VkResult swapchainInit(VkSwapchainKHR* swapchain, VkPhysicalDevice physdev, VkDevice dev, VkSurfaceKHR surface, GLFWwindow* window, uint32_t* queue_indices, uint32_t num_queues) {
	struct swapChainSupport supp = _get_swapchain_support(physdev, surface);
	VkSurfaceFormatKHR format = _choose_surface_format(supp.formats, supp.num_formats);
	VkPresentModeKHR mode = _choose_present_mode(supp.modes, supp.num_modes);
	VkExtent2D extent = _choose_extent(supp.capabilities, window);
	uint32_t imagec = supp.capabilities.minImageCount + 1;
	if (supp.capabilities.maxImageCount > 0 && imagec > supp.capabilities.maxImageCount) imagec = supp.capabilities.maxImageCount;

	VkSwapchainCreateInfoKHR create_info = {
		.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
		.surface = surface,
		.minImageCount = imagec,
		.imageFormat = format.format,
		.imageColorSpace = format.colorSpace,
		.imageExtent = extent,
		.imageArrayLayers = 1,
		.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
		.imageSharingMode = (num_queues > 1) ? VK_SHARING_MODE_CONCURRENT : VK_SHARING_MODE_EXCLUSIVE,
		.queueFamilyIndexCount = num_queues,
		.pQueueFamilyIndices = queue_indices,
		.preTransform = supp.capabilities.currentTransform,
		.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
		.presentMode = mode,
		.clipped = VK_FALSE,
		.oldSwapchain = VK_NULL_HANDLE
	};

	VkResult result = vkCreateSwapchainKHR(dev, &create_info, NULL, swapchain);
	return result;
}

void swapchainDeinit(VkSwapchainKHR swapchain, VkDevice dev) {
	vkDestroySwapchainKHR(dev, swapchain, NULL);
}
