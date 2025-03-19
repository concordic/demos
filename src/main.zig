const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const anon = comptime .{ .a = 1, .b = 2, .c = "Hello" };
    for (0..5) |value| {
        try stdout.print("{}, {s}\n", .{ value, anon.c });
    }
    // try writer.print("{}\n", .{category});
}
