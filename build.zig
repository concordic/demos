const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(
        .{
            .name = "main",
            .root_source_file = b.path("src/main.zig"),
            .target = b.graph.host
        }
    );
    exe.addCSourceFile(.{
        .file = b.path("src/binds/window/window.c"),
    });
    exe.addIncludePath(b.path("include"));
    exe.linkLibC();
    exe.addLibraryPath(b.path("lib"));
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("vulkan");
    exe.linkFramework("Cocoa");
    exe.linkFramework("OpenGL");
    exe.linkFramework("IOKit");

    b.installArtifact(exe);
}
