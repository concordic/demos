const std = @import("std");
const window = @import("binds/window.zig");
const instance = @import("binds/instance.zig");
const device = @import("binds/device.zig");
const surface = @import("binds/surface.zig");
const queue = @import("binds/queue.zig");
const swapchain = @import("binds/swapchain.zig");
const shader = @import("binds/shader.zig");
const framebuffer = @import("binds/framebuffer.zig");
const vulkan = @import("binds/c/vulkan.zig");

fn update() bool {
    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    
    // creation configuration
    var extensions: [2][]const u8 = .{
        vulkan.VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME,
        vulkan.VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME,
    };
    const instance_flags = vulkan.VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
    var validations: [1][]const u8 = .{
        "VK_LAYER_KHRONOS_validation"
    };
    var dev_extensions: [2][]const u8 = .{
        "VK_KHR_portability_subset",
        "VK_KHR_swapchain",
    };

    // create window and defer free
    var win = try window.window.init(allocator, 800, 600, "Vulkan");
    defer win.deinit();

    // create instance and defer free
    var inst = try instance.instance.init(allocator, 
        "Hello World", .{1, 0, 0}, 
        extensions[0..], instance_flags,
        validations[0..]
    );
    defer inst.deinit();

    // create surface and defer free
    var sf = try surface.surface.init(&inst, &win);
    defer sf.deinit();

    // create logical device and defer free
    var features: [2]queue.FeatureCallback = .{
        queue.wrap(
            struct { pub fn graphics(_: vulkan.VkPhysicalDevice, queues: []vulkan.VkQueueFamilyProperties, idx: u32, _: *anyopaque) bool { 
                return queues[idx].queueFlags & vulkan.VK_QUEUE_GRAPHICS_BIT != 0;
            }}.graphics, 
            undefined
        ),
        queue.wrap(
            struct { pub fn surface(physdev: vulkan.VkPhysicalDevice, _: []vulkan.VkQueueFamilyProperties, idx: u32, data: *anyopaque) bool {
                var support: vulkan.VkBool32 = vulkan.VK_FALSE;
                const surf: vulkan.VkSurfaceKHR = @ptrCast(@alignCast(data));
                _ = vulkan.vkGetPhysicalDeviceSurfaceSupportKHR(physdev, @intCast(idx), surf, &support);
                return support == vulkan.VK_TRUE;
            }}.surface, 
            @ptrCast(sf.surf)
        )
    };
    var dev = try device.device.init(allocator, &inst, 
        features[0..], 
        dev_extensions[0..], 
        validations[0..],
    );
    defer dev.deinit();

    var sc = try swapchain.swapchain.init(allocator, &dev, &sf, &win);
    defer sc.deinit();

    var rpass = try shader.renderpass.init(dev.dev, sc.create_info.imageFormat);
    defer rpass.deinit();

    var pipe = try shader.pipeline.init(allocator, @embedFile("shaders/vert.spv"), @embedFile("shaders/frag.spv"), dev.dev, sc.create_info.imageExtent, sc.create_info.imageFormat);
    defer pipe.deinit();

    var fb = try framebuffer.framebuffer.init(sc.views, dev.dev, rpass.renderpass, sc.create_info.imageExtent);
    defer fb.deinit();
    
    // start window update loop
    win.update(window.wrap(&update));
}
