const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    std.process.args();
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 2) return error.ExpectedArgument;

    const f = try std.fmt.parseFloat(f32, args[1]);
    const c = (f - 32.0) * 5.0 / 9.0;
    try stdout.print("{d:.1}c\n", .{c});
}
