const std = @import("std");
const window = @import("binds/window.zig");
const instance = @import("binds/instance.zig");
const device = @import("binds/device.zig");
const queue = @import("binds/queue.zig");
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
    var dev_extensions: [1][]const u8 = .{
        "VK_KHR_portability_subset",
    };

    // create instance and defer free
    var inst = try instance.instance.init(allocator, 
        "Hello World", .{1, 0, 0}, 
        extensions[0..], instance_flags,
        validations[0..]
    );
    defer inst.deinit();

    var features: [1]queue.CheckFeaturePointer = .{
        queue.wrap(struct {
            pub fn graphics(_: vulkan.VkPhysicalDevice, queues: []vulkan.VkQueueFamilyProperties, idx: u32) bool { 
                return queues[idx].queueFlags & vulkan.VK_QUEUE_GRAPHICS_BIT != 0;
            }
        }.graphics),
   //     queue.wrap(struct {
   //         pub fn surface(physdev: vulkan.VkPhysicalDevice, _: []vulkan.VkQueueFamilyProperties, idx: u32) bool {
   //             var support: bool = false;
   //             vulkan.vkGetPhysicalDeviceSurfaceSupportKHR(physdev, idx, surface, &support);
   //         }
   //     })
    };
    // create logical device and defer free
    var dev = try device.device.init(allocator, inst.inst, 
        features[0..], 
        dev_extensions[0..], 
        validations[0..]
    );
    defer dev.deinit();
    
    // create window and defer free
    var win = try window.window.init(allocator, 800, 600, "Vulkan");
    defer win.deinit();

    // start window update loop
    win.update(window.wrap(&update));
}
