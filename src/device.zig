const std = @import("std");
const instance = @import("instance.zig");
const vk = @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", "");
    @cInclude("vulkan/vulkan.h");
});

pub const VkDeviceError = error{ 
    vkPhysicalDeviceNotFound,
    vkQueueFamilyNotFound,
    vkDeviceCreateFailed
};

pub const Device = struct {
    allocator: std.mem.Allocator,
    physical_dev: vk.VkPhysicalDevice,
    logical_dev: vk.VkDevice,
    queue: *vk.VkQueue,
    inst: *instance.Instance,
    priority: f32 = 1.0,
    features: vk.VkPhysicalDeviceFeatures,

    pub fn init(d: *Device, alloc: std.mem.Allocator, inst: *instance.Instance) !void {
        d.allocator = alloc;
        d.inst = inst;
       
        try d.getPhysicalDevice();
        const create_info = try d.buildCreateInfo();
        const err = vk.vkCreateDevice(d.physical_dev, &create_info, null, &d.logical_dev);
        if (err != vk.VK_SUCCESS) {
            return VkDeviceError.vkDeviceCreateFailed;
        }
        d.queue = try d.allocator.create(vk.VkQueue);
        const idx: u32 = create_info.pQueueCreateInfos.*.queueFamilyIndex;
        vk.vkGetDeviceQueue(d.logical_dev, idx, 0, d.queue);
    }

    pub fn deinit(d: *Device) void {
        vk.vkDestroyDevice(d.logical_dev, null);
    } 

    fn getPhysicalDevice(d: *Device) !void {
        var device_count: u32 = 0;
        _ = vk.vkEnumeratePhysicalDevices(d.inst.instance, &device_count, null);
        if (device_count == 0) {
            return VkDeviceError.vkPhysicalDeviceNotFound;
        }
        const devices: []vk.VkPhysicalDevice = try d.allocator.alloc(vk.VkPhysicalDevice, device_count);
        _ = vk.vkEnumeratePhysicalDevices(d.inst.instance, &device_count, devices.ptr);
        for (devices) |device| {
            if (d.checkDevice(device)) {
                d.physical_dev = device;
                return;
            }
        }
        return VkDeviceError.vkPhysicalDeviceNotFound;
    }

    fn checkDevice(_: *Device, _: vk.VkPhysicalDevice) bool {
        return true;
    } 
    
    fn buildCreateInfo(d: *Device) !vk.VkDeviceCreateInfo {
        const queue_family_idx = try d.searchQueueFamily();
        var queue_create_info: vk.VkDeviceQueueCreateInfo = .{
            .sType = vk.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            .queueFamilyIndex = queue_family_idx,
            .queueCount = 1,
            .pQueuePriorities = &d.priority,
        };
        vk.vkGetPhysicalDeviceFeatures(d.physical_dev, &d.features);
        const create_info: vk.VkDeviceCreateInfo = .{
            .sType = vk.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
            .pQueueCreateInfos = &queue_create_info,
            .queueCreateInfoCount = 1,
            .pEnabledFeatures = &d.features,
            .enabledExtensionCount = 0,
            .enabledLayerCount = @intCast(d.inst.validation_layers.len),
            .ppEnabledLayerNames = if (d.inst.validation_layers.len == 0) null else d.inst.validation_layers.ptr
        };

        return create_info;
    }
    
    fn searchQueueFamily(d: *Device) !u32 {
        var graphics_index: ?u32 = null;
        var queue_family_count: u32 = 0;
        vk.vkGetPhysicalDeviceQueueFamilyProperties(d.physical_dev, &queue_family_count, null);
        const families: []vk.VkQueueFamilyProperties = try d.allocator.alloc(vk.VkQueueFamilyProperties, queue_family_count);
        vk.vkGetPhysicalDeviceQueueFamilyProperties(d.physical_dev, &queue_family_count, families.ptr);

        for (families, 0..) |family, idx| {
            if (family.queueFlags & vk.VK_QUEUE_GRAPHICS_BIT != 0) {
                graphics_index = @intCast(idx);
            }
        }
        if (graphics_index) |index| {
            return index;
        }
        return VkDeviceError.vkQueueFamilyNotFound;
    }

};

