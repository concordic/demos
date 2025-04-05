const glfw = @import("../glfw.zig");
const vk = @import("../vulkan.zig");
const std = @import("std");
const types = @import("../types.zig");

const c_str = [*c]const u8;
const str = []const u8;
const instanceInitResult = extern struct {
    result: vk.VkResult, 
    instance: vk.VkInstance
};
extern fn instanceInit(c_str, c_int, c_int, c_int, [*c]const c_str, c_int, c_int, [*c]const c_str, c_int) instanceInitResult;
extern fn instanceDeinit(*const instanceInitResult) void;

pub const errors = error{
    instanceCreationFailed
};

pub const instance = struct {
    inst: vk.VkInstance,
    result: instanceInitResult,

    pub fn init(alloc: std.mem.Allocator, app_name: str, version: [3]u32, extensions: []str, flags: i32, validations: []str) !instance {
        var inst: instance = undefined;
        try inst._init(alloc, app_name, version, extensions, flags, validations);
        return inst;
    }

    fn _init(self: *instance, alloc: std.mem.Allocator, 
            app_name: str, version: [3]u32, 
            required_extensions: []str, flags: i32,
            validation_layers: []str) !void {

        const z_app_name = try types.CStr.init(alloc, app_name);
        defer z_app_name.deinit();
        const z_extensions = try types.CStrArray.init(alloc, required_extensions);
        defer z_extensions.deinit();
        const z_validations = try types.CStrArray.init(alloc, validation_layers);
        defer z_validations.deinit();

        const result = instanceInit( 
            z_app_name.ptr, @intCast(version[0]), @intCast(version[1]), @intCast(version[2]), 
            z_extensions.ptr, @intCast(z_extensions.len), flags,
            z_validations.ptr, @intCast(z_validations.len)
        );
        if (result.result != vk.VK_SUCCESS) {
            return errors.instanceCreationFailed;
        }
        self.inst = result.instance;
        self.result = result;
    }

    pub fn deinit(self: *instance) void {
        instanceDeinit(&self.result);
    }
};
