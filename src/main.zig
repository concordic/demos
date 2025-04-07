const std = @import("std");
const window = @import("binds/window.zig");
const instance = @import("binds/instance.zig");
const device = @import("binds/device.zig");
const surface = @import("binds/surface.zig");
const queue = @import("binds/queue.zig");
const swapchain = @import("binds/swapchain.zig");
const shader = @import("binds/shader.zig");
const framebuffer = @import("binds/framebuffer.zig");
const commands = @import("binds/commands.zig");
const sync = @import("binds/sync.zig");
const vulkan = @import("binds/c/vulkan.zig");


const main_info = struct {
    device: device.device,
    in_flight: sync.fence,
    img_avail: sync.semaphore,
    render_done: sync.semaphore,
    swapchain: swapchain.swapchain,
    cmdbuf: commands.commandbuffer
};
// things required 
// device 
// in flight fence 
// swapchain 
// image available semaphore 
// command buffer 
fn update(data: *anyopaque) bool {
    const args: *main_info = @ptrCast(@alignCast(data));
    _ = vulkan.vkWaitForFences(args.device.dev, 1, &args.in_flight.fence, vulkan.VK_TRUE, std.math.maxInt(u64));
    _ = vulkan.vkResetFences(args.device.dev, 1, &args.in_flight.fence);
    var img_idx: u32 = undefined;
    _ = vulkan.vkAcquireNextImageKHR(args.device.dev, args.swapchain.sc, std.math.maxInt(u64), args.img_avail.semaphore, @ptrCast(vulkan.VK_NULL_HANDLE), &img_idx);
    _ = vulkan.vkResetCommandBuffer(args.cmdbuf.cb, 0);
    args.cmdbuf.record(img_idx) catch return false;
    const waits: [1]vulkan.VkSemaphore = .{args.img_avail.semaphore};
    const stages: [1]vulkan.VkPipelineStageFlags = .{vulkan.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT};
    const signals: [1]vulkan.VkSemaphore = .{args.render_done.semaphore};
    const swapchains: [1]vulkan.VkSwapchainKHR = .{args.swapchain.sc};
    const submit_info: vulkan.VkSubmitInfo = .{
        .sType = vulkan.VK_STRUCTURE_TYPE_SUBMIT_INFO,
        .waitSemaphoreCount = waits[0..].len,
        .pWaitSemaphores = waits[0..].ptr,
        .pWaitDstStageMask = stages[0..].ptr,
        .commandBufferCount = 1,
        .pCommandBuffers = &args.cmdbuf.cb,
        .signalSemaphoreCount = signals[0..].len,
        .pSignalSemaphores = signals[0..].ptr
    };
    const result = vulkan.vkQueueSubmit(args.device.queues.queues[args.device.queues.info_map[0]], 1, &submit_info, args.in_flight.fence);
    if (result != vulkan.VK_SUCCESS) return true;
    const present_info: vulkan.VkPresentInfoKHR = .{
        .sType = vulkan.VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
        .waitSemaphoreCount = signals[0..].len,
        .pWaitSemaphores = signals[0..].ptr,
        .swapchainCount = swapchains[0..].len,
        .pSwapchains = swapchains[0..].ptr,
        .pImageIndices = &img_idx,
        .pResults = null
    };
    _ = vulkan.vkQueuePresentKHR(args.device.queues.queues[args.device.queues.info_map[1]], &present_info);
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

    var pipe = try shader.pipeline.init(allocator, @embedFile("shaders/vert.spv"), @embedFile("shaders/frag.spv"), dev.dev, sc.create_info.imageExtent, sc.create_info.imageFormat, rpass.renderpass);
    defer pipe.deinit();

    var fb = try framebuffer.framebuffer.init(sc.views, dev.dev, rpass.renderpass, sc.create_info.imageExtent);
    defer fb.deinit();

    var cp = try commands.commandpool.init(dev.dev, dev.queues.indicies[0]);
    defer cp.deinit();

    var cb = try commands.commandbuffer.init(cp.commandpool, dev.dev, fb.framebuffers, rpass.renderpass, pipe.pipeline, sc.create_info.imageExtent);
    defer cb.deinit();

    var img_avail = try sync.semaphore.init(dev.dev);
    defer img_avail.deinit();
    var render_done = try sync.semaphore.init(dev.dev);
    defer render_done.deinit();
    var in_flight = try sync.fence.init(dev.dev);
    defer in_flight.deinit();

    // start window update loop
    var info: main_info = .{
        .cmdbuf = cb,
        .device = dev,
        .img_avail = img_avail,
        .in_flight = in_flight,
        .swapchain = sc,
        .render_done = render_done
    };
    win.update(window.wrap(&update), @ptrCast(&info));
}
