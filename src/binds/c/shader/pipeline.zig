const shader = @import("shader.zig");
const vk = @import("../vulkan.zig");
const std = @import("std");


const pipelineInitResult = extern struct {
    result: vk.VkResult,
    layout: vk.VkPipelineLayout
};
extern fn pipelineInit(vk.VkShaderModule, vk.VkShaderModule, vk.VkExtent2D, vk.VkFormat, vk.VkDevice) pipelineInitResult;
extern fn pipelineDeinit(vk.VkDevice, vk.VkPipelineLayout) void;


pub const errors = error {
    pipelineInitializationFailed
};


pub const pipeline = struct {
    vertex: shader.shader,
    fragment: shader.shader,
    layout: vk.VkPipelineLayout,
    result: pipelineInitResult,
    dev: vk.VkDevice,

    pub fn init(alloc: std.mem.Allocator, vert_raw: []const u8, frag_raw: []const u8, dev: vk.VkDevice, extent: vk.VkExtent2D, format: vk.VkFormat) !pipeline {
        var p: pipeline = undefined;
        try p._init(alloc, vert_raw, frag_raw, dev, extent, format);
        return p;
    }

    fn _init(self: *pipeline, alloc: std.mem.Allocator, vert_path: []const u8, frag_path: []const u8, dev: vk.VkDevice, extent: vk.VkExtent2D, format: vk.VkFormat) !void {
        self.vertex = try shader.shader.init(alloc, vert_path, dev);
        self.fragment = try shader.shader.init(alloc, frag_path, dev);
        self.dev = dev;

        const result = pipelineInit(self.vertex.shader, self.fragment.shader, extent, format, dev);
        if (result.result != vk.VK_SUCCESS) return errors.pipelineInitializationFailed;
        self.layout = result.layout;
        self.result = result;
    }

    pub fn deinit(self: *pipeline) void {
        pipelineDeinit(self.dev, self.layout);
        self.vertex.deinit();
        self.fragment.deinit();
    }
};
