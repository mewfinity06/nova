const std = @import("std");

const library_dir: [:0]const u8 = "libs/";
const library_ext: [:0]const u8 = ".zig";
const shared_libraries = [_][:0]const u8{
    "foo",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "nova",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    inline for (comptime shared_libraries) |name| {
        // No need for length calculation or slicing at comptime, _lib_name is already a comptime string.

        // Construct the full path by concatenating the directory, filename, and extension
        const lib_source_path_str = library_dir ++ name ++ library_ext;

        // Use b.path with the single, complete path string
        const lib_source_path = b.path(lib_source_path_str);

        const lib = b.addStaticLibrary(.{
            .name = name,
            .root_source_file = lib_source_path,
            .target = target,
            .optimize = optimize,
        });

        exe.linkLibrary(lib);
    }

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
