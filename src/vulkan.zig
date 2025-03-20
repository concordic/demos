const std = @import("std");
const vk = @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", "");
    @cInclude("vulkan/vulkan.h");
});

pub const VkError = error{ vkInstanceCreateFailed, vkValidationUnsupported };

pub const Instance = struct {
    instance: vk.VkInstance,
    allocator: std.mem.Allocator,
    // application
    app_name: [*:0]const u8,
    app_version: []const u32,
    // extensions
    extension_layers: [][*:0]const u8,
    create_flags: u32,
    // validation
    validation_layers: [][*:0]const u8,
    enable_validate: bool = true,

    pub fn init(inst: *Instance, alloc: std.mem.Allocator, name: []const u8, version: []const u32, extensions: [][]const u8, extension_flags: u32, validations: [][]const u8) !void {
        inst.allocator = alloc;
        inst.app_name = try std.fmt.allocPrintZ(inst.allocator, "{s}", .{name});
        inst.app_version = version;

        inst.create_flags = extension_flags;
        inst.extension_layers = try inst.allocator.alloc([*:0]const u8, extensions.len);
        for (extensions, 0..) |extension, idx| {
            inst.extension_layers[idx] = try std.fmt.allocPrintZ(inst.allocator, "{s}", .{extension});
        }

        inst.validation_layers = try inst.allocator.alloc([*:0]const u8, validations.len);
        for (validations, 0..) |validation, idx| {
            inst.validation_layers[idx] = try std.fmt.allocPrintZ(inst.allocator, "{s}", .{validation});
        }

        var app_info: vk.VkApplicationInfo = try inst.getAppInfo();
        var create_info: vk.VkInstanceCreateInfo = try inst.getCreateInfo(&app_info);

        var err: vk.VkResult = vk.VK_SUCCESS;
        err = vk.vkCreateInstance(&create_info, null, &inst.instance);
        if (err != vk.VK_SUCCESS) {
            return VkError.vkInstanceCreateFailed;
        }
    }

    pub fn deinit(inst: *Instance) void {
        vk.vkDestroyInstance(inst.instance, null);
    }

    fn getAppInfo(inst: *Instance) !vk.VkApplicationInfo {
        const app_info: vk.VkApplicationInfo = .{ 
            .sType = vk.VK_STRUCTURE_TYPE_APPLICATION_INFO, 
            .pApplicationName = inst.app_name[0..], 
            .applicationVersion = vk.VK_MAKE_VERSION(
                inst.app_version[0], inst.app_version[1], inst.app_version[2]
            ), 
            .pEngineName = "No Engine", 
            .engineVersion = vk.VK_MAKE_VERSION(1, 0, 0), 
            .apiVersion = vk.VK_API_VERSION_1_0 
        };
        return app_info;
    }

    fn getCreateInfo(inst: *Instance, app_info: *vk.VkApplicationInfo) !vk.VkInstanceCreateInfo {
        if (inst.enable_validate and !try inst.checkValidationLayer()) {
            return VkError.vkValidationUnsupported;
        }
        const create_info: vk.VkInstanceCreateInfo = .{ 
            .sType = vk.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO, 
            .pApplicationInfo = app_info, 
            .enabledExtensionCount = @intCast(inst.extension_layers.len), 
            .ppEnabledExtensionNames = inst.extension_layers.ptr, 
            .flags = inst.create_flags, 
            .enabledLayerCount = switch (inst.enable_validate) {
                true => @intCast(inst.validation_layers.len),
                false => 0,
            }, 
            .ppEnabledLayerNames = switch (inst.enable_validate) {
                true => inst.validation_layers.ptr,
                false => null,
            } 
        };
        return create_info;
    }

    fn checkValidationLayer(inst: *Instance) !bool {
        const str = @cImport({
            @cInclude("string.h");
        });

        var err: vk.VkResult = vk.VK_SUCCESS;
        var layer_count: u32 = undefined;
        err = vk.vkEnumerateInstanceLayerProperties(&layer_count, null);
        if (err != vk.VK_SUCCESS) {
            return VkError.vkValidationUnsupported;
        }

        const availables: []vk.VkLayerProperties = try inst.allocator.alloc(vk.VkLayerProperties, layer_count);
        err = vk.vkEnumerateInstanceLayerProperties(&layer_count, availables.ptr);
        if (err != vk.VK_SUCCESS) {
            return VkError.vkValidationUnsupported;
        }

        for (availables) |available| {
            var layer_found: bool = false;
            for (inst.validation_layers) |validation| {
                if (str.strcmp(available.layerName[0..].ptr, validation) == 0) {
                    layer_found = true;
                    break;
                }
            }
            if (!layer_found) {
                return false;
            }
        }
        return true;
    }
};
