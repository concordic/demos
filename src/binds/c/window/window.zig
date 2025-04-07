const glfw = @import("../glfw.zig");
const types = @import("../types.zig");
const std = @import("std");

extern fn windowInit(width: c_int, height: c_int, name: [*c]const u8) *glfw.GLFWwindow;
extern fn windowUpdate(window: *glfw.GLFWwindow, loop: ?*const fn (*anyopaque) callconv(.c) c_int, *anyopaque) void;
extern fn windowDeinit(window: *glfw.GLFWwindow) void;

pub fn wrap(comptime func: *const fn (*anyopaque) bool) *const fn (*anyopaque) callconv(.c) c_int {
    return struct {
        pub fn inner(data: *anyopaque) callconv(.c) c_int {
            if (func(data)) return 1 else return 0;
        }
    }.inner;
}

pub const window = struct {
    obj: *glfw.GLFWwindow,
   
    pub fn init(alloc: std.mem.Allocator, width: u32, height: u32, name: []const u8) !window {
        var win: window = undefined;
        try win._init(alloc, width, height, name);
        return win;
    }

    fn _init(w: *window, alloc: std.mem.Allocator, width: u32, height: u32, name: []const u8) !void {
        const z_name = try types.CStr.init(alloc, name);
        defer z_name.deinit();
        w.obj = windowInit(@intCast(width), @intCast(height), z_name.ptr);
    }

    pub fn deinit(w: *window) void {
        windowDeinit(w.obj);
    }

    pub fn update(w: *window, callback: *const fn (*anyopaque) callconv(.c) c_int, args: *anyopaque) void {
        windowUpdate(w.obj, callback, args);
    }    

};

