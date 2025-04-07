const shader = @import("shader.zig");
const vk = @import("../vulkan.zig");
const std = @import("std");


const pipelineInitResult = extern struct {
    result: vk.VkResult,
    layout: vk.VkPipelineLayout,
    pipeline: vk.VkPipeline
};
extern fn pipelineInit(vk.VkShaderModule, vk.VkShaderModule, vk.VkExtent2D, vk.VkFormat, vk.VkDevice, vk.VkRenderPass) pipelineInitResult;
extern fn pipelineDeinit(vk.VkDevice, vk.VkPipelineLayout, vk.VkPipeline) void;


pub const errors = error {
    pipelineInitializationFailed
};


pub const pipeline = struct {
    vertex: shader.shader,
    fragment: shader.shader,
    layout: vk.VkPipelineLayout,
    pipeline: vk.VkPipeline,
    result: pipelineInitResult,
    dev: vk.VkDevice,

    pub fn init(alloc: std.mem.Allocator, vert_raw: []const u8, frag_raw: []const u8, dev: vk.VkDevice, extent: vk.VkExtent2D, format: vk.VkFormat, renderpass: vk.VkRenderPass) !pipeline {
        var p: pipeline = undefined;
        try p._init(alloc, vert_raw, frag_raw, dev, extent, format, renderpass);
        return p;
    }

    fn _init(self: *pipeline, alloc: std.mem.Allocator, vert_path: []const u8, frag_path: []const u8, dev: vk.VkDevice, extent: vk.VkExtent2D, format: vk.VkFormat, renderpass: vk.VkRenderPass) !void {
        self.vertex = try shader.shader.init(alloc, vert_path, dev);
        self.fragment = try shader.shader.init(alloc, frag_path, dev);
        self.dev = dev;

        const result = pipelineInit(self.vertex.shader, self.fragment.shader, extent, format, dev, renderpass);
        if (result.result != vk.VK_SUCCESS) return errors.pipelineInitializationFailed;
        self.layout = result.layout;
        self.pipeline = result.pipeline;
        self.result = result;
    }

    pub fn deinit(self: *pipeline) void {
        pipelineDeinit(self.dev, self.layout, self.pipeline);
        self.vertex.deinit();
        self.fragment.deinit();
    }
};
