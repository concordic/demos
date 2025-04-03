const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(
        .{
            .name = "main",
            .root_source_file = b.path("src/main.zig"),
            .target = b.graph.host
        }
    );
    const files: [2][]const u8 = .{
        "window/window.c",
        "instance/instance.c"
    };
    exe.addCSourceFiles(.{
        .files = files[0..],
        .root = b.path("src/binds/c")
    });
    exe.addIncludePath(b.path("include"));
    exe.addIncludePath(b.path("src/binds/c"));
    exe.linkLibC();
    exe.addLibraryPath(b.path("lib"));
    // note this is macos only right now
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("vulkan");
    exe.linkFramework("Cocoa");
    exe.linkFramework("OpenGL");
    exe.linkFramework("IOKit");

    b.installArtifact(exe);
}
