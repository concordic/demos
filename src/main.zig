const std = @import("std");
const t = @import("test.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const anon = comptime .{ .a = 1, .b = 2, .c = "Hello" };
    const val = t.add(anon.a, anon.b);
    var a: i32 = undefined;
    var b: i32 = undefined;
    a = 1;
    b = 2;
    try stdout.print("{}, {}\n", .{ a, b });
    const val2 = t.add_ptr(&a, &b);
    t.print_hello();
    try stdout.print("{}, {}, {}, {}\n", .{ val, val2, a, b });
    for (0..5) |value| {
        try stdout.print("{}, {s}\n", .{ value, anon.c });
    }
    // try writer.print("{}\n", .{category});
}
