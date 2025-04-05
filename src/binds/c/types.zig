const std = @import("std");


pub const CStr = struct {
    ptr: [*]const u8,
    slc: [:0]const u8,
    alloc: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator, src: []const u8) !CStr {
        var c: CStr = undefined;
        try c._init(alloc, src);
        return c;
    }

    fn _init(self: *CStr, alloc: std.mem.Allocator, slc: []const u8) !void {
        self.slc = try alloc.dupeZ(u8, slc);
        self.ptr = self.slc.ptr;
        self.alloc = alloc;
    }

    pub fn deinit(self: CStr) void {
        self.alloc.free(self.slc);
    }
};

pub const CStrArray = struct {
    arr: []CStr,
    ptr: [*][*]const u8,
    ptr_arr: [][*]const u8,
    len: usize,
    alloc: std.mem.Allocator,
    
    pub fn init(alloc: std.mem.Allocator, src: [][]const u8) !CStrArray {
        var a: CStrArray = undefined;
        try a._init(alloc, src);
        return a;
    }

    fn _init(self: *CStrArray, alloc: std.mem.Allocator, slc: [][]const u8) !void {
        self.arr = try alloc.alloc(CStr, slc.len);
        self.len = self.arr.len;
        self.ptr_arr = try alloc.alloc([*]const u8, slc.len);
        for (slc, 0..) |src, idx| {
            self.arr[idx] = try CStr.init(alloc, src);
            self.ptr_arr[idx] = self.arr[idx].ptr;
        }
        self.ptr = self.ptr_arr.ptr;
        self.alloc = alloc;
    }

    pub fn deinit(self: CStrArray) void {
        for (self.arr) |cstr| {
            cstr.deinit();
        }
        self.alloc.free(self.arr);
        self.alloc.free(self.ptr_arr);
    }
};
