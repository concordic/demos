const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{ .name = "main", .root_source_file = b.path("src/main.zig"), .target = b.graph.host });
    b.installArtifact(exe);

    const c_source_files = [_][]const u8{"src/test.c"};
    const c_flags = [_][]const u8{};
    exe.addCSourceFiles(.{ .files = &c_source_files, .flags = &c_flags });

    exe.linkLibC();

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
