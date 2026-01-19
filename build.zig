const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_sha256 = b.addLibrary(.{
        .name = "crypto_sha256",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/sha256/sha256.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    
    const lib_blake2s = b.addLibrary(.{
        .name = "crypto_blake2s",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/blake/blake2s.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const mod_bitops = b.createModule(.{
        .root_source_file = b.path("src/cryptops/bitops.zig"),
    });

    const mod_boolops = b.createModule(.{
        .root_source_file = b.path("src/cryptops/boolops.zig"),
    });

    const mod_endian = b.createModule(.{
        .root_source_file = b.path("src/cryptops/endian.zig"),
    });

    lib_sha256.root_module.addImport("bitops", mod_bitops);
    lib_sha256.root_module.addImport("boolops", mod_boolops);
    lib_sha256.root_module.addImport("endian", mod_endian);
    
    lib_blake2s.root_module.addImport("bitops", mod_bitops);

    b.installArtifact(lib_sha256);
    b.installArtifact(lib_blake2s);
}
