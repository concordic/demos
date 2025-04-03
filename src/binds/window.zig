const winc = @import("window/window.zig");
const std = @import("std");

pub fn wrap(comptime func: *const fn () bool) *const fn (...) callconv(.c) c_int {
    return struct {
        fn inner(...) callconv(.c) c_int {
            if (func()) return 1 else return 0;
        }
    }.inner;
}

pub const window = struct {
    obj: *winc.GLFWwindow,
    alloc: std.mem.Allocator,
    
    pub fn init(w: *window, alloc: std.mem.Allocator, width: u32, height: u32, name: []const u8) !void {
        w.alloc = alloc;
        const z_name = try alloc.dupeZ(u8, name);
        w.obj = winc.initWindow(@intCast(width), @intCast(height), z_name.ptr).?;
    }

    pub fn deinit(w: *window) void {
        winc.deinitWindow(w.obj);
    }

    pub fn update(w: *window, callback: *const fn (...) callconv(.c) c_int) void {
        winc.updateWindow(w.obj, callback);
    }    

};
