const std = @import("std");
const vk = @import("../vulkan.zig");


const shaderModuleInitResult = extern struct {
    result: vk.VkResult,
    shader: vk.VkShaderModule,
};
extern fn shaderModuleInit(vk.VkDevice, [*c]const u32, u32) shaderModuleInitResult;
extern fn shaderModuleDeinit(vk.VkDevice, shaderModuleInitResult) void;


pub const errors = error{
    shaderInitializationFailed
};

pub const shader = struct {
    raw: []const u32,
    raw_slc: []const u8,
    shader: vk.VkShaderModule,
    result: shaderModuleInitResult,
    alloc: std.mem.Allocator,
    dev: vk.VkDevice,

    pub fn init(alloc: std.mem.Allocator, spv_raw: []const u8, dev: vk.VkDevice) !shader {
        var s: shader = undefined;
        try s._init(alloc, spv_raw, dev);
        return s;
    }

    fn _init(self: *shader, alloc: std.mem.Allocator, spv_raw: []const u8, dev: vk.VkDevice) !void {
        self.raw_slc = try alloc.dupe(u8, spv_raw);
        self.raw.ptr = @ptrCast(@alignCast(self.raw_slc));
        self.raw.len = spv_raw.len;
        const result = shaderModuleInit(dev, self.raw.ptr, @intCast(self.raw.len));
        if (result.result != vk.VK_SUCCESS) return errors.shaderInitializationFailed;
        self.shader = result.shader;
        self.result = result;
        self.alloc = alloc;
        self.dev = dev;
    }

    pub fn deinit(self: *shader) void {
        shaderModuleDeinit(self.dev, self.result);
        self.alloc.free(self.raw_slc);
    }
};
