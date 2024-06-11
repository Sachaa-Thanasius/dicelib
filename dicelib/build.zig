const std = @import("std");

const targets: []const std.Target.Query = &.{
    .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .gnu },
    .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .musl },

    .{ .cpu_arch = .arm, .os_tag = .linux, .abi = .gnu },
    .{ .cpu_arch = .arm, .os_tag = .linux, .abi = .musl },

    .{ .cpu_arch = .x86, .os_tag = .linux, .abi = .gnu },
    .{ .cpu_arch = .x86, .os_tag = .linux, .abi = .musl },

    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },

    .{ .cpu_arch = .aarch64, .os_tag = .macos },
    .{ .cpu_arch = .x86_64, .os_tag = .macos },

    .{ .cpu_arch = .x86, .os_tag = .windows },
    .{ .cpu_arch = .x86_64, .os_tag = .windows },
};

pub fn build(b: *std.Build) !void {
    // const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_source_file = b.path("dicemath.zig");

    for (targets) |t| {
        const libdicemath = b.addSharedLibrary(.{
            .name = "dicemath",
            .root_source_file = root_source_file,
            .target = b.resolveTargetQuery(t),
            .optimize = optimize,
            .single_threaded = false,
            .pic = true,
            .strip = true,
            .unwind_tables = false,
        });

        // libdicemath.bind_symbolic = true;
        libdicemath.link_builtin = true;
        libdicemath.link_z_nocopyreloc = true;
        libdicemath.link_gc_sections = true;
        libdicemath.linker_allow_shlib_undefined = false;
        libdicemath.generated_implib = null;
        libdicemath.formatted_panics = false;
        
        const target_output = b.addInstallArtifact(libdicemath, .{
            .dest_dir = .{
                .override = .{
                    .custom = try t.zigTriple(b.allocator),
                },
            },
        });

        b.getInstallStep().dependOn(&target_output.step);
        // b.installArtifact(libdicemath);
    }
}
