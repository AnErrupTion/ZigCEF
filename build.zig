const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "ZigCEF",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addIncludePath(.{ .path = "cef" });
    exe.addObjectFile(.{ .path = "cef/binaries/libcef.so" });
    exe.linkLibC();

    b.installArtifact(exe);

    const copy_bin_step = b.step("copy-bin", "Copies the CEF binaries into the output directory");
    copy_bin_step.makeFn = copyBin;
    copy_bin_step.dependOn(b.getInstallStep());

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(copy_bin_step);

    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

fn copyBin(self: *std.Build.Step, progress: *std.Progress.Node) !void {
    _ = self;
    _ = progress;

    std.debug.print("Copying CEF binaries...\n", .{});

    try copyDirectory("cef/binaries", "zig-out/bin");
    try copyDirectory("cef/binaries/locales", "zig-out/bin/locales");
}

fn copyDirectory(src: []const u8, dest: []const u8) !void {
    var dest_dir = try std.fs.cwd().makeOpenPath(dest, .{});
    defer dest_dir.close();

    var src_iter_dir = try std.fs.cwd().openIterableDir(src, .{});
    defer src_iter_dir.close();

    var src_dir = try std.fs.cwd().openDir(src, .{});
    defer src_dir.close();

    var iterator = src_iter_dir.iterate();
    while (try iterator.next()) |entry| {
        if (entry.kind != .file) continue;

        try src_dir.copyFile(entry.name, dest_dir, entry.name, .{});
    }
}
